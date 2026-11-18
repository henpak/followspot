import AppKit

/// Transparent, borderless panel covering exactly one screen (design.md, Decision 3).
@MainActor
final class OverlayPanel: NSPanel {
    let displayID: CGDirectDisplayID
    let overlayView: OverlayView

    init(displayID: CGDirectDisplayID) {
        self.displayID = displayID
        self.overlayView = OverlayView(frame: .zero)
        super.init(contentRect: .zero,
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered,
                   defer: false)

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        ignoresMouseEvents = true
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        animationBehavior = .none
        // sharingType stays at its default so screen sharing captures the overlay.
        contentView = overlayView
    }

    /// Positions the panel over `screen` and shows it.
    func place(on screen: NSScreen) {
        setFrame(screen.frame, display: true)
        overlayView.setContentsScale(screen.backingScaleFactor)
        orderFrontRegardless()
    }

    /// While selecting, the panel takes the mouse; otherwise it is click-through.
    func setSelecting(_ selecting: Bool) {
        ignoresMouseEvents = !selecting
        overlayView.setSelecting(selecting)
    }

    // Never take keyboard focus away from the presented app.
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    // Borderless windows may cover the menu bar area; do not let AppKit move them.
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        frameRect
    }
}

extension NSScreen {
    var displayID: CGDirectDisplayID? {
        (deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value
    }
}
