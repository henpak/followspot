# Proposal

## Why

Bug report: the halo is on, the user highlights an area and presses Esc. The highlight disappears as expected, but the halo turns off too. The expectation was that the halo stays.

The cause is not a programming error but the previous definition: Esc removes “all active markings” and therefore also turns off halo and spotlight (`add-presenter-overlay`, design.md Decision 7). There is also a side effect: while halo or spotlight are on, Presenter captures Esc system-wide, so the presented app (Keynote, dialogs) does not receive it.

The user wants a consistent operating principle: every shortcut turns its feature on, and pressing it again turns it off. Esc is no longer needed for that.

## What Changes

- **BREAKING** Presenter no longer captures Esc, in any state. It always reaches the app in front.
- `⌥F1` becomes a toggle:
  - nothing active → start the rectangle selection
  - selection running → cancel the selection
  - highlight visible → remove the highlight (previously: start a new selection that replaces the old one)
- `⌥F2`, `⌥F3`, `⌥F4` stay toggles as before. Halo and spotlight are only turned off by their own shortcut, the menu or “Quit”.
- Unchanged: a normal click removes the highlight; a click without dragging cancels the selection.
- Menu: the note “Esc removes all markings” is dropped. “Highlight area” carries a check mark while a selection or a highlight is active, and toggles like `⌥F1`.
- README: shortcut table and explanations without Esc.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `presenter-controls`: “System-wide shortcuts” describes `⌥F1` as a toggle; “Esc removes markings” is removed; “Menu bar menu” without the Esc note and with a state for “Highlight area”.
- `area-highlighting`: cancelling the selection and removing the highlight with `⌥F1` instead of Esc; pressing `⌥F1` again with a visible highlight removes it instead of starting a new one.

## Impact

- **Code:**
  - `Sources/PresenterCore/OverlayState.swift`: `toggleSelection()`, `isHighlightActive`; `escape()`, `hasActiveMarkings`, `escapeShouldBeRegistered` are removed
  - `Sources/Presenter/HotkeyManager.swift`: `HotkeyAction.escape` and the dynamic Esc registration are removed
  - `Sources/Presenter/OverlayController.swift`, `Sources/Presenter/StatusMenu.swift`
- **Tests:** `OverlayStateTests` updated
- **Docs:** `README.md`
- No change to stored settings, permissions or the build.
