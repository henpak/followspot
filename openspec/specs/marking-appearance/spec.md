# marking-appearance Specification

## Purpose

Ermöglicht es, die Größe von Klick-Ring, Cursor-Halo und Spotlight sowie die Abdunklungsstärke von Highlight und Spotlight in je drei Stufen anzupassen und die Hilfslinien bei der Rechteck-Auswahl ein- oder auszublenden, damit die Markierungen zu Monitorgröße und Präsentationsstil passen.

## Requirements

### Requirement: Größenstufen
Die App SHALL für Klick-Ring, Cursor-Halo und Spotlight jeweils eine eigene Größeneinstellung mit den Stufen Klein, Mittel und Groß anbieten. Die Stufe Mittel MUST der bisherigen Größe entsprechen und SHALL der Standardwert sein; Klein MUST sichtbar kleiner und Groß sichtbar größer sein.

#### Scenario: Standard beim ersten Start
- **WHEN** die App zum ersten Mal startet
- **THEN** sind Klick-Ring, Halo und Spotlight auf Mittel und so groß wie vor dieser Änderung

#### Scenario: Einstellungen sind unabhängig
- **WHEN** der Nutzer die Klick-Ring-Größe auf Klein und die Halo-Größe auf Groß stellt
- **THEN** erscheinen Klick-Ringe klein, das Halo groß und die Spotlight-Größe bleibt unverändert

### Requirement: Größe des Klick-Rings
Die gewählte Klick-Ring-Größe SHALL Start- und Endgröße sowie die Linienstärke des Rings bestimmen, für Links-, Rechts- und sonstige Klicks gleichermaßen. Sie SHALL für jeden nach der Änderung erscheinenden Ring gelten; bereits laufende Ring-Animationen laufen in der alten Größe aus.

#### Scenario: Großer Klick-Ring
- **WHEN** der Nutzer die Klick-Ring-Größe auf Groß stellt und danach klickt
- **THEN** erscheint ein deutlich größerer Ring mit dickerer Linie als bei Mittel

### Requirement: Größe von Halo und Spotlight
Die gewählte Halo-Größe SHALL den Radius des Cursor-Halos bestimmen, die gewählte Spotlight-Größe den Radius des hellen Kreises im Spotlight. Eine Änderung MUST sofort wirken, auch wenn Halo bzw. Spotlight gerade eingeschaltet sind.

#### Scenario: Halo-Größe bei aktivem Halo ändern
- **WHEN** das Halo eingeschaltet ist und der Nutzer die Halo-Größe auf Klein stellt
- **THEN** wird das Halo sofort kleiner und folgt weiter dem Mauszeiger

#### Scenario: Spotlight-Größe bei aktivem Spotlight ändern
- **WHEN** der Spotlight eingeschaltet ist und der Nutzer die Spotlight-Größe auf Groß stellt
- **THEN** wird der helle Kreis sofort größer

### Requirement: Abdunklungsstärke
Die App SHALL zwei getrennte Einstellungen für die Abdunklung anbieten – eine für das Rechteck-Highlight, eine für den Spotlight – jeweils mit den Stufen Leicht (25 %), Mittel (40 %) und Stark (60 %) Schwarz. Mittel SHALL der Standardwert sein. Der hervorgehobene Bereich bzw. der helle Kreis MUST unabhängig von der Stufe unverändert hell bleiben. Eine Änderung MUST sofort wirken, auch auf ein sichtbares Highlight bzw. einen aktiven Spotlight.

#### Scenario: Highlight stärker abdunkeln
- **WHEN** ein Rechteck-Highlight sichtbar ist und der Nutzer „Abdunklung Highlight“ auf Stark stellt
- **THEN** wird der Bereich außerhalb des Rechtecks sofort dunkler, das Rechteck selbst bleibt hell und das Highlight bleibt bestehen

#### Scenario: Einstellungen sind getrennt
- **WHEN** der Nutzer „Abdunklung Spotlight“ auf Leicht stellt und „Abdunklung Highlight“ auf Mittel lässt
- **THEN** dunkelt der Spotlight schwächer ab als ein Rechteck-Highlight

### Requirement: Hilfslinien bei der Rechteck-Auswahl
Die App SHALL einen Schalter „Hilfslinien beim Aufziehen“ anbieten, Standard an. Ist er an, MUST während der Rechteck-Auswahl ein Fadenkreuz aus Linien über den ganzen Bildschirm durch den Mauszeiger angezeigt werden; ist er aus, MUST dieses Fadenkreuz entfallen. Das Auswahlrechteck während des Ziehens und das fertige Highlight MUST in beiden Fällen angezeigt werden.

#### Scenario: Hilfslinien ausgeschaltet
- **WHEN** der Nutzer „Hilfslinien beim Aufziehen“ ausschaltet und die Rechteck-Auswahl startet
- **THEN** erscheinen keine Linien über den Bildschirm, beim Ziehen ist aber das gestrichelte Auswahlrechteck sichtbar

#### Scenario: Hilfslinien eingeschaltet
- **WHEN** der Schalter an ist und der Nutzer die Rechteck-Auswahl startet
- **THEN** laufen Fadenkreuz-Linien durch den Mauszeiger über den ganzen Bildschirm

### Requirement: Bedienung im Menü
Das Menüleisten-Menü SHALL je ein Untermenü „Größe Klick-Ring“, „Größe Halo“ und „Größe Spotlight“ mit den Einträgen Klein, Mittel, Groß sowie „Abdunklung Highlight“ und „Abdunklung Spotlight“ mit den Einträgen Leicht, Mittel, Stark enthalten, wobei die aktive Stufe mit Häkchen markiert ist, sowie den Schalter „Hilfslinien beim Aufziehen“ mit sichtbarem Ein/Aus-Zustand.

#### Scenario: Aktive Stufe erkennbar
- **WHEN** die Halo-Größe Groß ist und der Nutzer das Untermenü „Größe Halo“ öffnet
- **THEN** ist Groß mit Häkchen markiert

#### Scenario: Schalterzustand erkennbar
- **WHEN** die Hilfslinien ausgeschaltet sind und der Nutzer das Menü öffnet
- **THEN** ist „Hilfslinien beim Aufziehen“ ohne Häkchen

### Requirement: Einstellungen bleiben gespeichert
Größen, Abdunklungsstärken und Hilfslinien-Schalter SHALL über Beenden und Neustart der App erhalten bleiben. Fehlende oder unbekannte gespeicherte Werte MUST auf die Standardwerte (Mittel bzw. Hilfslinien an) zurückfallen.

#### Scenario: Neustart
- **WHEN** der Nutzer die Spotlight-Größe auf Klein stellt und die Hilfslinien ausschaltet, die App beendet und neu startet
- **THEN** ist die Spotlight-Größe weiterhin Klein und die Hilfslinien sind aus

#### Scenario: Unbekannter gespeicherter Wert
- **WHEN** für die Klick-Ring-Größe ein unbekannter Wert gespeichert ist
- **THEN** verwendet die App die Stufe Mittel
