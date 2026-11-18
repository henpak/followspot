# Tasks

## 1. Logic (PresenterCore)

- [x] 1.1 `OverlayState`: add `toggleSelection()` and `isHighlightActive` (design.md Decision 1); remove `escape()`, `hasActiveMarkings` and `escapeShouldBeRegistered`; `clearAll()` keeps its behavior. Verify: `swift build`.
- [x] 1.2 Update `OverlayStateTests`: remove the Esc tests; add tests for `toggleSelection()` (start, cancel, remove highlight, start again afterwards), for halo/spotlight/click rings staying unchanged when the highlight is toggled, and for `clearAll()`. Verify: `swift test` green.

## 2. App

- [x] 2.1 `HotkeyManager`: remove `HotkeyAction.escape`, `setEscapeRegistered` and `isEscapeRegistered` (design.md Decision 2). Verify: `swift build`.
- [x] 2.2 `OverlayController`: `⌥F1` calls `toggleSelection()`; the Esc registration in `stateDidChange()` is removed; the menu keeps using `perform(.highlight)`. Verify: `swift build`.
- [x] 2.3 `StatusMenu`: remove the note “Esc removes all markings”; “Highlight area” with a check mark when `isHighlightActive`, its action toggles (design.md Decision 3). Verify: `swift build`.
- [x] 2.4 README: remove Esc from the shortcut table and explanations, describe `⌥F1` as a toggle. Verify: the README mentions Esc only to say that Presenter does not capture it.

## 3. Check in the running app

- [x] 3.1 Build and install with `scripts/build-app.sh --open`, `swift test` green.
- [x] 3.2 Manually: halo on → `⌥F1` → drag a rectangle → `⌥F1`: the highlight is gone, the halo stays. The same with the spotlight. Esc in an app (e.g. the Safari search field) works normally there, also while halo, spotlight, selection or highlight are active. `⌥F1` during the selection cancels it. The menu item “Highlight area” shows a check mark while a highlight is visible.
