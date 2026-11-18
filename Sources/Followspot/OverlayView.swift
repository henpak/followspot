import AppKit
import FollowspotCore
import QuartzCore

/// Draws all markings for one screen with Core Animation layers (design.md, Decision 4).
/// Coordinates are local to the screen, origin bottom-left (unflipped, like Cocoa).
@MainActor
final class OverlayView: NSView {

    /// Called with the selected rectangle (local coordinates) when a drag ends.
    var onSelectionFinished: ((CGRect) -> Void)?
    var onSelectionCancelled: (() -> Void)?
    /// Called when this view observes the mouse moving (tracking area / drag).
    var onCursorMoved: (() -> Void)?

    private let rootLayer = CALayer()
    private let selectionCatcher = CALayer()
    private let spotlightLayer = CAShapeLayer()
    private let highlightDimLayer = CAShapeLayer()
    private let highlightBorderLayer = CAShapeLayer()
    private let haloLayer = CAShapeLayer()
    private let crosshairLayer = CAShapeLayer()
    private let selectionLayer = CAShapeLayer()
    private let ringContainer = CALayer()

    private var fullSizeLayers: [CALayer] {
        [selectionCatcher, spotlightLayer, highlightDimLayer, highlightBorderLayer,
         crosshairLayer, selectionLayer, ringContainer]
    }

    private var contentsScale: CGFloat = 2
    private var colors = MarkingColors()
    private var settings = AppearanceSettings()
    private var isSelecting = false
    private var dragStart: CGPoint?
    private var spotlightOn = false
    private var haloOn = false
    private var highlightRect: CGRect?
    /// Cursor position in local coordinates, nil when the cursor is on another screen.
    private var cursor: CGPoint?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        layer = rootLayer          // layer-hosting view
        wantsLayer = true
        setUpLayers()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override var isFlipped: Bool { false }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    // MARK: Setup

    private func setUpLayers() {
        selectionCatcher.backgroundColor = Style.selectionCatcherColor.cgColor
        selectionCatcher.isHidden = true

        for dim in [spotlightLayer, highlightDimLayer] {
            dim.fillRule = .evenOdd
            dim.isHidden = true
        }

        highlightBorderLayer.fillColor = nil
        highlightBorderLayer.lineWidth = Style.highlightBorderWidth
        highlightBorderLayer.isHidden = true

        haloLayer.lineWidth = Style.haloLineWidth
        haloLayer.isHidden = true

        crosshairLayer.fillColor = nil
        crosshairLayer.lineWidth = Style.crosshairLineWidth
        crosshairLayer.isHidden = true

        selectionLayer.lineWidth = Style.selectionLineWidth
        selectionLayer.lineDashPattern = [6, 4]
        selectionLayer.isHidden = true

        // Bottom to top.
        for sublayer in [selectionCatcher, spotlightLayer, highlightDimLayer, highlightBorderLayer,
                         haloLayer, crosshairLayer, selectionLayer, ringContainer] {
            rootLayer.addSublayer(sublayer)
        }
        updateLayerColors()
        updateAppearanceLayers()
    }

    /// Applies new sizes, dimming levels and the guides switch immediately, also to an active
    /// halo, spotlight, highlight or selection (spec marking-appearance). Running ring
    /// animations keep their size.
    func applyAppearance(_ newAppearance: AppearanceSettings) {
        guard newAppearance != settings else { return }
        settings = newAppearance
        withoutAnimation {
            updateAppearanceLayers()
            refreshCursorDependent()
        }
    }

    private func updateAppearanceLayers() {
        highlightDimLayer.fillColor = Style.dimColor(settings.highlightDimming).cgColor
        spotlightLayer.fillColor = Style.dimColor(settings.spotlightDimming).cgColor

        let d = Style.haloRadius(settings.haloSize) * 2
        haloLayer.bounds = CGRect(x: 0, y: 0, width: d, height: d)   // position (centre) is kept
        haloLayer.path = CGPath(ellipseIn: haloLayer.bounds.insetBy(dx: Style.haloLineWidth / 2, dy: Style.haloLineWidth / 2), transform: nil)
    }

    /// Applies new marking colours immediately, also to visible markings
    /// (spec marking-colors: Sofortige Wirkung). Running ring animations keep their colour.
    func applyColors(_ newColors: MarkingColors) {
        guard newColors != colors else { return }
        colors = newColors
        withoutAnimation { updateLayerColors() }
    }

    private func updateLayerColors() {
        let accent = colors.accent
        haloLayer.fillColor = Style.haloFill(accent).cgColor
        haloLayer.strokeColor = Style.haloStroke(accent).cgColor
        highlightBorderLayer.strokeColor = Style.highlightBorder(accent).cgColor
        crosshairLayer.strokeColor = Style.crosshair(accent).cgColor
        selectionLayer.fillColor = Style.selectionFill(accent).cgColor
        selectionLayer.strokeColor = Style.selectionStroke(accent).cgColor
    }

    func setContentsScale(_ scale: CGFloat) {
        contentsScale = scale
        withoutAnimation {
            rootLayer.contentsScale = scale
            for l in fullSizeLayers + [haloLayer] { l.contentsScale = scale }
        }
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        withoutAnimation {
            rootLayer.frame = bounds
            for l in fullSizeLayers { l.frame = bounds }
            refreshAll()
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas { removeTrackingArea(area) }
        addTrackingArea(NSTrackingArea(rect: .zero,
                                       options: [.activeAlways, .mouseMoved, .cursorUpdate, .inVisibleRect],
                                       owner: self))
    }

    // MARK: State

    func apply(_ state: OverlayState, displayID: CGDirectDisplayID) {
        spotlightOn = state.spotlightEnabled
        haloOn = state.haloEnabled
        if let h = state.highlight, h.displayID == displayID {
            highlightRect = h.rect
        } else {
            highlightRect = nil
        }
        withoutAnimation { refreshAll() }
    }

    func setSelecting(_ selecting: Bool) {
        guard selecting != isSelecting else { return }
        isSelecting = selecting
        dragStart = nil
        withoutAnimation {
            selectionCatcher.isHidden = !selecting
            selectionLayer.isHidden = true
            refreshCursorDependent()
        }
        if selecting, cursor != nil { NSCursor.crosshair.set() }
    }

    /// - Parameter local: cursor position on this screen, or nil if it is on another screen.
    func updateCursor(_ local: CGPoint?) {
        cursor = local
        withoutAnimation { refreshCursorDependent() }
    }

    private func refreshAll() {
        if let r = highlightRect {
            highlightDimLayer.path = DimmingPath.make(bounds: bounds, cutout: .rect(r, cornerRadius: Style.highlightCornerRadius))
            let inset = -Style.highlightBorderWidth / 2
            let borderRect = r.insetBy(dx: inset, dy: inset)
            let radius = min(Style.highlightCornerRadius, borderRect.width / 2, borderRect.height / 2)
            highlightBorderLayer.path = CGPath(roundedRect: borderRect, cornerWidth: radius, cornerHeight: radius, transform: nil)
            highlightDimLayer.isHidden = false
            highlightBorderLayer.isHidden = false
        } else {
            highlightDimLayer.isHidden = true
            highlightBorderLayer.isHidden = true
        }
        refreshCursorDependent()
    }

    private func refreshCursorDependent() {
        // Spotlight: all screens are dimmed, only the screen with the cursor gets the bright circle.
        spotlightLayer.isHidden = !spotlightOn
        if spotlightOn {
            let radius = Style.spotlightRadius(settings.spotlightSize)
            let cutout = cursor.map { Cutout.circle(center: $0, radius: radius) }
            spotlightLayer.path = DimmingPath.make(bounds: bounds, cutout: cutout)
        }

        if haloOn, let c = cursor {
            haloLayer.position = c
            haloLayer.isHidden = false
        } else {
            haloLayer.isHidden = true
        }

        // Guide lines only while selecting and if enabled; the selection rectangle is independent.
        if isSelecting, settings.showsSelectionGuides, let c = cursor {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: bounds.minX, y: c.y))
            path.addLine(to: CGPoint(x: bounds.maxX, y: c.y))
            path.move(to: CGPoint(x: c.x, y: bounds.minY))
            path.addLine(to: CGPoint(x: c.x, y: bounds.maxY))
            crosshairLayer.path = path
            crosshairLayer.isHidden = false
        } else {
            crosshairLayer.isHidden = true
        }
    }

    // MARK: Click rings

    func showRing(at point: CGPoint, kind: ClickKind) {
        let color: NSColor
        switch kind {
        case .left: color = Style.color(colors.accent)
        case .right: color = Style.color(colors.rightClick)
        case .other: color = Style.otherClickColor
        }

        let metrics = Style.ring(settings.clickRingSize)
        let ring = CAShapeLayer()
        let d = metrics.startRadius * 2
        ring.bounds = CGRect(x: 0, y: 0, width: d, height: d)
        ring.position = point
        ring.contentsScale = contentsScale
        ring.path = CGPath(ellipseIn: ring.bounds.insetBy(dx: metrics.lineWidth / 2, dy: metrics.lineWidth / 2), transform: nil)
        ring.fillColor = color.withAlphaComponent(Style.ringFillAlpha).cgColor
        ring.strokeColor = color.cgColor
        ring.lineWidth = metrics.lineWidth

        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1
        scale.toValue = metrics.endRadius / metrics.startRadius
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1
        fade.toValue = 0
        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = Style.ringDuration
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock { [weak ring] in ring?.removeFromSuperlayer() }
        ring.opacity = 0   // final model value; the animation shows the fade
        ringContainer.addSublayer(ring)
        ring.add(group, forKey: "ring")
        CATransaction.commit()
    }

    // MARK: Mouse (only delivered while selecting – otherwise the panel ignores the mouse)

    override func mouseMoved(with event: NSEvent) {
        if isSelecting { NSCursor.crosshair.set() }
        onCursorMoved?()
    }

    override func cursorUpdate(with event: NSEvent) {
        if isSelecting {
            NSCursor.crosshair.set()
        } else {
            super.cursorUpdate(with: event)
        }
    }

    override func mouseDown(with event: NSEvent) {
        guard isSelecting else { return }
        dragStart = convert(event.locationInWindow, from: nil)
        NSCursor.crosshair.set()
    }

    override func mouseDragged(with event: NSEvent) {
        guard isSelecting, let start = dragStart else { return }
        let rect = ScreenGeometry.rect(from: start, to: convert(event.locationInWindow, from: nil), clampedTo: bounds)
        withoutAnimation {
            selectionLayer.path = CGPath(rect: rect, transform: nil)
            selectionLayer.isHidden = false
        }
        NSCursor.crosshair.set()
        onCursorMoved?()
    }

    override func mouseUp(with event: NSEvent) {
        guard isSelecting, let start = dragStart else { return }
        dragStart = nil
        let rect = ScreenGeometry.rect(from: start, to: convert(event.locationInWindow, from: nil), clampedTo: bounds)
        withoutAnimation { selectionLayer.isHidden = true }
        onSelectionFinished?(rect)
    }

    override func rightMouseDown(with event: NSEvent) {
        guard isSelecting else { return }
        dragStart = nil
        withoutAnimation { selectionLayer.isHidden = true }
        onSelectionCancelled?()
    }

    // MARK: Helpers

    private func withoutAnimation(_ body: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        body()
        CATransaction.commit()
    }
}
