# Proposal

## Why

Bug-Report: Halo ist an, der Nutzer hebt einen Bereich hervor und drückt Esc. Das Highlight verschwindet wie erwartet, aber auch das Halo geht aus. Erwartet war, dass das Halo bleibt.

Ursache ist kein Programmierfehler, sondern die bisherige Festlegung: Esc entfernt „alle aktiven Markierungen“ und schaltet damit auch Halo und Spotlight ab (`add-presenter-overlay`, design.md Decision 7). Dazu kommt ein Nebeneffekt: Solange Halo oder Spotlight an sind, fängt Presenter Esc systemweit ab, und die präsentierte App (Keynote, Dialoge) bekommt es nicht.

Der Nutzer wünscht sich ein einheitliches Bedienprinzip: Jedes Kürzel schaltet seine Funktion ein, ein erneuter Druck schaltet sie wieder aus. Esc wird dafür nicht mehr gebraucht.

## What Changes

- **BREAKING** Esc wird von Presenter nicht mehr abgefangen, in keinem Zustand. Es erreicht immer die Vordergrund-App.
- `⌥F1` wird zum Umschalter:
  - nichts aktiv → Rechteck-Auswahl starten
  - Auswahl läuft → Auswahl abbrechen
  - Highlight sichtbar → Highlight entfernen (bisher: neue Auswahl starten, die das alte ersetzt)
- `⌥F2`, `⌥F3`, `⌥F4` bleiben unverändert Umschalter. Halo und Spotlight gehen nur noch über ihr eigenes Kürzel, das Menü oder „Beenden“ aus.
- Unverändert: Ein normaler Klick entfernt das Highlight; ein Klick ohne Ziehen bricht die Auswahl ab.
- Menü: Der Hinweis „Esc entfernt alle Markierungen“ entfällt. „Bereich hervorheben“ trägt ein Häkchen, solange Auswahl oder Highlight aktiv sind, und schaltet wie `⌥F1` um.
- README: Kürzeltabelle und Erläuterungen ohne Esc.

## Capabilities

### New Capabilities

Keine.

### Modified Capabilities

- `presenter-controls`: „Systemweite Hotkeys“ beschreibt `⌥F1` als Umschalter; „Esc entfernt Markierungen“ entfällt; „Menüleisten-Menü“ ohne Esc-Hinweis, mit Zustand für „Bereich hervorheben“.
- `area-highlighting`: Abbrechen der Auswahl und Entfernen des Highlights per `⌥F1` statt Esc; erneutes `⌥F1` bei sichtbarem Highlight entfernt es, statt ein neues zu starten.

## Impact

- **Code:**
  - `Sources/PresenterCore/OverlayState.swift`: `toggleSelection()`, `isHighlightActive`; `escape()`, `hasActiveMarkings`, `escapeShouldBeRegistered` entfallen
  - `Sources/Presenter/HotkeyManager.swift`: `HotkeyAction.escape` und die dynamische Esc-Registrierung entfallen
  - `Sources/Presenter/OverlayController.swift`, `Sources/Presenter/StatusMenu.swift`
- **Tests:** `OverlayStateTests` angepasst
- **Doku:** `README.md`
- Keine Änderung an gespeicherten Einstellungen, Berechtigungen oder Build.
