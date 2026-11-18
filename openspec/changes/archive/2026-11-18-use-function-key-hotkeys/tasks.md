# Tasks

## 1. Neue Belegung

- [x] 1.1 In `HotkeyAction` (`Sources/Presenter/HotkeyManager.swift`) die Belegung umstellen:
  - `keyCode` auf `kVK_F1`/`kVK_F2`/`kVK_F3`
  - `carbonModifiers` auf `optionKey`; Esc bleibt ohne Modifier
  - `menuKey` auf die `NSF1FunctionKey`-Codepoints
  - `displayShortcut` auf `⌥F1`/`⌥F2`/`⌥F3`
  - neue Eigenschaft `menuModifiers` (design.md, Decisions 1–3)

  Verifizieren: `swift build` läuft ohne Fehler.
- [x] 1.2 `StatusMenu.addItem` nimmt die Modifier-Maske aus `hotkey.menuModifiers` statt aus dem festen `[.control, .option]`. Verifizieren: `swift build`. Das Menü zeigt `⌥F1` an „Bereich hervorheben“, `⌥F2` an „Spotlight“ und `⌥F3` an „Cursor-Halo“.
- [x] 1.3 README anpassen: Kürzeltabelle, die Erwähnungen von `⌃⌥H` im Fließtext („neues Rechteck“, Tabelle „Hilfslinien“) und ein Hinweis zur fn-Einstellung (design.md, Risks). Verifizieren: `grep -n "⌃⌥" README.md` findet nichts mehr.

- [x] 1.4 Neue `HotkeyAction` für die Klick-Ringe anlegen:
  - Rohwert 5, `⌥F4`
  - in `standard` aufnehmen
  - `OverlayController.perform` schaltet damit die Klick-Ringe um
  - der Menüeintrag „Klick-Ringe“ zeigt `⌥F4`
  - README-Tabelle ergänzen

  Verifizieren: `swift build`, im Log keine Registrierungsfehler.

## 2. Prüfen in der laufenden App

- [x] 2.1 Mit `scripts/build-app.sh --open` bauen und installieren, dann `swift test` ausführen (66 Tests bleiben grün). Prüfen, dass das Menü keinen Hinweis „Kürzel … nicht verfügbar“ zeigt.
- [x] 2.2 Manuell in einer fremden App, z. B. Safari im Vordergrund:
  - `⌥F1` startet die Rechteck-Auswahl.
  - `⌥F2` schaltet den Spotlight um.
  - `⌥F3` schaltet das Halo um.
  - `⌥F4` schaltet die Klick-Ringe ab und wieder an.
  - Esc entfernt alles.
  - Die Vordergrund-App verliert dabei nicht den Fokus.
- [x] 2.3 Manuell: `⌃⌥S` in einer fremden App löst in Presenter nichts mehr aus (Spec-Szenario „Alte Kürzel frei“).

## Workflow follow-up

- Vor dem Archivieren dieses Changes zuerst `add-presenter-overlay` und `add-marking-colors` archivieren (design.md, Migration Plan).
