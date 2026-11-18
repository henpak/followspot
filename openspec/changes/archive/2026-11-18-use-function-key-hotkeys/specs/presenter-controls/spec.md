# Spec Delta

## MODIFIED Requirements

### Requirement: Systemweite Hotkeys
Die App SHALL folgende Tastenkürzel systemweit bereitstellen, unabhängig davon, welche App im Vordergrund ist: `opt+F1` startet die Rechteck-Auswahl, `opt+F2` schaltet Spotlight um, `opt+F3` schaltet das Cursor-Halo um, `opt+F4` schaltet die Klick-Ringe um. Die früheren Kürzel `ctrl+opt+H/S/C` MUST NOT mehr abgefangen werden.

#### Scenario: Hotkey in fremder App
- **WHEN** eine andere App im Vordergrund ist und der Nutzer `opt+F2` drückt
- **THEN** schaltet sich der Spotlight um, ohne dass die App den Fokus verliert

#### Scenario: Rechteck-Auswahl per Hotkey
- **WHEN** der Nutzer `opt+F1` drückt
- **THEN** beginnt die Rechteck-Auswahl

#### Scenario: Halo per Hotkey
- **WHEN** der Nutzer `opt+F3` drückt
- **THEN** schaltet sich das Cursor-Halo um

#### Scenario: Klick-Ringe per Hotkey
- **WHEN** die Klick-Ringe an sind und der Nutzer `opt+F4` drückt
- **THEN** erzeugen folgende Klicks keine Ringe mehr, und der Menüeintrag „Klick-Ringe“ ist ohne Häkchen

#### Scenario: Alte Kürzel frei
- **WHEN** die App läuft und der Nutzer in einer anderen App `ctrl+opt+S` drückt
- **THEN** reagiert Presenter nicht und die Vordergrund-App erhält den Tastendruck

#### Scenario: Hotkey bereits belegt
- **WHEN** ein Tastenkürzel beim Start nicht registriert werden kann
- **THEN** startet die App trotzdem und das Menü zeigt an, welches Kürzel nicht verfügbar ist
