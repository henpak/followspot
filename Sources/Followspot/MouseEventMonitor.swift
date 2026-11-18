import AppKit
import FollowspotCore

/// Observes mouse clicks and movement in all apps via global NSEvent monitors
/// (design.md, Decision 5). Events sent to this app itself are not seen – that is
/// intended: while selecting, the overlay handles the mouse locally.
@MainActor
final class MouseEventMonitor {
    /// Global click position (Cocoa global coordinates) and kind.
    var onClick: ((CGPoint, ClickKind) -> Void)?
    var onMove: (() -> Void)?

    private var monitors: [Any] = []

    func start() {
        stop()

        let clicks: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        if let m = NSEvent.addGlobalMonitorForEvents(matching: clicks, handler: { [weak self] event in
            // Global monitor handlers run on the main thread.
            MainActor.assumeIsolated { self?.handleClick(event) }
        }) {
            monitors.append(m)
        } else {
            Log.event("global click monitor could NOT be installed")
        }

        let moves: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
        if let m = NSEvent.addGlobalMonitorForEvents(matching: moves, handler: { [weak self] _ in
            MainActor.assumeIsolated { self?.onMove?() }
        }) {
            monitors.append(m)
        } else {
            Log.event("global move monitor could NOT be installed")
        }
    }

    func stop() {
        for m in monitors { NSEvent.removeMonitor(m) }
        monitors.removeAll()
    }

    private func handleClick(_ event: NSEvent) {
        // For events without a window, locationInWindow is in global screen coordinates.
        let location = event.window == nil ? event.locationInWindow : NSEvent.mouseLocation
        let kind = ClickKind.classify(buttonNumber: event.buttonNumber,
                                      controlPressed: event.modifierFlags.contains(.control))
        Log.event("click \(kind) at \(Int(location.x)),\(Int(location.y))")
        onClick?(location, kind)
        onMove?()
    }
}
