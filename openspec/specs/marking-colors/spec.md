# marking-colors Specification

## Purpose

Ermöglicht es, die Farben der Markierungen direkt im Menüleisten-Menü aus einer festen, für Bildschirmfreigaben geeigneten Palette zu wählen, damit sie zum präsentierten Inhalt passen und gut erkennbar bleiben.

## Requirements

### Requirement: Farbpalette
Die App SHALL genau diese 8 Farben zur Auswahl anbieten: Orange, Gelb, Rot, Pink, Lila, Blau, Türkis, Grün. Jede Farbe MUST kräftig und voll deckend sein, damit sie in komprimierten Video-Streams erkennbar bleibt.

#### Scenario: Palette im Menü
- **WHEN** der Nutzer das Untermenü einer Farbeinstellung öffnet
- **THEN** werden die 8 Farben jeweils mit Farbpunkt und Namen angezeigt

### Requirement: Akzentfarbe
Die App SHALL eine einstellbare Akzentfarbe haben, die für Linksklick-Ring, Cursor-Halo, Rahmen des Rechteck-Highlights, Fadenkreuz und Auswahlrechteck verwendet wird. Halo und Auswahlrechteck verwenden die Akzentfarbe teiltransparent. Der Standardwert SHALL Orange sein.

#### Scenario: Standardfarbe beim ersten Start
- **WHEN** die App zum ersten Mal startet und der Nutzer links klickt
- **THEN** erscheint der Ring in Orange und ein Rechteck-Highlight hat einen orangen Rahmen

#### Scenario: Akzentfarbe ändern
- **WHEN** der Nutzer im Untermenü „Akzentfarbe“ Grün wählt und danach links klickt, das Halo einschaltet und ein Rechteck aufzieht
- **THEN** sind Ring, Halo, Fadenkreuz, Auswahlrechteck und Highlight-Rahmen grün

### Requirement: Rechtsklick-Farbe
Die App SHALL eine einstellbare Rechtsklick-Farbe haben, die für Rechtsklick-Ringe (inkl. ctrl+Klick) verwendet wird. Der Standardwert SHALL Blau sein.

#### Scenario: Rechtsklick-Farbe ändern
- **WHEN** der Nutzer im Untermenü „Rechtsklick-Farbe“ Pink wählt und rechts klickt
- **THEN** erscheint der Ring in Pink

### Requirement: Unterscheidbarkeit von Links- und Rechtsklick
Akzent- und Rechtsklick-Farbe MUST immer verschieden sein. Im Untermenü einer Farbeinstellung SHALL die aktuell für die jeweils andere Einstellung gewählte Farbe nicht auswählbar sein.

#### Scenario: Gleiche Farbe ist gesperrt
- **WHEN** die Akzentfarbe Orange ist und der Nutzer das Untermenü „Rechtsklick-Farbe“ öffnet
- **THEN** ist Orange dort deaktiviert und nicht wählbar

#### Scenario: Ungültige gespeicherte Kombination
- **WHEN** beim Start gespeicherte Werte vorliegen, bei denen beide Farben gleich sind
- **THEN** behält die App die Akzentfarbe und setzt die Rechtsklick-Farbe auf eine andere Farbe der Palette

### Requirement: Farbwahl im Menü
Das Menüleisten-Menü SHALL die Einträge „Akzentfarbe“ und „Rechtsklick-Farbe“ jeweils als Untermenü enthalten; die aktive Farbe MUST mit Häkchen markiert sein und das Haupt-Menü MUST die aktive Farbe am Eintrag erkennen lassen (Farbpunkt).

#### Scenario: Aktive Farbe erkennbar
- **WHEN** die Rechtsklick-Farbe Blau ist und der Nutzer das Menü öffnet
- **THEN** zeigt der Eintrag „Rechtsklick-Farbe“ einen blauen Farbpunkt und im Untermenü ist Blau mit Häkchen markiert

### Requirement: Sofortige Wirkung
Eine Farbänderung SHALL sofort wirken, ohne Neustart: auch auf gerade sichtbare Markierungen (Halo, Rechteck-Highlight). Bereits laufende Ring-Animationen laufen in der alten Farbe aus.

#### Scenario: Halo ist aktiv
- **WHEN** das Cursor-Halo eingeschaltet ist und der Nutzer die Akzentfarbe ändert
- **THEN** wechselt das Halo sofort in die neue Farbe

#### Scenario: Highlight ist aktiv
- **WHEN** ein Rechteck-Highlight sichtbar ist und der Nutzer über das Menü die Akzentfarbe ändert
- **THEN** wechselt der Rahmen in die neue Farbe und das Highlight bleibt bestehen

### Requirement: Farben bleiben gespeichert
Die gewählten Farben SHALL über Beenden und Neustart der App erhalten bleiben. Unbekannte oder fehlende gespeicherte Werte MUST auf die Standardfarben zurückfallen.

#### Scenario: Neustart
- **WHEN** der Nutzer die Akzentfarbe auf Türkis setzt, die App beendet und neu startet
- **THEN** ist die Akzentfarbe weiterhin Türkis

#### Scenario: Unbekannter gespeicherter Wert
- **WHEN** der gespeicherte Wert keiner Palettenfarbe entspricht
- **THEN** verwendet die App die Standardfarbe für diese Einstellung
