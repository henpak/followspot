# Spec Delta

## Purpose

Definiert, wie der Nutzer die App während einer Präsentation bedient – über systemweite Tastenkürzel, die Esc-Taste und ein Menüleisten-Menü – ohne die präsentierte App verlassen zu müssen.

## ADDED Requirements

### Requirement: Systemweite Hotkeys
Die App SHALL folgende Tastenkürzel systemweit bereitstellen, unabhängig davon, welche App im Vordergrund ist: `ctrl+opt+H` startet die Rechteck-Auswahl, `ctrl+opt+S` schaltet Spotlight um, `ctrl+opt+C` schaltet das Cursor-Halo um.

#### Scenario: Hotkey in fremder App
- **WHEN** eine andere App im Vordergrund ist und der Nutzer `ctrl+opt+S` drückt
- **THEN** schaltet sich der Spotlight um, ohne dass die App den Fokus verliert

#### Scenario: Hotkey bereits belegt
- **WHEN** ein Tastenkürzel beim Start nicht registriert werden kann
- **THEN** startet die App trotzdem und das Menü zeigt an, welches Kürzel nicht verfügbar ist

### Requirement: Esc entfernt Markierungen
Wenn eine Markierung oder die Rechteck-Auswahl aktiv ist, SHALL Esc alle aktiven Markierungen entfernen bzw. die Auswahl abbrechen. Ist nichts davon aktiv, MUST Esc unverändert an die Vordergrund-App weitergereicht werden.

#### Scenario: Esc bei aktivem Highlight
- **WHEN** ein Rechteck-Highlight aktiv ist und der Nutzer Esc drückt
- **THEN** verschwindet das Highlight

#### Scenario: Esc ohne aktive Markierung
- **WHEN** keine Markierung aktiv ist und der Nutzer in einer App Esc drückt
- **THEN** erhält die App das Esc wie gewohnt

### Requirement: Menüleisten-Menü
Die App SHALL ausschließlich als Symbol in der Menüleiste erscheinen (kein Dock-Symbol, kein Fenster beim Start). Das Menü MUST Schalter für Klick-Ringe, Cursor-Halo und Spotlight mit sichtbarem Ein/Aus-Zustand, einen Eintrag zum Starten der Rechteck-Auswahl, die zugehörigen Tastenkürzel sowie „Beenden“ enthalten.

#### Scenario: App starten
- **WHEN** der Nutzer die App startet
- **THEN** erscheint nur ein Symbol in der Menüleiste und kein Dock-Symbol

#### Scenario: Zustand im Menü
- **WHEN** Spotlight per Hotkey eingeschaltet wurde und der Nutzer das Menü öffnet
- **THEN** ist der Spotlight-Eintrag als aktiv markiert

#### Scenario: Beenden
- **WHEN** der Nutzer im Menü „Beenden“ wählt
- **THEN** werden alle Markierungen entfernt und die App beendet sich

### Requirement: Hinweis auf fehlende Berechtigungen
Benötigt eine Funktion eine macOS-Berechtigung, die nicht erteilt ist, SHALL die App dies im Menü anzeigen und einen Weg zu den passenden Systemeinstellungen anbieten, statt still zu versagen.

#### Scenario: Berechtigung fehlt
- **WHEN** eine benötigte Berechtigung nicht erteilt ist
- **THEN** zeigt das Menü einen Hinweis mit Eintrag zum Öffnen der Systemeinstellungen
