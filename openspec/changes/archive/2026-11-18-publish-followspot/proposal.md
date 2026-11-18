# Proposal

## Why

The app is going to be published on GitHub (`henpak/followspot`) and should be easy for others to install. Several things no longer fit:

- The name “Presenter” is too generic.
- The UI and all documentation are in German, while the audience is international.
- The bundle ID (`local.presenter.app`), the default signing identity (a personal “Apple Development” certificate) and the README are tailored to personal use.
- There are no releases, no installer and no CI.

## What Changes

- **BREAKING** New name **Followspot**: app bundle `Followspot.app`, bundle ID `io.github.henpak.followspot`, Swift targets `Followspot`/`FollowspotCore`.
- **BREAKING** The UI is entirely in English (menu, color and level names, notices). No German localization.
- Settings from the old domain `local.presenter.app` are taken over once at first launch.
- Scripts: `package-app.sh` (universal build, ad-hoc signed, ZIP + SHA-256), `build-app.sh` (build and install locally), `install.sh` (one-line install from GitHub Releases, uninstall).
- GitHub Actions: CI (build, tests, packaging, shellcheck) and a release workflow for `v*` tags.
- English README, MIT license, changelog, issue templates, Dependabot.
- All specs and change documents in the repository are translated to English.
- `.claude/` and `.devin/` are no longer versioned.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `marking-colors`: English menu titles and color names; colors are taken over from “Presenter”.
- `marking-appearance`: English menu titles and level names; settings are taken over from “Presenter”.
- `presenter-controls`: English menu items, app name Followspot.

## Impact

- **Code:** all source and test folders (rename), `StatusMenu.swift`, `PaletteColor.swift`, `AppearanceSettings.swift`, `HotkeyManager.swift`, `Log.swift`, app entry point; new `SettingsMigration.swift`
- **Build:** `Package.swift`, `Resources/Info.plist`, `scripts/`
- **Repository:** `.github/`, `README.md`, `LICENSE`, `CHANGELOG.md`, `.gitignore`, `openspec/` (translation)
- **Users:** an existing `Presenter.app` is replaced by `Followspot.app`; settings are kept.
