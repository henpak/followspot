# Spec Delta

## Purpose

Macht Mausaktivität für Zuschauer einer Bildschirmfreigabe sichtbar, damit sie jederzeit erkennen, wo sich der Mauszeiger befindet und wo geklickt wird.

## ADDED Requirements

### Requirement: Klick-Ring
Bei jedem Maus-Klick in einer beliebigen App SHALL an der Klickposition ein Ring erscheinen, der innerhalb von etwa 0,4 Sekunden verblasst. Die Klick-Ringe SHALL beim App-Start aktiv sein.

#### Scenario: Linksklick
- **WHEN** der Nutzer irgendwo auf dem Bildschirm links klickt
- **THEN** erscheint an genau dieser Position ein Ring und verblasst danach

#### Scenario: Klick auf dem zweiten Bildschirm
- **WHEN** der Nutzer auf dem externen Monitor klickt
- **THEN** erscheint der Ring auf dem externen Monitor an der Klickposition

#### Scenario: Schnelle Klickfolge
- **WHEN** der Nutzer mehrfach schnell hintereinander klickt
- **THEN** erscheint für jeden Klick ein eigener Ring

### Requirement: Unterscheidung von Links- und Rechtsklick
Klick-Ringe für Links- und Rechtsklick MUST sich farblich deutlich unterscheiden.

#### Scenario: Rechtsklick
- **WHEN** der Nutzer rechts klickt (inkl. ctrl+Klick bzw. Zwei-Finger-Tipp)
- **THEN** erscheint ein Ring in der Rechtsklick-Farbe statt der Linksklick-Farbe

### Requirement: Klick-Ringe ein- und ausschalten
Der Nutzer SHALL die Klick-Ringe über das Menüleisten-Menü ein- und ausschalten können.

#### Scenario: Klick-Ringe deaktiviert
- **WHEN** der Nutzer die Klick-Ringe im Menü ausschaltet und danach klickt
- **THEN** erscheint kein Ring

### Requirement: Cursor-Halo
Die App SHALL einen dauerhaft sichtbaren, halbtransparenten Kreis um den Mauszeiger anzeigen können, der dem Zeiger ohne merkliche Verzögerung folgt, auch über Bildschirmgrenzen hinweg. Das Halo SHALL beim App-Start ausgeschaltet sein.

#### Scenario: Halo einschalten
- **WHEN** der Nutzer das Cursor-Halo per Hotkey oder Menü einschaltet und die Maus bewegt
- **THEN** folgt ein Kreis dem Mauszeiger

#### Scenario: Wechsel des Bildschirms
- **WHEN** der Nutzer mit aktivem Halo die Maus auf den anderen Bildschirm bewegt
- **THEN** wird das Halo auf dem anderen Bildschirm um den Zeiger angezeigt

#### Scenario: Halo ausschalten
- **WHEN** der Nutzer das Halo erneut umschaltet
- **THEN** verschwindet der Kreis
