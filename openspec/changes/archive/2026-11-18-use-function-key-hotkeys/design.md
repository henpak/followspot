# Design

## Context

The hotkeys are registered with Carbon `RegisterEventHotKey` (see `add-presenter-overlay`, Decision 6). This needs no permission, and the keystroke is consumed. The layout is hard-coded in `HotkeyAction`:

- `keyCode`
- `carbonModifiers`
- `menuKey` and `displayShortcut` for display in the menu

The menu takes `menuKey` as its key equivalent and hard-codes the modifier mask to `[.control, .option]`.

Relevant facts on the developer's Mac:

- Keyboard layout ABC-QWERTZ.
- “Use F1, F2, etc. keys as standard function keys” is **on** (`com.apple.keyboard.fnState = 1`). The top-row keys therefore send F1… without fn.
- `⌥F1–F3` are neither macOS system shortcuts (keyboard navigation uses `⌃F1–F8`) nor do they produce a character.

## Goals / Non-Goals

**Goals:**
- Shortcuts with one modifier that can be reached with one hand, without character or system conflicts.
- The display in the menu (shortcut at the item, warning) automatically matches the registration.

**Non-Goals:**
- Freely configurable shortcuts (recorder in the menu, persistence in UserDefaults).
- Keeping the old `⌃⌥` shortcuts as aliases.
- Detecting whether another app uses `⌥F1–F3`: Carbon hotkeys take precedence over app shortcuts.

## Decisions

### 1. Mapping F1 = highlight, F2 = spotlight, F3 = halo

The highlight is used most and sits on the outermost key, the easiest to hit blindly. Spotlight and halo follow in the order of the previous layout (H, S, C).

Rejected: the menu order (halo, spotlight, highlight). It grew historically and is not sorted by frequency.

`⌥F4` toggles the click rings. So far they could only be switched from the menu; they are added as a new `HotkeyAction` with raw value 5, so the IDs of the existing actions stay stable. The action is registered permanently like F1–F3. Esc still does not turn the click rings off, because they are a base setting and not a temporary marking.

### 2. Modifiers as a property of `HotkeyAction`, the menu derives the mask from it

Next to `carbonModifiers`, `HotkeyAction` gets a matching `menuModifiers: NSEvent.ModifierFlags`. `StatusMenu` uses it instead of hard-coding `[.control, .option]`. That keeps registration and display in one place, and a future change only touches `HotkeyAction`.

Rejected: changing the mask in `StatusMenu` to `[.option]`. That is smaller, but the duplication remains.

### 3. F-keys in the menu through the function key code points

For F1–F3, `menuKey` returns `String(UnicodeScalar(NSF1FunctionKey)!)` and so on. AppKit shows these code points in the menu as “F1”, together with the modifier mask as `⌥F1`. The Carbon key codes are `kVK_F1`, `kVK_F2` and `kVK_F3`.

### 4. Specs without shortcuts where the shortcut is only a means to an end

The scenarios in `marking-appearance` test the guides, not the shortcut. They therefore only speak of “starting the rectangle selection”. The concrete shortcuts are defined only in `presenter-controls`.

## Risks / Trade-offs

- **fnState is switched:** if the user turns off the system setting “Use F1, F2, etc. keys as standard function keys”, the top-row keys send brightness and so on. The shortcuts are then `fn⌥F1`. → The README mentions this dependency.
- **App shortcuts are shadowed:** some apps use `⌥F1–F3`, e.g. JetBrains IDEs (“Select In” on `⌥F1`). While Presenter runs, these do not reach them. → Accepted. If it gets in the way, a configurable layout is a separate later change.
- **Registration fails:** if another app already holds the shortcut globally, the existing warning in the menu applies. → No additional effort.

## Migration Plan

- Rebuild and install with `scripts/build-app.sh --open`. The settings in UserDefaults are not affected.
- Rollback: go back to the previous commit and rebuild.
- Archiving: archive `add-presenter-overlay` and `add-marking-colors` first, then this change. The MODIFIED deltas require `presenter-controls` and `marking-appearance` to exist as main specs.
