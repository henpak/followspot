import AppKit
import FollowspotCore

/// Menu bar icon and menu (Spec presenter-controls: Menüleisten-Menü).
@MainActor
final class StatusMenu: NSObject, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let menu = NSMenu()
    private unowned let controller: OverlayController

    init(controller: OverlayController) {
        self.controller = controller
        super.init()
        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "cursorarrow.rays", accessibilityDescription: "Followspot")
            image?.isTemplate = true
            button.image = image
            button.toolTip = "Followspot"
        }
        menu.delegate = self
        menu.autoenablesItems = false
        statusItem.menu = menu
        rebuild()
    }

    func remove() {
        NSStatusBar.system.removeStatusItem(statusItem)
    }

    // Refresh check marks every time the menu opens (state may have changed via hotkeys).
    func menuNeedsUpdate(_ menu: NSMenu) {
        rebuild()
    }

    private func rebuild() {
        menu.removeAllItems()
        let state = controller.state

        addItem("Click Rings", on: state.clickRingsEnabled, hotkey: .clickRings, action: #selector(toggleClickRings))
        addItem("Cursor Halo", on: state.haloEnabled, hotkey: .halo, action: #selector(toggleHalo))
        addItem("Spotlight", on: state.spotlightEnabled, hotkey: .spotlight, action: #selector(toggleSpotlight))
        addItem("Highlight Area", on: state.isHighlightActive, hotkey: .highlight, action: #selector(toggleSelection))

        menu.addItem(.separator())
        menu.addItem(colorItem(title: "Accent Color", forAccent: true))
        menu.addItem(colorItem(title: "Right-Click Color", forAccent: false))

        // Sizes, dimming and guides (spec marking-appearance: Bedienung im Menü).
        let appearance = controller.appearance
        menu.addItem(.separator())
        menu.addItem(levelItem(title: "Click Ring Size", levels: MarkingSize.allCases, active: appearance.clickRingSize,
                               name: \.displayName) { [unowned controller] in controller.setClickRingSize($0) })
        menu.addItem(levelItem(title: "Halo Size", levels: MarkingSize.allCases, active: appearance.haloSize,
                               name: \.displayName) { [unowned controller] in controller.setHaloSize($0) })
        menu.addItem(levelItem(title: "Spotlight Size", levels: MarkingSize.allCases, active: appearance.spotlightSize,
                               name: \.displayName) { [unowned controller] in controller.setSpotlightSize($0) })
        menu.addItem(levelItem(title: "Highlight Dimming", levels: DimLevel.allCases, active: appearance.highlightDimming,
                               name: \.displayName) { [unowned controller] in controller.setHighlightDimming($0) })
        menu.addItem(levelItem(title: "Spotlight Dimming", levels: DimLevel.allCases, active: appearance.spotlightDimming,
                               name: \.displayName) { [unowned controller] in controller.setSpotlightDimming($0) })
        addItem("Crosshair While Selecting", on: appearance.showsSelectionGuides, action: #selector(toggleSelectionGuides))

        let failed = controller.failedHotkeys
        if !failed.isEmpty {
            menu.addItem(.separator())
            for action in failed {
                let item = NSMenuItem(title: "⚠︎ Shortcut \(action.displayShortcut) unavailable", action: nil, keyEquivalent: "")
                item.isEnabled = false
                menu.addItem(item)
            }
        }

        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit Followspot", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    private func addItem(_ title: String, on: Bool? = nil, hotkey: HotkeyAction? = nil, action: Selector) {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: hotkey?.menuKey ?? "")
        if let hotkey {
            item.keyEquivalentModifierMask = hotkey.menuModifiers
        }
        item.target = self
        if let on {
            item.state = on ? .on : .off
        }
        menu.addItem(item)
    }

    /// Menu entry with a submenu of levels (Klein/Mittel/Groß, Leicht/Mittel/Stark);
    /// the active level carries a check mark.
    private func levelItem<Level: Equatable>(title: String,
                                             levels: [Level],
                                             active: Level,
                                             name: (Level) -> String,
                                             select: @escaping (Level) -> Void) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: title)
        submenu.autoenablesItems = false
        for level in levels {
            let entry = NSMenuItem(title: name(level), action: #selector(runAction(_:)), keyEquivalent: "")
            entry.target = self
            entry.representedObject = MenuAction { select(level) }
            entry.state = level == active ? .on : .off
            submenu.addItem(entry)
        }
        item.submenu = submenu
        return item
    }

    @objc private func runAction(_ sender: NSMenuItem) {
        (sender.representedObject as? MenuAction)?.run()
    }

    @objc private func toggleSelectionGuides() { controller.toggleSelectionGuides() }

    /// Menu entry with the active colour as dot and a submenu with the palette
    /// (spec marking-colors: Farbwahl im Menü, Unterscheidbarkeit).
    private func colorItem(title: String, forAccent: Bool) -> NSMenuItem {
        let colors = controller.colors
        let active = forAccent ? colors.accent : colors.rightClick

        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.image = Self.colorDot(active)

        let submenu = NSMenu(title: title)
        submenu.autoenablesItems = false
        for color in PaletteColor.allCases {
            let selectable = colors.isSelectable(color, forAccent: forAccent)
            let entry = NSMenuItem(title: color.displayName,
                                   action: forAccent ? #selector(selectAccent(_:)) : #selector(selectRightClick(_:)),
                                   keyEquivalent: "")
            entry.target = self
            entry.representedObject = color.rawValue
            entry.image = Self.colorDot(color, dimmed: !selectable)
            entry.state = color == active ? .on : .off
            entry.isEnabled = selectable
            if !selectable {
                entry.toolTip = forAccent ? "Already used as the right-click color"
                                          : "Already used as the accent color"
            }
            submenu.addItem(entry)
        }
        item.submenu = submenu
        return item
    }

    /// Small filled circle in a palette colour. Non-template images are not greyed out by
    /// AppKit, so disabled entries are drawn dimmed explicitly. The thin outline keeps light
    /// colours (yellow) visible on a light menu background.
    static func colorDot(_ color: PaletteColor, dimmed: Bool = false) -> NSImage {
        let image = NSImage(size: NSSize(width: 12, height: 12), flipped: false) { rect in
            let path = NSBezierPath(ovalIn: rect.insetBy(dx: 0.5, dy: 0.5))
            Style.color(color, alpha: dimmed ? 0.35 : 1).setFill()
            path.fill()
            NSColor.labelColor.withAlphaComponent(dimmed ? 0.1 : 0.25).setStroke()
            path.lineWidth = 1
            path.stroke()
            return true
        }
        image.isTemplate = false
        return image
    }

    @objc private func selectAccent(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String, let color = PaletteColor(rawValue: id) else { return }
        controller.setAccentColor(color)
    }

    @objc private func selectRightClick(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String, let color = PaletteColor(rawValue: id) else { return }
        controller.setRightClickColor(color)
    }

    @objc private func toggleClickRings() { controller.toggleClickRings() }
    @objc private func toggleHalo() { controller.perform(.halo) }
    @objc private func toggleSpotlight() { controller.perform(.spotlight) }
    @objc private func toggleSelection() { controller.perform(.highlight) }
    @objc private func quit() { controller.quit() }
}

/// Closure carried by a menu item via `representedObject`.
private final class MenuAction: NSObject {
    let run: () -> Void

    init(_ run: @escaping () -> Void) {
        self.run = run
    }
}
