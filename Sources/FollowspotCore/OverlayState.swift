import CoreGraphics

public enum OverlayMode: Equatable, Sendable {
    /// Overlay is click-through; markings are only displayed.
    case normal
    /// One-shot rectangle selection: the overlay captures the mouse until one rectangle is drawn.
    case selecting
}

/// A highlighted rectangle on one display.
public struct Highlight: Equatable, Sendable {
    /// Rectangle in the local coordinate space of the display.
    public var rect: CGRect
    public var displayID: UInt32

    public init(rect: CGRect, displayID: UInt32) {
        self.rect = rect
        self.displayID = displayID
    }
}

/// The complete, UI-independent state of the overlay (see design.md, Decision 7).
public struct OverlayState: Equatable, Sendable {

    /// Drags smaller than this (in points, per side) count as a plain click: no highlight.
    public static let minimumSelectionSize: CGFloat = 4

    public var clickRingsEnabled = true
    public private(set) var haloEnabled = false
    public private(set) var spotlightEnabled = false
    public private(set) var mode: OverlayMode = .normal
    public private(set) var highlight: Highlight?

    public init() {}

    /// The rectangle-highlight function is on: a selection is running or a highlight is visible.
    public var isHighlightActive: Bool {
        mode == .selecting || highlight != nil
    }

    // MARK: Rectangle highlight

    /// Highlight hotkey / menu entry: starts a selection when nothing is active, otherwise
    /// cancels the running selection or removes the visible highlight. Halo, spotlight and
    /// click rings are not affected (design.md of replace-escape-with-toggle-hotkeys, Decision 1).
    public mutating func toggleSelection() {
        if mode == .selecting {
            cancelSelection()
        } else if highlight != nil {
            highlight = nil
        } else {
            beginSelection()
        }
    }

    /// Starts a one-shot selection. An existing highlight is replaced.
    public mutating func beginSelection() {
        highlight = nil
        mode = .selecting
    }

    /// Ends the selection with the dragged rectangle. Too small rectangles (a click
    /// without dragging) end the selection without creating a highlight.
    public mutating func finishSelection(rect: CGRect, displayID: UInt32) {
        guard mode == .selecting else { return }
        mode = .normal
        let r = rect.standardized
        guard r.width >= Self.minimumSelectionSize, r.height >= Self.minimumSelectionSize else { return }
        highlight = Highlight(rect: r, displayID: displayID)
    }

    public mutating func cancelSelection() {
        mode = .normal
    }

    /// A normal click somewhere on screen (observed globally) removes the highlight.
    public mutating func registerGlobalClick() {
        guard mode == .normal else { return }
        highlight = nil
    }

    // MARK: Toggles

    public mutating func toggleSpotlight() { spotlightEnabled.toggle() }
    public mutating func toggleHalo() { haloEnabled.toggle() }
    public mutating func toggleClickRings() { clickRingsEnabled.toggle() }

    // MARK: Cleanup

    /// Removes everything, e.g. before quitting. Click rings are a passive feature, not a
    /// marking, and stay as they are.
    public mutating func clearAll() {
        mode = .normal
        highlight = nil
        spotlightEnabled = false
        haloEnabled = false
    }

    /// Drops a highlight whose display is no longer connected.
    public mutating func displaysChanged(available: Set<UInt32>) {
        if let h = highlight, !available.contains(h.displayID) {
            highlight = nil
        }
    }
}
