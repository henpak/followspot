# Design

## Context

Bisher ist die App ein Eigenbau: Bundle-ID `local.presenter.app`, Signatur mit dem persönlichen „Apple Development“-Zertifikat, Installation nur über `scripts/build-app.sh`. Es gibt keine Apple-Developer-Mitgliedschaft, also auch keine Notarisierung. Die App braucht keine Berechtigungen (globale Maus-Monitore, Carbon-Hotkeys).

## Goals / Non-Goals

**Goals:**
- Installation für Fremde ohne Xcode: Einzeiler oder ZIP.
- Reproduzierbare Releases aus GitHub Actions.
- Keine persönlichen Daten oder lokalen Einstellungen im öffentlichen Repo.

**Non-Goals:**
- Homebrew-Cask, Notarisierung, Auto-Update, Lokalisierung.

## Decisions

### 1. Name Followspot, Bundle-ID unter `io.github.henpak`

Followspot ist der Verfolger-Scheinwerfer im Theater. Unter Mac-Cursor-Tools ist der Name frei, Limelight, Glint und ClickLight sind vergeben. Die Bundle-ID nutzt die GitHub-Domain des Kontos, weil es keine eigene Projekt-Domain gibt.

Die Capability `presenter-controls` behält ihren Namen. Sie beschreibt die Bedienung, nicht das Produkt.

### 2. Ad-hoc-Signatur

Ohne Developer-ID ist eine Ad-hoc-Signatur (`codesign -s -`) das Beste. Sie reicht für Apple Silicon. Weil die App keine TCC-Berechtigungen braucht, schadet es nicht, dass sich die Signatur mit jedem Build ändert. `FOLLOWSPOT_SIGN_IDENTITY` erlaubt weiterhin ein eigenes Zertifikat.

### 3. Installation per curl umgeht Gatekeeper legitim

Mit `curl` geladene Dateien bekommen kein `com.apple.quarantine`-Attribut, deshalb startet die App ohne Warnung. Der Installer prüft trotzdem die SHA-256-Prüfsumme aus dem Release und entfernt ein eventuell vorhandenes Attribut. Für den ZIP-Download aus dem Browser beschreibt die README „Open Anyway“ bzw. `xattr -dr com.apple.quarantine`.

Die Release-Assets heißen fest `Followspot.zip` und `Followspot.zip.sha256`. So funktioniert `releases/latest/download/…` ohne API-Aufruf.

### 4. Einmalige Übernahme der Einstellungen

`SettingsMigration` in `FollowspotCore` ist eine reine Funktion `migrate(legacy: [String: Any]?, into: UserDefaults)`:
- Sie kopiert die bekannten Schlüssel, die im Ziel fehlen.
- Danach setzt sie `migratedFromLegacyDomain`.
- Ist das Flag schon gesetzt, macht sie nichts.

Die App liest die alte Domain mit `UserDefaults.standard.persistentDomain(forName: "local.presenter.app")` und ruft die Migration in `main()` auf, bevor `AppDelegate` und `OverlayController` die Stores laden. Die alte Domain bleibt unangetastet, sie gilt als Backup.

### 5. Universal-Binary in Release und CI

`swift build -c release --arch arm64 --arch x86_64` erzeugt ein Universal-Binary unter `.build/apple/Products/Release`. Der Pfad kommt aus `--show-bin-path` mit denselben Argumenten.

## Risks / Trade-offs

- **Gatekeeper beim Browser-Download:** Nutzer müssen einmal „Open Anyway“ wählen. → Der Einzeiler ist in der README der empfohlene Weg.
- **Intel-Macs:** Ein ad-hoc signiertes x86_64-Binary läuft, wurde aber nur gebaut, nicht auf echter Hardware getestet. → In der README als „untested“ vermerkt.
- **Umbenennung:** Eine alte `Presenter.app` bliebe parallel installiert. → `build-app.sh` entfernt sie lokal. Für andere gibt es sie nicht, weil sie nie veröffentlicht wurde.

## Migration Plan

Neu bauen mit `scripts/build-app.sh --open`. Die Einstellungen werden übernommen, `Presenter.app` wird entfernt. Rollback: alte Historie aus dem Git-Bundle wiederherstellen.
