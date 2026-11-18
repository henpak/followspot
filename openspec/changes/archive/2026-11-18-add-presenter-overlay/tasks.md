# Tasks

## 0. Prerequisites

- [x] 0.1 Repair the Xcode toolchain (open Xcode and install “Additional Components”, or update Xcode); verify: `swift --version` prints a version without errors
- [x] 0.2 Provide a stable signing identity (add an Apple ID as Personal Team in Xcode → Settings → Accounts and create an “Apple Development” certificate, otherwise a self-created code signing certificate); verify: `security find-identity -v -p codesigning` lists the identity

## 1. Project skeleton and build

- [x] 1.1 Create a Swift package with the executable target `Presenter` (macOS 15+) and a test target; the app starts as a pure menu bar app with an icon and “Quit”; verify: `swift build` succeeds
- [x] 1.2 Write a build script that produces a release build, assembles `Presenter.app` with `Info.plist` (`LSUIElement = true`), signs it with the configurable identity and copies it to `~/Applications`; verify: `codesign -dv ~/Applications/Presenter.app` shows the identity, the app starts without a Dock icon
- [x] 1.3 Create a README with prerequisites, build/install command and signing setup; verify: the documented command works as described

## 2. Spike: permissions and event access

- [x] 2.1 Spike: test a global mouse monitor (clicks, `mouseMoved`) and a Carbon hotkey registration without granted permissions and record the result in design.md (Decision 5/6); verify: the log shows click events from other apps, or a note on which permission is needed
- [x] 2.2 If needed (**dropped: spike showed no permission is needed, see design.md Decision 5**): implement a permission check and show a notice plus an “Open System Settings” item in the menu (spec presenter-controls: Notice about missing permissions); verify: with the permission revoked the notice appears and the item opens the right settings pane

## 3. Overlay layer (screen-overlay)

- [x] 3.1 Implement the global → display-local coordinate conversion as a pure function and cover it with unit tests for two displays (different arrangements, negative origins); verify: `swift test` green
- [x] 3.2 Create one transparent, click-through `NSPanel` per `NSScreen` (level `.screenSaver`, all Spaces, full-screen auxiliary); verify: a test marking appears on both displays, also above a full-screen app and after switching Spaces, and clicks reach the apps underneath
- [x] 3.3 Rebuild the panels when displays change; verify: disconnect and reconnect an external display while running, markings are positioned correctly afterwards, no crash

## 4. Central state and hotkeys (presenter-controls)

- [x] 4.1 Implement `OverlayController` with flags (click rings, halo, spotlight), mode (NORMAL/SELECTING) and highlight state as in design.md Decision 7, including the “Esc registered” condition; cover the state transitions with unit tests; verify: `swift test` green
- [x] 4.2 Register the global hotkeys `ctrl+opt+H/S/C` via Carbon and connect them to the controller; show a failed registration in the menu; verify: hotkeys work in another app without a focus change (log/menu state)
- [x] 4.3 Register/unregister Esc dynamically depending on the state; verify: without an active marking, e.g. a text editor dialog receives Esc normally; with an active marking, Esc removes it
- [x] 4.4 Complete the menu bar menu with toggles (check mark state) for click rings, halo, spotlight, the item “Highlight area”, the shortcuts shown, and “Quit” (removes all markings); verify: state changed by hotkey is marked correctly when the menu opens
- [x] 4.5 Document hotkeys and Esc behavior in the README; verify: the README table matches the menu

## 5. Click visualization (click-visualization)

- [x] 5.1 Click rings as animated `CAShapeLayer`s (left/right click distinguished by color, fade about 0.4 s) through the global mouse monitor; verify: left, right and ctrl-clicks on both displays show rings in the correct color at the exact position, rapid clicks create several rings
- [x] 5.2 Make click rings switchable in the menu; verify: after turning them off no rings appear
- [x] 5.3 Cursor halo that follows the pointer across both displays without implicit animation, off by default; verify: `ctrl+opt+C` toggles it, the halo follows the mouse smoothly, also when changing displays

## 6. Highlighting areas (area-highlighting)

- [x] 6.1 Dimming path calculation (display area minus rectangle or circle) and clamping the rectangle to the starting display as pure functions with unit tests; verify: `swift test` green
- [x] 6.2 Spotlight mode: dim all displays, cut out a circle around the cursor, the overlay stays click-through; verify: `ctrl+opt+S` toggles it, the circle follows the mouse, clicks reach the apps
- [x] 6.3 One-shot rectangle selection: panels accept the mouse (`acceptsFirstMouse`), crosshair cursor (fallback: drawn by the app), dragging draws a live rectangle, then back to NORMAL; a click without dragging and Esc cancel; verify: walk through all scenarios of the spec “One-shot rectangle selection” manually
- [x] 6.4 Highlight rendering (40 % dimming, border) and removal on the next global click, Esc or a new `ctrl+opt+H`; verify: a click after the highlight removes it **and** triggers in the app underneath

## 7. Integration

- [x] 7.1 Test call with full-screen sharing (e.g. Zoom/Teams/Meet, a second device as viewer): click rings, halo, spotlight and rectangle highlight are clearly visible to the viewer; fine-tune colors/sizes in the constants; verify: all four effects visible to the viewer, result noted in design.md (Open Questions)
- [x] 7.2 Document the known limitation (sharing a single window does not show the overlay) in the README; verify: a “Limitations” section exists

## Workflow follow-up

- After a successful implementation run `/opsx:verify` and then archive the change with `/opsx:archive`.
