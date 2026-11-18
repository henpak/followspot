# Design

## Context

Empty repository, no existing specs (motivation: see proposal.md, Why). The target system is the developer's Mac: macOS 26, a laptop display plus an external QHD monitor. The app is only built and used locally. The Xcode toolchain on that Mac is currently broken (`swift --version` fails while loading libraries) and must be repaired before implementation.

## Goals / Non-Goals

**Goals:**
- Buildable and signable entirely from the command line (no clicking in Xcode, except once for the certificate).
- Smooth rendering (halo and spotlight follow the mouse without stutter) on two Retina/QHD displays.
- As few macOS permissions as possible.
- An architecture that later modes (pen, arrows, zoom) can build on without restructuring.

**Non-Goals:**
- Configurable colors, sizes or shortcuts (values are constants in the code).
- Support for macOS versions older than macOS 15.
- Distribution, notarization, auto-update.

## Decisions

### 1. Swift + AppKit, Swift package instead of an Xcode project
A Swift package (executable target) plus a small build script that runs `swift build -c release`, assembles a `Presenter.app` bundle from it (with `Info.plist`, `LSUIElement = true`) and signs it.
- *Alternative Xcode project:* an `.xcodeproj` is hard to maintain by hand or from the CLI. Rejected.
- *Alternative SwiftUI `MenuBarExtra`:* possible for the menu bar, but overlay windows, window levels and event monitors are AppKit anyway. One technology is simpler. Rejected.
- *Alternative Electron/Tauri:* too heavyweight for an overlay tool. Rejected.

### 2. Stable code signature
The build script signs with a fixed identity so macOS permissions survive rebuilds. Preferably an “Apple Development” certificate (free Personal Team, created once in Xcode → Settings → Accounts). The fallback is a self-created code signing certificate in Keychain Access. The identity name is configurable in the script.
- *Alternative ad-hoc signature (`-`):* the signature changes with every build, so permissions would have to be granted again and again. Rejected.

### 3. Overlay: one `NSPanel` per display
For every `NSScreen` a borderless, transparent `NSPanel` (`.nonactivatingPanel`), window level `.screenSaver`, `collectionBehavior` = all Spaces + full-screen auxiliary + stationary, no shadow. `ignoresMouseEvents = true` by default. `sharingType` stays at the default so screen captures include the overlay. On `didChangeScreenParametersNotification` the panels are rebuilt.
- *Alternative one large window across all displays:* macOS does not reliably size windows across display boundaries, and different scale factors cause problems. Rejected.
- Level `.screenSaver` rather than higher (e.g. the shielding level), so system dialogs are not blocked.

### 4. Drawing with Core Animation
Every panel has a layer-backed view. Click rings are short-lived `CAShapeLayer`s with a scale and fade animation that are removed afterwards. The halo is a `CAShapeLayer` whose position is set on mouse movement. Spotlight and rectangle dimming are a `CAShapeLayer` with the path “display area + cut-out” and the even-odd fill rule. Position updates run without implicit animations (`CATransaction.setDisableActions`).
- *Alternative `draw(_:)` with Core Graphics:* a full redraw on every mouse movement, unnecessarily expensive on two high-resolution displays. Rejected.

### 5. Mouse events through global NSEvent monitors
`NSEvent.addGlobalMonitorForEvents` for mouse clicks (left/right/other), `mouseMoved` and drag events. Positions are always taken from `NSEvent.mouseLocation` (global coordinates) and converted to local coordinates per panel (subtracting `screen.frame.origin`). This keeps them correct with two displays in any arrangement and scale.
- Global monitors do not see events sent to the app itself. That is intended: in selection mode the panels handle the mouse locally.
- *Fallback if a spike shows that permissions are missing or events do not arrive:* a listen-only `CGEventTap` (requires Input Monitoring).
- **Spike result (macOS 26.6, 2026-11-11):** global monitors for mouse clicks and movement deliver events from all apps on both displays **without any permission**. `AXIsProcessTrusted()` is `false`, yet clicks arrive, and Presenter does not appear in the Accessibility list. During installation the WindowServer does check `kTCCServiceAccessibility`, but that triggers no dialog. A dialog that was observed came from an `osascript` test (permission for Terminal), not from Presenter. Consequence: neither a `CGEventTap` nor a permission check in the menu is needed. Task 2.2 is dropped.

### 6. Hotkeys through Carbon `RegisterEventHotKey`
System-wide shortcuts without special permissions. The shortcut is consumed and does not reach the app in front. **Esc is registered only dynamically**, while a marking or the selection mode is active, and unregistered immediately afterwards. That way Esc stays with the app in front in every other situation (see spec presenter-controls).
- *Alternative global key monitor (`NSEvent`):* needs Accessibility and cannot consume keys. Rejected.
- *Alternative library (e.g. KeyboardShortcuts):* an external dependency is unnecessary for four fixed shortcuts. Rejected.
- **Spike result (2026-11-11):** `⌃⌥H/S/C` and the dynamic Esc work system-wide and need no permission. Esc reaches the app in front normally while nothing is active.

### 7. State model
A central `OverlayController` holds the state and distributes it to the panels:

```
  Flags (independent):  clickRings (on) | halo (off) | spotlight (off)

  Mode:
   NORMAL --ctrl+opt+H--> SELECTING --drag finished--> NORMAL + highlight(rect, screen)
     ^                      |  |
     |                      |  +--click without drag--> NORMAL
     |                      +--Esc--------------------> NORMAL
     |
     +-- highlight is removed on: global click | Esc | new ctrl+opt+H

  Esc hotkey registered  <=>  SELECTING || highlight != nil || spotlight || halo
```
In the SELECTING state all panels are set to `ignoresMouseEvents = false`. The views return `acceptsFirstMouse = true` so the first click arrives without activating the app. Afterwards it is switched back to `true`.

Spotlight and halo are also turned off by Esc, because according to the spec Esc removes “all active markings”.

### 8. Rectangles across display boundaries
The selection is limited to the display on which dragging started; the coordinates are clamped to its frame. The spotlight, in contrast, dims all displays and only cuts out the circle on the display with the cursor.

### 9. Appearance values (initial values, constants in the code)
- Click ring: line width ≥ 4 pt, start radius about 18 pt, grows to about 30 pt, fades in 0.4 s. Left click yellow/orange, right click blue. High contrast so it survives video compression.
- Halo: radius about 28 pt, semi-transparent fill.
- Dimming: black at 40 % opacity. Rectangle border 3 pt in the accent color.
- Spotlight radius: about 120 pt.

## Risks / Trade-offs

- [Global mouse monitors deliver no events without permission] → Spike as the first task. If so: an Accessibility notice in the menu and, if necessary, a `CGEventTap`.
- [The crosshair cursor cannot be set reliably from an inactive app] → First try cursor rects and `cursorUpdate` on the panel. Fallback: draw a custom crosshair in the overlay.
- [Esc is consumed while something is active; e.g. an Esc meant for the presented app is intercepted] → Deliberately accepted. Esc is only taken while a marking is actually visible.
- [Thin or pale markings disappear in the video compression of conferencing apps] → Vivid colors and thick lines (see Decision 9). Fine-tuning after a real test call.
- [Window level `.screenSaver` sits above Mission Control, notifications and the like] → The overlay is transparent and click-through. If it gets in the way, go one level lower.
- [Sharing only a window does not show the overlay] → Platform limitation that cannot be solved. Documented in the spec.
- [Broken Xcode toolchain blocks the build] → Repair as task 0, before any code is written.

## Migration Plan

No migration needed (new app). Installation: the build script puts `Presenter.app` into `~/Applications`. Add it as a login item manually if needed. Removal: quit and delete the app, remove permissions in System Settings.

## Open Questions

- Exact colors, radii and animation durations are fine-tuned after a test call with real screen sharing. This only changes constants.
- **Test call result (2026-11-18):** carried out by the user. Click rings, halo, spotlight and rectangle highlight are clearly visible to the viewer.
