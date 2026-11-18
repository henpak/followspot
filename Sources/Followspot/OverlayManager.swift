import AppKit
import FollowspotCore

/// Owns one `OverlayPanel` per connected screen and routes drawing commands to them.
@MainActor
final class OverlayManager {
    var onSelectionFinished: ((CGRect, CGDirectDisplayID) -> Void)?
    var onSelectionCancelled: (() -> Void)?

    private var panels: [CGDirectDisplayID: OverlayPanel] = [:]
    private var state = OverlayState()
    private var colors = MarkingColors()
    private var appearance = AppearanceSettings()

    var displayIDs: Set<UInt32> { Set(panels.keys) }

    /// (Re)creates panels to match the currently connected screens. Safe to call repeatedly.
    func rebuild() {
        var connected = Set<CGDirectDisplayID>()
        for screen in NSScreen.screens {
            guard let id = screen.displayID else { continue }
            connected.insert(id)
            let panel = panels[id] ?? makePanel(displayID: id)
            panels[id] = panel
            panel.place(on: screen)
        }
        for (id, panel) in panels where !connected.contains(id) {
            panel.orderOut(nil)
            panel.close()
            panels[id] = nil
        }
        Log.event("overlay rebuilt for \(panels.count) screen(s)")
        applyColors(colors)
        applyAppearance(appearance)
        apply(state)
        cursorMoved()
    }

    func closeAll() {
        for panel in panels.values {
            panel.orderOut(nil)
            panel.close()
        }
        panels.removeAll()
    }

    func apply(_ newState: OverlayState) {
        state = newState
        let selecting = newState.mode == .selecting
        for (id, panel) in panels {
            panel.setSelecting(selecting)
            panel.overlayView.apply(newState, displayID: id)
        }
    }

    /// Recolours all panels; also remembered for panels created later (screen plugged in).
    func applyColors(_ newColors: MarkingColors) {
        colors = newColors
        for panel in panels.values {
            panel.overlayView.applyColors(newColors)
        }
    }

    /// Applies sizes, dimming and guides to all panels; also remembered for panels created later.
    func applyAppearance(_ newAppearance: AppearanceSettings) {
        appearance = newAppearance
        for panel in panels.values {
            panel.overlayView.applyAppearance(newAppearance)
        }
    }

    /// Reads the current global mouse location and updates cursor-following markings.
    func cursorMoved() {
        let global = NSEvent.mouseLocation
        let entries = Array(panels.values)
        let index = ScreenGeometry.screenIndex(containing: global, frames: entries.map(\.frame))
        for (i, panel) in entries.enumerated() {
            let local = (i == index) ? ScreenGeometry.localPoint(global, inScreenFrame: panel.frame) : nil
            panel.overlayView.updateCursor(local)
        }
    }

    func showRing(atGlobal global: CGPoint, kind: ClickKind) {
        let entries = Array(panels.values)
        guard let index = ScreenGeometry.screenIndex(containing: global, frames: entries.map(\.frame)) else { return }
        let panel = entries[index]
        panel.overlayView.showRing(at: ScreenGeometry.localPoint(global, inScreenFrame: panel.frame), kind: kind)
    }

    private func makePanel(displayID: CGDirectDisplayID) -> OverlayPanel {
        let panel = OverlayPanel(displayID: displayID)
        panel.overlayView.onSelectionFinished = { [weak self] rect in
            self?.onSelectionFinished?(rect, displayID)
        }
        panel.overlayView.onSelectionCancelled = { [weak self] in
            self?.onSelectionCancelled?()
        }
        panel.overlayView.onCursorMoved = { [weak self] in
            self?.cursorMoved()
        }
        return panel
    }
}
