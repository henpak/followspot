# Proposal

## Why

Die App soll öffentlich auf GitHub erscheinen (`henpak/followspot`) und für andere einfach installierbar sein. Dafür passt einiges nicht mehr:

- Der Name „Presenter“ ist zu generisch.
- Die Oberfläche ist deutsch, das Publikum international.
- Bundle-ID (`local.presenter.app`), Standard-Signatur (persönliches „Apple Development“-Zertifikat) und README sind auf den Eigengebrauch zugeschnitten.
- Es gibt keine Releases, keinen Installer und keine CI.

## What Changes

- **BREAKING** Neuer Name **Followspot**: App-Bundle `Followspot.app`, Bundle-ID `io.github.henpak.followspot`, Swift-Targets `Followspot`/`FollowspotCore`.
- **BREAKING** Oberfläche komplett auf Englisch (Menü, Farb- und Stufennamen, Hinweise). Keine deutsche Lokalisierung.
- Einstellungen aus der alten Domain `local.presenter.app` werden beim ersten Start einmalig übernommen.
- Skripte: `package-app.sh` (Universal-Build, ad-hoc signiert, ZIP + SHA-256), `build-app.sh` (lokal bauen und installieren), `install.sh` (Einzeiler-Installation aus GitHub Releases, Deinstallation).
- GitHub Actions: CI (Build, Tests, Paket, shellcheck) und Release-Workflow bei Tags `v*`.
- Englische README, MIT-Lizenz, Changelog, Issue-Templates, Dependabot.
- `.claude/` und `.devin/` werden nicht mehr versioniert.

## Capabilities

### New Capabilities

Keine.

### Modified Capabilities

- `marking-colors`: englische Menütitel und Farbnamen; Farben werden aus „Presenter“ übernommen.
- `marking-appearance`: englische Menütitel und Stufennamen; Einstellungen werden aus „Presenter“ übernommen.
- `presenter-controls`: englische Menüeinträge, App-Name Followspot.

## Impact

- **Code:** alle Quell- und Testordner (Umbenennung), `StatusMenu.swift`, `PaletteColor.swift`, `AppearanceSettings.swift`, `HotkeyManager.swift`, `Log.swift`, App-Einstieg; neu `SettingsMigration.swift`
- **Build:** `Package.swift`, `Resources/Info.plist`, `scripts/`
- **Repo:** `.github/`, `README.md`, `LICENSE`, `CHANGELOG.md`, `.gitignore`
- **Nutzer:** eine vorhandene `Presenter.app` muss durch `Followspot.app` ersetzt werden; Einstellungen bleiben erhalten.
