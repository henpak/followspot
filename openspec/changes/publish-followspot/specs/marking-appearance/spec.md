# Spec Delta

## MODIFIED Requirements

### Requirement: Größenstufen
Die App SHALL für Klick-Ring, Cursor-Halo und Spotlight jeweils eine eigene Größeneinstellung mit den Stufen Small, Medium und Large anbieten. Die Stufe Medium MUST der bisherigen Größe entsprechen und SHALL der Standardwert sein; Small MUST sichtbar kleiner und Large sichtbar größer sein.

#### Scenario: Standard beim ersten Start
- **WHEN** die App zum ersten Mal startet
- **THEN** sind Klick-Ring, Halo und Spotlight auf Medium und so groß wie vor dieser Änderung

#### Scenario: Einstellungen sind unabhängig
- **WHEN** der Nutzer die Klick-Ring-Größe auf Small und die Halo-Größe auf Large stellt
- **THEN** erscheinen Klick-Ringe klein, das Halo groß und die Spotlight-Größe bleibt unverändert

### Requirement: Abdunklungsstärke
Die App SHALL zwei getrennte Einstellungen für die Abdunklung anbieten – eine für das Rechteck-Highlight, eine für den Spotlight – jeweils mit den Stufen Light (25 %), Medium (40 %) und Strong (60 %) Schwarz. Medium SHALL der Standardwert sein. Der hervorgehobene Bereich bzw. der helle Kreis MUST unabhängig von der Stufe unverändert hell bleiben. Eine Änderung MUST sofort wirken, auch auf ein sichtbares Highlight bzw. einen aktiven Spotlight.

#### Scenario: Highlight stärker abdunkeln
- **WHEN** ein Rechteck-Highlight sichtbar ist und der Nutzer „Highlight Dimming“ auf Strong stellt
- **THEN** wird der Bereich außerhalb des Rechtecks sofort dunkler, das Rechteck selbst bleibt hell und das Highlight bleibt bestehen

#### Scenario: Einstellungen sind getrennt
- **WHEN** der Nutzer „Spotlight Dimming“ auf Light stellt und „Highlight Dimming“ auf Medium lässt
- **THEN** dunkelt der Spotlight schwächer ab als ein Rechteck-Highlight

### Requirement: Hilfslinien bei der Rechteck-Auswahl
Die App SHALL einen Schalter „Crosshair While Selecting“ anbieten, Standard an. Ist er an, MUST während der Rechteck-Auswahl ein Fadenkreuz aus Linien über den ganzen Bildschirm durch den Mauszeiger angezeigt werden; ist er aus, MUST dieses Fadenkreuz entfallen. Das Auswahlrechteck während des Ziehens und das fertige Highlight MUST in beiden Fällen angezeigt werden.

#### Scenario: Hilfslinien ausgeschaltet
- **WHEN** der Nutzer „Crosshair While Selecting“ ausschaltet und die Rechteck-Auswahl startet
- **THEN** erscheinen keine Linien über den Bildschirm, beim Ziehen ist aber das gestrichelte Auswahlrechteck sichtbar

#### Scenario: Hilfslinien eingeschaltet
- **WHEN** der Schalter an ist und der Nutzer die Rechteck-Auswahl startet
- **THEN** laufen Fadenkreuz-Linien durch den Mauszeiger über den ganzen Bildschirm

### Requirement: Bedienung im Menü
Das Menüleisten-Menü SHALL je ein Untermenü „Click Ring Size“, „Halo Size“ und „Spotlight Size“ mit den Einträgen Small, Medium, Large sowie „Highlight Dimming“ und „Spotlight Dimming“ mit den Einträgen Light, Medium, Strong enthalten, wobei die aktive Stufe mit Häkchen markiert ist, sowie den Schalter „Crosshair While Selecting“ mit sichtbarem Ein/Aus-Zustand.

#### Scenario: Aktive Stufe erkennbar
- **WHEN** die Halo-Größe Large ist und der Nutzer das Untermenü „Halo Size“ öffnet
- **THEN** ist Large mit Häkchen markiert

#### Scenario: Schalterzustand erkennbar
- **WHEN** die Hilfslinien ausgeschaltet sind und der Nutzer das Menü öffnet
- **THEN** ist „Crosshair While Selecting“ ohne Häkchen

### Requirement: Einstellungen bleiben gespeichert
Größen, Abdunklungsstärken und Hilfslinien-Schalter SHALL über Beenden und Neustart der App erhalten bleiben. Fehlende oder unbekannte gespeicherte Werte MUST auf die Standardwerte (Medium bzw. Hilfslinien an) zurückfallen.

#### Scenario: Neustart
- **WHEN** der Nutzer die Spotlight-Größe auf Small stellt und die Hilfslinien ausschaltet, die App beendet und neu startet
- **THEN** ist die Spotlight-Größe weiterhin Small und die Hilfslinien sind aus

#### Scenario: Unbekannter gespeicherter Wert
- **WHEN** für die Klick-Ring-Größe ein unbekannter Wert gespeichert ist
- **THEN** verwendet die App die Stufe Medium

#### Scenario: Übernahme aus Presenter
- **WHEN** der Nutzer bisher die App unter dem Namen „Presenter“ genutzt hat und Followspot zum ersten Mal startet
- **THEN** gelten die bisher gewählten Größen, Abdunklungsstärken und der Hilfslinien-Schalter weiter
