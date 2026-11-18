# Spec Delta

## MODIFIED Requirements

### Requirement: Hilfslinien bei der Rechteck-Auswahl
Die App SHALL einen Schalter „Hilfslinien beim Aufziehen“ anbieten, Standard an. Ist er an, MUST während der Rechteck-Auswahl ein Fadenkreuz aus Linien über den ganzen Bildschirm durch den Mauszeiger angezeigt werden; ist er aus, MUST dieses Fadenkreuz entfallen. Das Auswahlrechteck während des Ziehens und das fertige Highlight MUST in beiden Fällen angezeigt werden.

#### Scenario: Hilfslinien ausgeschaltet
- **WHEN** der Nutzer „Hilfslinien beim Aufziehen“ ausschaltet und die Rechteck-Auswahl startet
- **THEN** erscheinen keine Linien über den Bildschirm, beim Ziehen ist aber das gestrichelte Auswahlrechteck sichtbar

#### Scenario: Hilfslinien eingeschaltet
- **WHEN** der Schalter an ist und der Nutzer die Rechteck-Auswahl startet
- **THEN** laufen Fadenkreuz-Linien durch den Mauszeiger über den ganzen Bildschirm
