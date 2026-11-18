# Proposal

## Why

Die aktuellen Kürzel `⌃⌥H/S/C` brauchen zwei Modifier und sind mit einer Hand schlecht zu greifen. Bei einer Präsentation liegt die andere Hand meist auf Maus oder Trackpad. Gebraucht wird eine Belegung mit nur einem Modifier, die weder mit macOS noch mit gängigen Apps kollidiert und kein Zeichen beim Tippen blockiert.

Mögliche Alternativen und warum sie ausscheiden:

- `⌃F1–F8` sind macOS-Tastaturnavigation.
- `⌃1–3` wechseln den Schreibtisch und sind in Xcode belegt.
- `⌘1–3` sind in fast jeder App belegt.
- `⌥1–3` tippen `¡ “ ¶`.
- `⌃`+Buchstabe sind Text-Bindings und im Terminal belegt.

`⌥F1–F3` hat keinen dieser Nachteile.

## What Changes

- **BREAKING** Neue Belegung der systemweiten Kürzel. Die alten `⌃⌥H/S/C` entfallen ersatzlos:
  - `⌥F1` (statt `⌃⌥H`): Bereich hervorheben, also Rechteck-Auswahl starten
  - `⌥F2` (statt `⌃⌥S`): Spotlight an/aus
  - `⌥F3` (statt `⌃⌥C`): Cursor-Halo an/aus
  - `⌥F4` (**neu**): Klick-Ringe an/aus. Bisher ging das nur über das Menü, während einer Präsentation also nicht ohne Griff zur Menüleiste.
- Die Reihenfolge F1 → F3 folgt der Häufigkeit: das Highlight ist am häufigsten und liegt auf der Taste, die am leichtesten zu treffen ist.
- Esc bleibt unverändert: es wird nur abgefangen, solange etwas aktiv ist.
- Das Menüleisten-Menü zeigt die neuen Kürzel an den Einträgen an. Die Warnung „Kürzel … nicht verfügbar“ nennt ebenfalls die neue Bezeichnung.
- Die Bedienungstabelle im README wird angepasst.
- Die Kürzel bleiben fest im Code verdrahtet. Eine frei konfigurierbare Belegung ist nicht Teil dieses Changes.

## Capabilities

### New Capabilities

Keine.

### Modified Capabilities

- `presenter-controls`: In der Anforderung „Systemweite Hotkeys“ ändern sich die Tastenkürzel von `ctrl+opt+H/S/C` auf `opt+F1/F2/F3`. Neu hinzu kommt `opt+F4`, um die Klick-Ringe umzuschalten. Die Capability wird von `add-presenter-overlay` eingeführt.
- `marking-appearance`: Die Szenarien der Anforderung „Hilfslinien bei der Rechteck-Auswahl“ nennen bisher `ctrl+opt+H`. Sie werden kürzelneutral formuliert („startet die Rechteck-Auswahl“). Die Capability wird von `add-marking-colors` eingeführt.

## Impact

- **Code:**
  - `Sources/Presenter/HotkeyManager.swift`: `keyCode`, `carbonModifiers`, `menuKey` und `displayShortcut` in `HotkeyAction`, dazu die neue Aktion für die Klick-Ringe
  - `Sources/Presenter/OverlayController.swift`: die neue Aktion ausführen
  - `Sources/Presenter/StatusMenu.swift`: Modifier-Maske der Menüeinträge, Darstellung von F-Tasten als Key-Equivalent
- **Doku:** `README.md` (Kürzeltabelle sowie die Erwähnungen von `⌃⌥H` im Fließtext)
- **Keine Änderung** an PresenterCore, Tests, Berechtigungen, gespeicherten Einstellungen oder dem Build.
- **Abhängigkeit:** Die geänderten Capabilities existieren erst in den noch nicht archivierten Changes `add-presenter-overlay` und `add-marking-colors`. Deshalb müssen diese beiden vor diesem Change archiviert werden.
