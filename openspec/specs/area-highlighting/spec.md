# area-highlighting Specification

## Purpose

Lenkt die Aufmerksamkeit der Zuschauer auf einen bestimmten Bildschirmbereich, indem dieser hervorgehoben und der Rest abgedunkelt wird – entweder als aufgezogenes Rechteck oder als Spotlight um den Cursor.

## Requirements

### Requirement: Rechteck-Auswahl im Ein-Schuss-Modus
Nach Auslösen des Highlight-Hotkeys SHALL die App genau eine Rechteck-Auswahl per Maus-Ziehen ermöglichen und danach automatisch in den Normalbetrieb zurückkehren. Während der Auswahl MUST ein Fadenkreuz-Cursor angezeigt werden. Ein erneutes Drücken des Highlight-Hotkeys während der Auswahl MUST die Auswahl abbrechen.

#### Scenario: Rechteck aufziehen
- **WHEN** der Nutzer den Highlight-Hotkey drückt und ein Rechteck aufzieht
- **THEN** wird dieser Bereich hervorgehoben und Klicks erreichen danach wieder die Apps

#### Scenario: Auswahl abbrechen
- **WHEN** der Nutzer im Auswahlmodus den Highlight-Hotkey erneut drückt, bevor er ein Rechteck zieht
- **THEN** wird der Auswahlmodus ohne Highlight beendet

#### Scenario: Klick ohne Ziehen
- **WHEN** der Nutzer im Auswahlmodus nur klickt, ohne ein Rechteck aufzuziehen
- **THEN** entsteht kein Highlight und die App kehrt in den Normalbetrieb zurück

#### Scenario: Auswahl auf dem externen Monitor
- **WHEN** der Nutzer das Rechteck auf dem externen Monitor aufzieht
- **THEN** erscheint das Highlight auf dem externen Monitor

### Requirement: Darstellung des Rechteck-Highlights
Ein Rechteck-Highlight SHALL den Bereich außerhalb des Rechtecks auf dem betroffenen Bildschirm deutlich abdunkeln (ca. 40 %) und das Rechteck mit einem farbigen Rahmen versehen. Der Inhalt innerhalb des Rechtecks MUST unverändert sichtbar bleiben.

#### Scenario: Highlight sichtbar
- **WHEN** ein Rechteck-Highlight aktiv ist
- **THEN** ist der Bereich außerhalb abgedunkelt und der Bereich innerhalb unverändert hell mit Rahmen

### Requirement: Spotlight
Die App SHALL einen Spotlight-Modus bieten, der alle Bildschirme abdunkelt bis auf einen Kreis um den Mauszeiger, der dem Zeiger folgt. Der Spotlight-Modus MUST per Hotkey ein- und ausschaltbar sein und das Overlay dabei klick-durchlässig lassen.

#### Scenario: Spotlight einschalten
- **WHEN** der Nutzer den Spotlight-Hotkey drückt
- **THEN** wird alles außer einem Kreis um den Mauszeiger abgedunkelt

#### Scenario: Spotlight folgt der Maus
- **WHEN** der Spotlight aktiv ist und der Nutzer die Maus bewegt
- **THEN** bewegt sich der helle Kreis mit dem Zeiger

#### Scenario: Spotlight ausschalten
- **WHEN** der Spotlight aktiv ist und der Nutzer den Spotlight-Hotkey erneut drückt
- **THEN** wird die Abdunklung entfernt

### Requirement: Rechteck-Highlight per Klick oder Hotkey entfernen
Ein aktives Rechteck-Highlight SHALL beim nächsten normalen Maus-Klick oder beim erneuten Drücken des Highlight-Hotkeys verschwinden. Der entfernende Klick MUST trotzdem die darunterliegende App erreichen. Andere Funktionen (Halo, Spotlight, Klick-Ringe) MUST davon unberührt bleiben.

#### Scenario: Weiterklicken entfernt Highlight
- **WHEN** ein Highlight aktiv ist und der Nutzer irgendwo klickt
- **THEN** verschwindet das Highlight und der Klick wird von der App unter dem Mauszeiger verarbeitet

#### Scenario: Hotkey entfernt Highlight
- **WHEN** ein Highlight aktiv ist und der Nutzer den Highlight-Hotkey erneut drückt
- **THEN** verschwindet das Highlight, ohne dass eine neue Auswahl beginnt

#### Scenario: Neues Highlight nach dem Entfernen
- **WHEN** das Highlight per Hotkey entfernt wurde und der Nutzer den Highlight-Hotkey noch einmal drückt
- **THEN** beginnt eine neue Rechteck-Auswahl
