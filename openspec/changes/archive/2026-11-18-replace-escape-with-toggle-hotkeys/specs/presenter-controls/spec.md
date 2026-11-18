# Spec Delta

## MODIFIED Requirements

### Requirement: Systemweite Hotkeys
Die App SHALL folgende Tastenkürzel systemweit bereitstellen, unabhängig davon, welche App im Vordergrund ist: `opt+F1` schaltet die Rechteck-Highlight-Funktion um (Auswahl starten bzw. laufende Auswahl abbrechen oder sichtbares Highlight entfernen), `opt+F2` schaltet Spotlight um, `opt+F3` schaltet das Cursor-Halo um, `opt+F4` schaltet die Klick-Ringe um. Jedes Kürzel MUST nur seine eigene Funktion beeinflussen. Die früheren Kürzel `ctrl+opt+H/S/C` MUST NOT mehr abgefangen werden.

#### Scenario: Hotkey in fremder App
- **WHEN** eine andere App im Vordergrund ist und der Nutzer `opt+F2` drückt
- **THEN** schaltet sich der Spotlight um, ohne dass die App den Fokus verliert

#### Scenario: Rechteck-Auswahl per Hotkey
- **WHEN** weder Auswahl noch Highlight aktiv sind und der Nutzer `opt+F1` drückt
- **THEN** beginnt die Rechteck-Auswahl

#### Scenario: Halo per Hotkey
- **WHEN** der Nutzer `opt+F3` drückt
- **THEN** schaltet sich das Cursor-Halo um

#### Scenario: Halo bleibt beim Entfernen des Highlights
- **WHEN** das Cursor-Halo an ist, ein Rechteck-Highlight sichtbar ist und der Nutzer `opt+F1` drückt
- **THEN** verschwindet das Highlight und das Halo bleibt an

#### Scenario: Klick-Ringe per Hotkey
- **WHEN** die Klick-Ringe an sind und der Nutzer `opt+F4` drückt
- **THEN** erzeugen folgende Klicks keine Ringe mehr, und der Menüeintrag „Klick-Ringe“ ist ohne Häkchen

#### Scenario: Alte Kürzel frei
- **WHEN** die App läuft und der Nutzer in einer anderen App `ctrl+opt+S` drückt
- **THEN** reagiert Presenter nicht und die Vordergrund-App erhält den Tastendruck

#### Scenario: Esc bleibt bei der App
- **WHEN** Halo, Spotlight, eine Auswahl oder ein Highlight aktiv ist und der Nutzer Esc drückt
- **THEN** reagiert Presenter nicht, alle Funktionen bleiben unverändert und die Vordergrund-App erhält das Esc

#### Scenario: Hotkey bereits belegt
- **WHEN** ein Tastenkürzel beim Start nicht registriert werden kann
- **THEN** startet die App trotzdem und das Menü zeigt an, welches Kürzel nicht verfügbar ist

### Requirement: Menüleisten-Menü
Die App SHALL ausschließlich als Symbol in der Menüleiste erscheinen (kein Dock-Symbol, kein Fenster beim Start). Das Menü MUST Schalter für Klick-Ringe, Cursor-Halo, Spotlight und „Bereich hervorheben“ mit sichtbarem Ein/Aus-Zustand, die zugehörigen Tastenkürzel sowie „Beenden“ enthalten. „Bereich hervorheben“ MUST als aktiv markiert sein, solange eine Auswahl läuft oder ein Highlight sichtbar ist, und MUST beim Auswählen wie `opt+F1` umschalten.

#### Scenario: App starten
- **WHEN** der Nutzer die App startet
- **THEN** erscheint nur ein Symbol in der Menüleiste und kein Dock-Symbol

#### Scenario: Zustand im Menü
- **WHEN** Spotlight per Hotkey eingeschaltet wurde und der Nutzer das Menü öffnet
- **THEN** ist der Spotlight-Eintrag als aktiv markiert

#### Scenario: Highlight-Zustand im Menü
- **WHEN** ein Rechteck-Highlight sichtbar ist und der Nutzer das Menü öffnet
- **THEN** ist „Bereich hervorheben“ als aktiv markiert

#### Scenario: Beenden
- **WHEN** der Nutzer im Menü „Beenden“ wählt
- **THEN** werden alle Markierungen entfernt und die App beendet sich

## REMOVED Requirements

### Requirement: Esc entfernt Markierungen
**Reason**: Esc hat Halo und Spotlight mit abgeschaltet, obwohl nur das Highlight weg sollte, und war währenddessen für die präsentierte App blockiert. Jede Funktion wird jetzt nur über ihr eigenes Kürzel umgeschaltet.
**Migration**: Highlight bzw. Auswahl mit `opt+F1` (oder einem Klick) beenden, Spotlight mit `opt+F2`, Halo mit `opt+F3`.
