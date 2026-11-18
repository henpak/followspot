# Tasks

## 1. Rename and English UI

- [x] 1.1 Rename targets and folders (`Followspot`, `FollowspotCore`, `FollowspotCoreTests`), `Package.swift`, imports, app entry point `FollowspotApp`. Verify: `swift build`.
- [x] 1.2 `Info.plist`: name, executable, bundle ID `io.github.henpak.followspot`, region `en`, version `1.0.0`. Hotkey signature `FLSP`, log subsystem from the bundle ID.
- [x] 1.3 English strings in `StatusMenu`, `PaletteColor`, `MarkingSize`, `DimLevel`; tests updated. Verify: `swift test`, no German UI text left in `Sources/`.
- [x] 1.4 `SettingsMigration` with tests (copy, no overwrite, only once, missing domain), called before the stores load (design.md Decision 4). Verify: `swift test`.

## 2. Scripts

- [x] 2.1 `scripts/package-app.sh` (universal, version, ad-hoc, ZIP + SHA-256); switch `scripts/build-app.sh` to it and remove an old `Presenter.app`. Verify: `lipo -archs`, `codesign -dv`, `plutil -p`.
- [x] 2.2 `scripts/install.sh` with checksum, `--uninstall` and an overridable source for testing. Verify: install from a local ZIP and uninstall.
- [ ] 2.3 `shellcheck scripts/*.sh` without findings (runs in CI).

## 3. Repository

- [x] 3.1 `.github/workflows/ci.yml`, `release.yml`, `dependabot.yml`, issue templates.
- [x] 3.2 English README, `LICENSE` (MIT), `CHANGELOG.md`, `.gitignore` with `.claude/` and `.devin/`.
- [x] 3.3 Translate all specs and change documents (including the archive) to English; no German left in the repository. Verify: `openspec validate --all`, search for German umlauts and common words.

## 4. Check

- [x] 4.1 `scripts/build-app.sh --open`: Followspot runs, the menu is in English, previous settings are taken over, `Presenter.app` is removed.
- [ ] 4.2 After publishing: CI green, release `v1.0.0` with `Followspot.zip` and `.sha256`, the one-line installer from the README installs the app.
