# Tasks

## 1. Umbenennen und englische Oberfläche

- [x] 1.1 Targets und Ordner umbenennen (`Followspot`, `FollowspotCore`, `FollowspotCoreTests`), `Package.swift`, Imports, App-Einstieg `FollowspotApp`. Verifizieren: `swift build`.
- [x] 1.2 `Info.plist`: Name, Executable, Bundle-ID `io.github.henpak.followspot`, Region `en`, Version `1.0.0`. Hotkey-Signatur `FLSP`, Log-Subsystem aus der Bundle-ID.
- [x] 1.3 Englische Texte in `StatusMenu`, `PaletteColor`, `MarkingSize`, `DimLevel`; Tests angepasst. Verifizieren: `swift test`, kein deutscher UI-Text mehr in `Sources/`.
- [x] 1.4 `SettingsMigration` mit Tests (Kopie, kein Überschreiben, nur einmal, fehlende Domain) und Aufruf vor dem Laden der Stores (design.md Decision 4). Verifizieren: `swift test`.

## 2. Skripte

- [x] 2.1 `scripts/package-app.sh` (Universal, Version, ad-hoc, ZIP + SHA-256) und `scripts/build-app.sh` darauf umstellen, alte `Presenter.app` entfernen. Verifizieren: `lipo -archs`, `codesign -dv`, `plutil -p`.
- [x] 2.2 `scripts/install.sh` mit Prüfsumme, `--uninstall` und überschreibbarer Quelle für Tests. Verifizieren: Installation aus lokaler ZIP und Deinstallation.
- [ ] 2.3 `shellcheck scripts/*.sh` ohne Befund.

## 3. Repository

- [x] 3.1 `.github/workflows/ci.yml`, `release.yml`, `dependabot.yml`, Issue-Templates.
- [x] 3.2 README auf Englisch, `LICENSE` (MIT), `CHANGELOG.md`, `.gitignore` um `.claude/` und `.devin/`.

## 4. Prüfen

- [x] 4.1 `scripts/build-app.sh --open`: Followspot läuft, das Menü ist englisch, die bisherigen Einstellungen sind übernommen, `Presenter.app` ist entfernt.
- [ ] 4.2 Nach dem Veröffentlichen: CI grün, Release `v1.0.0` mit `Followspot.zip` und `.sha256`, der Einzeiler aus der README installiert die App.
