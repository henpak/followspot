# Design

## Context

So far (`add-presenter-overlay`, Decisions 6/7) Esc is registered dynamically as a Carbon hotkey while a selection, highlight, spotlight or halo is active, and `OverlayState.escape()` then resets everything except the click rings. `⌥F1` always starts a new selection; a visible highlight is replaced.

## Goals / Non-Goals

**Goals:**
- Every feature is turned on and off only by its own shortcut (or menu item).
- Esc always belongs to the app in front.

**Non-Goals:**
- An “everything off” shortcut. “Quit” still clears everything.
- Changes to click behavior (a click removes the highlight, a click without dragging cancels).

## Decisions

### 1. `⌥F1` toggles between “off” and “highlight feature active”

“Active” means: a selection is running **or** a highlight is visible (`OverlayState.isHighlightActive`). `toggleSelection()`:

```
isHighlightActive == false  →  beginSelection()
mode == .selecting          →  cancelSelection()
highlight != nil            →  highlight = nil
```

To replace a visible highlight with a new one, press `⌥F1` twice, or click once and then press `⌥F1`.

Rejected: `⌥F1` with a visible highlight keeps starting a new selection. That would contradict the desired principle “press again = off”.

### 2. Remove the Esc hotkey completely

`HotkeyAction.escape` (raw value 4), `setEscapeRegistered`, `isEscapeRegistered`, `escapeShouldBeRegistered` and `hasActiveMarkings` are removed. Raw value 4 is not reused; `clickRings` keeps 5.

### 3. Menu item “Highlight area” with state

The item gets a check mark when `isHighlightActive` and triggers the same toggle as `⌥F1`. It thereby behaves like the other three toggles.

## Risks / Trade-offs

- **Esc habit:** anyone pressing Esc to cancel a selection now changes nothing; Esc goes to the app. → A click without dragging still cancels, and so does `⌥F1`. README and menu no longer mention Esc.
- **Two presses for a new highlight:** accepted deliberately in favor of a consistent principle. Usually there is a click in between anyway, which removes the old highlight.

## Migration Plan

Rebuild with `scripts/build-app.sh --open`. No stored data is affected.
