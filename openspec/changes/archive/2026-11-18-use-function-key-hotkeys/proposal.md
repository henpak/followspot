# Proposal

## Why

The current shortcuts `⌃⌥H/S/C` need two modifiers and are hard to reach with one hand. During a presentation the other hand is usually on the mouse or trackpad. What is needed is a layout with a single modifier that conflicts neither with macOS nor with common apps and does not block a character while typing.

Possible alternatives and why they are ruled out:

- `⌃F1–F8` are macOS keyboard navigation.
- `⌃1–3` switch desktops and are taken in Xcode.
- `⌘1–3` are taken in almost every app.
- `⌥1–3` type `¡ “ ¶`.
- `⌃`+letter are text bindings and taken in the terminal.

`⌥F1–F3` has none of these drawbacks.

## What Changes

- **BREAKING** New layout of the system-wide shortcuts. The old `⌃⌥H/S/C` are removed without replacement:
  - `⌥F1` (instead of `⌃⌥H`): highlight area, i.e. start the rectangle selection
  - `⌥F2` (instead of `⌃⌥S`): spotlight on/off
  - `⌥F3` (instead of `⌃⌥C`): cursor halo on/off
  - `⌥F4` (**new**): click rings on/off. So far this was only possible from the menu, so not during a presentation without reaching for the menu bar.
- The order F1 → F3 follows frequency: the highlight is used most and sits on the key that is easiest to hit.
- Esc stays unchanged: it is only captured while something is active.
- The menu bar menu shows the new shortcuts at its items. The warning “Shortcut … unavailable” also uses the new name.
- The usage table in the README is updated.
- The shortcuts stay hard-coded. A freely configurable layout is not part of this change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `presenter-controls`: in the requirement “System-wide shortcuts” the shortcuts change from `ctrl+opt+H/S/C` to `opt+F1/F2/F3`. `opt+F4` is added to toggle the click rings. The capability is introduced by `add-presenter-overlay`.
- `marking-appearance`: the scenarios of the requirement “Crosshair guides during rectangle selection” currently name `ctrl+opt+H`. They are rephrased without a shortcut (“starts a rectangle selection”). The capability is introduced by `add-marking-colors`.

## Impact

- **Code:**
  - `Sources/Presenter/HotkeyManager.swift`: `keyCode`, `carbonModifiers`, `menuKey` and `displayShortcut` in `HotkeyAction`, plus the new action for the click rings
  - `Sources/Presenter/OverlayController.swift`: perform the new action
  - `Sources/Presenter/StatusMenu.swift`: modifier mask of the menu items, showing F-keys as key equivalents
- **Docs:** `README.md` (shortcut table and the mentions of `⌃⌥H` in the text)
- **No change** to PresenterCore, tests, permissions, stored settings or the build.
- **Dependency:** the modified capabilities only exist in the not yet archived changes `add-presenter-overlay` and `add-marking-colors`. Those two must therefore be archived before this change.
