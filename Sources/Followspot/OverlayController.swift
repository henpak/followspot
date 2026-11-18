import AppKit
import FollowspotCore

/// Central coordinator: holds the `OverlayState` and connects input (mouse, hotkeys, menu)
/// with output (overlay panels). design.md, Decision 7.
@MainActor
final class OverlayController {
    private(set) var state = OverlayState() {
        didSet { stateDidChange() }
    }

    /// User-selected marking colours; persisted and applied on every change.
    private(set) var colors: MarkingColors {
        didSet {
            guard colors != oldValue else { return }
            colorStore.save(colors)
            overlays.applyColors(colors)
        }
    }

    /// User-selected sizes, dimming levels and guides switch; persisted and applied on every change.
    private(set) var appearance: AppearanceSettings {
        didSet {
            guard appearance != oldValue else { return }
            appearanceStore.save(appearance)
            overlays.applyAppearance(appearance)
        }
    }

    private let colorStore = ColorStore()
    private let appearanceStore = AppearanceStore()
    private let overlays = OverlayManager()
    private let mouse = MouseEventMonitor()
    private let hotkeys = HotkeyManager()
    private var statusMenu: StatusMenu?
    private var screenObserver: NSObjectProtocol?

    var failedHotkeys: [HotkeyAction] { hotkeys.failedActions }

    init() {
        colors = colorStore.load()
        appearance = appearanceStore.load()
    }

    func start() {
        overlays.applyColors(colors)
        overlays.applyAppearance(appearance)
        overlays.onSelectionFinished = { [weak self] rect, displayID in
            self?.state.finishSelection(rect: rect, displayID: displayID)
        }
        overlays.onSelectionCancelled = { [weak self] in
            self?.state.cancelSelection()
        }
        overlays.rebuild()

        mouse.onClick = { [weak self] location, kind in
            self?.handleGlobalClick(at: location, kind: kind)
        }
        mouse.onMove = { [weak self] in
            self?.overlays.cursorMoved()
        }
        mouse.start()

        hotkeys.onHotkey = { [weak self] action in
            self?.perform(action)
        }
        hotkeys.start()

        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.screensChanged() }
        }

        statusMenu = StatusMenu(controller: self)
        stateDidChange()
    }

    func stop() {
        mouse.stop()
        hotkeys.stop()
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
        overlays.closeAll()
        statusMenu?.remove()
    }

    // MARK: Actions

    func perform(_ action: HotkeyAction) {
        switch action {
        case .highlight: state.toggleSelection()
        case .spotlight: state.toggleSpotlight()
        case .halo: state.toggleHalo()
        case .clickRings: state.toggleClickRings()
        }
    }

    func toggleClickRings() {
        state.toggleClickRings()
    }

    /// Changes the accent colour; ignored if the right-click colour already uses it.
    func setAccentColor(_ color: PaletteColor) {
        colors.setAccent(color)
    }

    /// Changes the right-click colour; ignored if the accent colour already uses it.
    func setRightClickColor(_ color: PaletteColor) {
        colors.setRightClick(color)
    }

    func setClickRingSize(_ size: MarkingSize) { appearance.clickRingSize = size }
    func setHaloSize(_ size: MarkingSize) { appearance.haloSize = size }
    func setSpotlightSize(_ size: MarkingSize) { appearance.spotlightSize = size }
    func setHighlightDimming(_ level: DimLevel) { appearance.highlightDimming = level }
    func setSpotlightDimming(_ level: DimLevel) { appearance.spotlightDimming = level }
    func toggleSelectionGuides() { appearance.showsSelectionGuides.toggle() }

    func quit() {
        state.clearAll()
        NSApp.terminate(nil)
    }

    // MARK: Private

    private func handleGlobalClick(at location: CGPoint, kind: ClickKind) {
        if state.clickRingsEnabled {
            overlays.showRing(atGlobal: location, kind: kind)
        }
        // The click itself reaches the app below (overlay is click-through); it only
        // removes the highlight here.
        state.registerGlobalClick()
    }

    private func screensChanged() {
        overlays.rebuild()
        state.displaysChanged(available: overlays.displayIDs)
    }

    private func stateDidChange() {
        overlays.apply(state)
        overlays.cursorMoved()
    }
}
