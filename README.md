# Followspot

[![CI](https://github.com/henpak/followspot/actions/workflows/ci.yml/badge.svg)](https://github.com/henpak/followspot/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/henpak/followspot)](https://github.com/henpak/followspot/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![macOS 15+](https://img.shields.io/badge/macOS-15%2B-lightgrey)

**Point your audience at what matters when you share your screen.**

Followspot is a tiny macOS menu bar app for live demos, screen-shared calls and presentations.
It shows your clicks, highlights an area of the screen, puts a spotlight on the cursor and adds a
halo around the pointer, all with one-handed keyboard shortcuts and without leaving the app
you are presenting.

> A *followspot* is the theatre spotlight that follows the performer across the stage.

## Features

- **Click rings**: every click shows a short animated ring. Left and right clicks have different colors.
- **Highlight area**: drag a rectangle; everything else on that screen is dimmed until your next click.
- **Spotlight**: dims all screens except a circle that follows the cursor.
- **Cursor halo**: a colored ring that stays around the pointer.
- **Global shortcuts** `⌥F1`–`⌥F4` that work in any app and don't steal focus.
- **Customizable**: 8 colors, three sizes, three dimming levels, optional crosshair guides.
- **Multi-display**: works across all connected screens, including full-screen apps and Spaces.
- **No permissions needed**: no Accessibility or Input Monitoring access, no network, no telemetry.

## Requirements

- macOS 15 Sequoia or newer
- Apple Silicon or Intel Mac (universal binary; Intel builds are not tested on real hardware yet)

## Install

### One-line install (recommended)

```sh
curl -fsSL https://raw.githubusercontent.com/henpak/followspot/main/scripts/install.sh | bash
```

The script downloads the latest release, verifies its SHA-256 checksum, installs
`Followspot.app` into `~/Applications` and starts it. Run the same command again to update.
Read the [script](scripts/install.sh) first if you like. It is short.

### Manual download

1. Download `Followspot.zip` from the [latest release](https://github.com/henpak/followspot/releases/latest)
   and unzip it.
2. Move `Followspot.app` to `Applications` (or `~/Applications`).
3. Open it. Followspot is open source but not notarized by Apple, so macOS blocks the first
   launch of a downloaded copy. To allow it, choose one of:
   - **System Settings → Privacy & Security**, scroll down and click **Open Anyway** next to the
     Followspot message, then confirm.
   - Or run once in Terminal:
     ```sh
     xattr -dr com.apple.quarantine /Applications/Followspot.app
     ```

### Build from source

Requires Xcode 16 or newer (or the matching Swift toolchain).

```sh
git clone https://github.com/henpak/followspot.git
cd followspot
scripts/build-app.sh --open   # builds, installs to ~/Applications and starts the app
```

### Start at login

System Settings → General → Login Items → **+** → choose `Followspot.app`.

## Usage

Followspot lives in the menu bar (cursor icon). It has no Dock icon and no window.

| Shortcut | Action |
|---|---|
| `⌥F1` | **Highlight area** on/off: drag one rectangle, then normal clicking resumes. Press again to cancel the selection or remove the highlight. |
| `⌥F2` | **Spotlight** on/off |
| `⌥F3` | **Cursor halo** on/off |
| `⌥F4` | **Click rings** on/off |

- Every shortcut only toggles its own feature. Removing a highlight keeps halo, spotlight and click rings as they are.
- A highlight also disappears with your next normal click, and that click still reaches the app below.
  A click without dragging, or a right-click, cancels the selection.
- Followspot never captures `Esc`; it always reaches the app in front.
- The F-keys work without `fn` when **System Settings → Keyboard → Keyboard Shortcuts… → Function Keys →
  "Use F1, F2, etc. keys as standard function keys"** is on. Otherwise use `fn⌥F1` and so on.
- While Followspot runs, other apps don't receive `⌥F1`–`⌥F4` (for example "Select In" in
  JetBrains IDEs). If a shortcut is already taken by another app, the menu shows a warning.
- Click rings are on by default and start out on again after a relaunch.

### Settings

All settings are in the menu, take effect immediately (also on a visible halo or highlight) and
are remembered across launches.

| Menu item | Options | Default | Affects |
|---|---|---|---|
| **Accent Color** | Orange, Yellow, Red, Pink, Purple, Blue, Teal, Green | Orange | left-click ring, cursor halo, highlight border, crosshair and selection rectangle |
| **Right-Click Color** | same palette | Blue | right-click ring (including ctrl-click) |
| **Click Ring Size** | Small / Medium / Large | Medium | new click rings |
| **Halo Size** | Small / Medium / Large | Medium | cursor halo |
| **Spotlight Size** | Small / Medium / Large | Medium | bright circle of the spotlight |
| **Highlight Dimming** | Light 25 % / Medium 40 % / Strong 60 % | Medium | area outside the highlighted rectangle |
| **Spotlight Dimming** | Light 25 % / Medium 40 % / Strong 60 % | Medium | area outside the spotlight circle |
| **Crosshair While Selecting** | on / off | on | full-screen guide lines while dragging a rectangle |

Accent and right-click color are always different: the color used by one setting is disabled in
the other. To reset everything:

```sh
defaults delete io.github.henpak.followspot
```

## Permissions & privacy

None. Followspot observes mouse events through global event monitors, which cover mouse events
only and need no Accessibility or Input Monitoring permission. Shortcuts are registered as
system-wide hotkeys. Followspot makes no network connections. If macOS ever asks to grant
Followspot a permission, something is wrong. Please don't grant it, and open an issue instead.

## Limitations

- **Share your screen, not a window.** The markings are drawn in a transparent overlay window.
  Viewers see them when you share an entire screen in Zoom, Teams, Meet and similar apps.
  When you share only a single app window, the markings are **not** visible to viewers.
- A highlight rectangle stays on the screen where you started dragging.
- Only the levels in the menu are adjustable; exact sizes, line widths and animation timings are
  constants in [`Style.swift`](Sources/Followspot/Style.swift).

## Uninstall

```sh
curl -fsSL https://raw.githubusercontent.com/henpak/followspot/main/scripts/install.sh | bash -s -- --uninstall
```

Or quit Followspot from its menu and delete `Followspot.app`. Settings can be removed with
`defaults delete io.github.henpak.followspot`.

## Troubleshooting

Enable the event log (clicks, shortcuts, display changes), relaunch Followspot, reproduce the
problem, then read the log:

```sh
defaults write io.github.henpak.followspot debugLogging -bool true
/usr/bin/log show --last 10m --style compact --predicate 'subsystem == "io.github.henpak.followspot"'
defaults delete io.github.henpak.followspot debugLogging   # turn it off again
```

## Development

```sh
swift build                        # debug build
swift test                         # unit tests of the core logic (FollowspotCore)
swift run Followspot               # run without an app bundle
scripts/build-app.sh --open        # build, install to ~/Applications and launch
scripts/package-app.sh --universal --zip   # release bundle + zip in build/
```

- `Sources/FollowspotCore`: AppKit-free logic (state machine, geometry, settings), fully unit tested
- `Sources/Followspot`: the menu bar app (AppKit, Core Animation, Carbon hotkeys)
- `openspec/`: requirements and design decisions, written with [OpenSpec](https://github.com/Fission-AI/OpenSpec)
  (in German). `openspec/specs/` describes the current behavior, and `openspec/changes/archive/` records
  how and why it got there.

Releases are built by GitHub Actions: pushing a tag like `v1.2.3` runs the tests, builds a
universal, ad-hoc signed app and publishes `Followspot.zip` with its checksum.

## License

[MIT](LICENSE)
