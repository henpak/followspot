# screen-overlay Specification

## Purpose

Stellt eine transparente Zeichenebene über allen Bildschirmen bereit, auf der Klick-Visualisierungen und Highlights erscheinen, ohne die Bedienung der darunterliegenden Apps zu stören.

## Requirements

### Requirement: Overlay auf allen Bildschirmen
Die App SHALL auf jedem angeschlossenen Bildschirm eine transparente Overlay-Ebene anzeigen, die über allen normalen App-Fenstern liegt, auch über Vollbild-Apps und in allen Spaces.

#### Scenario: Zwei Bildschirme angeschlossen
- **WHEN** die App läuft und zwei Bildschirme angeschlossen sind
- **THEN** können Markierungen auf beiden Bildschirmen angezeigt werden

#### Scenario: App im Vollbild
- **WHEN** eine andere App im Vollbildmodus läuft
- **THEN** erscheinen Markierungen weiterhin über dieser App

#### Scenario: Spaces wechseln
- **WHEN** der Nutzer in einen anderen Space wechselt
- **THEN** bleibt das Overlay dort verfügbar

### Requirement: Klick-Durchlässigkeit im Normalbetrieb
Außerhalb des Rechteck-Auswahlmodus SHALL das Overlay keine Maus- oder Tastatureingaben abfangen; alle Eingaben MUST die darunterliegenden Apps unverändert erreichen.

#### Scenario: Klick durch das Overlay
- **WHEN** der Nutzer im Normalbetrieb auf einen Button einer App klickt
- **THEN** löst der Button in der App wie gewohnt aus

#### Scenario: Klick bei aktivem Spotlight
- **WHEN** Spotlight oder Cursor-Halo aktiv ist und der Nutzer klickt
- **THEN** erreicht der Klick die darunterliegende App

### Requirement: Sichtbarkeit bei Bildschirmfreigabe
Das Overlay MUST bei der Freigabe des gesamten Bildschirms durch Konferenz-Apps im übertragenen Bild enthalten sein und darf sich nicht von der Bildschirmaufnahme ausschließen.

#### Scenario: Vollbild-Freigabe
- **WHEN** der Nutzer den ganzen Bildschirm in einer Konferenz-App teilt und klickt
- **THEN** sehen die Zuschauer den Klick-Ring

#### Scenario: Freigabe eines einzelnen Fensters
- **WHEN** der Nutzer nur ein einzelnes App-Fenster teilt
- **THEN** ist das Overlay für Zuschauer nicht sichtbar (bekannte, akzeptierte Einschränkung)

### Requirement: Reaktion auf Bildschirm-Änderungen
Die App SHALL das Overlay anpassen, wenn Bildschirme angeschlossen, getrennt oder in Auflösung bzw. Anordnung geändert werden, ohne Neustart der App.

#### Scenario: Externer Monitor wird angeschlossen
- **WHEN** während die App läuft ein externer Monitor angeschlossen wird
- **THEN** erscheinen Markierungen auch auf dem neuen Monitor an der korrekten Position

#### Scenario: Monitor wird getrennt
- **WHEN** ein Monitor getrennt wird
- **THEN** läuft die App ohne Fehler auf den verbleibenden Bildschirmen weiter
