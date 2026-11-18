# Tasks

## 1. Logik (PresenterCore)

- [x] 1.1 `OverlayState`: `toggleSelection()` und `isHighlightActive` ergänzen (design.md Decision 1); `escape()`, `hasActiveMarkings` und `escapeShouldBeRegistered` entfernen, `clearAll()` behält sein Verhalten. Verifizieren: `swift build`.
- [x] 1.2 `OverlayStateTests` anpassen: Esc-Tests entfernen; Tests für `toggleSelection()` (starten, abbrechen, Highlight entfernen, danach neu starten), dafür, dass Halo/Spotlight/Klick-Ringe beim Umschalten des Highlights unverändert bleiben, und für `clearAll()`. Verifizieren: `swift test` grün.

## 2. App

- [x] 2.1 `HotkeyManager`: `HotkeyAction.escape`, `setEscapeRegistered` und `isEscapeRegistered` entfernen (design.md Decision 2). Verifizieren: `swift build`.
- [x] 2.2 `OverlayController`: `⌥F1` ruft `toggleSelection()`; Esc-Registrierung in `stateDidChange()` entfällt; das Menü nutzt weiter `perform(.highlight)`. Verifizieren: `swift build`.
- [x] 2.3 `StatusMenu`: Hinweis „Esc entfernt alle Markierungen“ entfernen; „Bereich hervorheben“ mit Häkchen bei `isHighlightActive`, Aktion schaltet um (design.md Decision 3). Verifizieren: `swift build`.
- [x] 2.4 README: Esc aus Kürzeltabelle und Erläuterungen entfernen, `⌥F1` als Umschalter beschreiben. Verifizieren: README erwähnt Esc nur noch mit dem Hinweis, dass Presenter es nicht abfängt.

## 3. Prüfen in der laufenden App

- [x] 3.1 Mit `scripts/build-app.sh --open` bauen und installieren, `swift test` grün.
- [x] 3.2 Manuell: Halo an → `⌥F1` → Rechteck aufziehen → `⌥F1`: Highlight weg, Halo bleibt. Gleiches mit Spotlight. Esc in einer App (z. B. Safari-Suchfeld) wirkt dort normal, auch während Halo, Spotlight, Auswahl oder Highlight aktiv sind. `⌥F1` während der Auswahl bricht ab. Menüeintrag „Bereich hervorheben“ zeigt Häkchen bei sichtbarem Highlight.
