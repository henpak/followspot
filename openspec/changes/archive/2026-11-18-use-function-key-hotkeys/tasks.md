# Tasks

## 1. New layout

- [x] 1.1 Change the layout in `HotkeyAction` (`Sources/Presenter/HotkeyManager.swift`):
  - `keyCode` to `kVK_F1`/`kVK_F2`/`kVK_F3`
  - `carbonModifiers` to `optionKey`; Esc stays without a modifier
  - `menuKey` to the `NSF1FunctionKey` code points
  - `displayShortcut` to `⌥F1`/`⌥F2`/`⌥F3`
  - new property `menuModifiers` (design.md, Decisions 1–3)

  Verify: `swift build` runs without errors.
- [x] 1.2 `StatusMenu.addItem` takes the modifier mask from `hotkey.menuModifiers` instead of the fixed `[.control, .option]`. Verify: `swift build`. The menu shows `⌥F1` at “Highlight area”, `⌥F2` at “Spotlight” and `⌥F3` at “Cursor halo”.
- [x] 1.3 Update the README: shortcut table, the mentions of `⌃⌥H` in the text (“new rectangle”, table “Guides”) and a note on the fn setting (design.md, Risks). Verify: `grep -n "⌃⌥" README.md` finds nothing.

- [x] 1.4 Add a new `HotkeyAction` for the click rings:
  - raw value 5, `⌥F4`
  - add it to `standard`
  - `OverlayController.perform` toggles the click rings with it
  - the menu item “Click rings” shows `⌥F4`
  - extend the README table

  Verify: `swift build`, no registration errors in the log.

## 2. Check in the running app

- [x] 2.1 Build and install with `scripts/build-app.sh --open`, then run `swift test` (66 tests stay green). Check that the menu shows no “Shortcut … unavailable” notice.
- [x] 2.2 Manually in another app, e.g. Safari in front:
  - `⌥F1` starts the rectangle selection.
  - `⌥F2` toggles the spotlight.
  - `⌥F3` toggles the halo.
  - `⌥F4` turns the click rings off and on again.
  - Esc removes everything.
  - The app in front does not lose focus.
- [x] 2.3 Manually: `⌃⌥S` in another app no longer triggers anything in Presenter (spec scenario “Former shortcuts are free”).

## Workflow follow-up

- Before archiving this change, archive `add-presenter-overlay` and `add-marking-colors` first (design.md, Migration Plan).
