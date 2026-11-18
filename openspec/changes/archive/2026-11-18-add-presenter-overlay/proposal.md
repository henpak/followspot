# Proposal

## Why

When presenting with a shared screen (Zoom, Teams, Meet), viewers cannot see where the presenter clicks, and there is no simple way to highlight a specific area. Commercial tools such as Presentify solve this but cost money; a lean macOS app built for personal use covers the core that is needed.

## What Changes

- New native macOS menu bar app (Swift + AppKit), without a Dock icon, for personal use only (no distribution, no App Store).
- Transparent, click-through overlay on every connected display that is visible in the shared picture when the entire screen is shared.
- Click visualization: a short, fading ring at every click position, with different colors for left and right clicks.
- Cursor halo: a permanent circle around the mouse pointer, toggled by shortcut.
- Spotlight: the screen is dimmed except for a circle around the cursor, toggled by shortcut; the overlay stays click-through.
- One-shot rectangle highlight: press the shortcut, drag a rectangle, the rest is dimmed; then automatically back to normal mode. The highlight disappears with the next normal click or with Esc.
- Global shortcuts (`ctrl+opt` + letter) and Esc to remove all markings.
- Menu bar menu with toggles for the modes and “Quit”.
- Deliberately not included (later changes): freehand pen/arrows, keystroke display, zoom/magnifier, settings window, launch at login.

## Capabilities

### New Capabilities
- `screen-overlay`: transparent overlay layer above all displays: click-through, visibility when screen sharing, reacting to display changes.
- `click-visualization`: making mouse activity visible: click rings and cursor halo.
- `area-highlighting`: highlighting screen areas: one-shot rectangle highlight and spotlight.
- `presenter-controls`: operating the app: global shortcuts, Esc behavior and menu bar menu.

### Modified Capabilities
<!-- None: the project has no specs yet. -->

## Impact

- New Swift package with a build script that produces a signed app bundle; no external dependencies.
- Uses macOS system interfaces: window levels, global mouse event monitors, system-wide hotkey registration. The Accessibility permission may be required (checked first).
- Signing with a stable identity (free “Personal Team” certificate or a locally created one), so macOS permissions survive rebuilds.
- Prerequisite: a working Xcode toolchain on the development Mac (currently broken, must be repaired before implementation).
- Limitation: if only a single window is shared in the conferencing app instead of the entire screen, the overlay is not visible to viewers.
