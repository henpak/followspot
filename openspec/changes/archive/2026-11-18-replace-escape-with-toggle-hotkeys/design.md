# Design

## Context

Bisher (`add-presenter-overlay`, Decision 6/7) wird Esc dynamisch als Carbon-Hotkey registriert, solange Auswahl, Highlight, Spotlight oder Halo aktiv sind, und `OverlayState.escape()` setzt dann alles außer den Klick-Ringen zurück. `⌥F1` startet immer eine neue Auswahl; ein sichtbares Highlight wird dabei ersetzt.

## Goals / Non-Goals

**Goals:**
- Jede Funktion wird ausschließlich über ihr eigenes Kürzel (oder den Menüeintrag) ein- und ausgeschaltet.
- Esc gehört immer der Vordergrund-App.

**Non-Goals:**
- Ein „alles aus“-Kürzel. „Beenden“ räumt weiterhin alles ab.
- Änderungen an Klick-Verhalten (Klick entfernt Highlight, Klick ohne Ziehen bricht ab).

## Decisions

### 1. `⌥F1` schaltet zwischen „aus“ und „Highlight-Funktion aktiv“ um

„Aktiv“ heißt: Auswahl läuft **oder** Highlight sichtbar (`OverlayState.isHighlightActive`). `toggleSelection()`:

```
isHighlightActive == false  →  beginSelection()
mode == .selecting          →  cancelSelection()
highlight != nil            →  highlight = nil
```

Wer ein sichtbares Highlight durch ein neues ersetzen will, drückt `⌥F1` zweimal oder klickt einmal und drückt dann `⌥F1`.

Verworfen: `⌥F1` bei sichtbarem Highlight startet weiterhin eine neue Auswahl. Das widerspräche dem gewünschten Prinzip „erneut drücken = aus“.

### 2. Esc-Hotkey komplett entfernen

`HotkeyAction.escape` (Rohwert 4), `setEscapeRegistered`, `isEscapeRegistered`, `escapeShouldBeRegistered` und `hasActiveMarkings` entfallen. Der Rohwert 4 wird nicht neu vergeben; `clickRings` behält 5.

### 3. Menüeintrag „Bereich hervorheben“ mit Zustand

Der Eintrag bekommt ein Häkchen bei `isHighlightActive` und ruft dieselbe Umschaltung auf wie `⌥F1`. So verhält er sich wie die anderen drei Schalter.

## Risks / Trade-offs

- **Gewohnheit Esc:** Wer Esc drückt, um eine Auswahl abzubrechen, bewegt jetzt nichts mehr; Esc geht an die App. → Ein Klick ohne Ziehen bricht weiterhin ab; `⌥F1` ebenso. README und Menü nennen kein Esc mehr.
- **Zwei Drücke für ein neues Highlight:** Bewusst akzeptiert zugunsten eines einheitlichen Prinzips. Meist wird ohnehin zwischendurch geklickt, was das alte Highlight entfernt.

## Migration Plan

Neu bauen mit `scripts/build-app.sh --open`. Keine gespeicherten Daten betroffen.
