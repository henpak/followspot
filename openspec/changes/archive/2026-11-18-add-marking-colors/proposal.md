# Proposal

## Why

Farben und Größen der Markierungen sind fest im Code. Je nach präsentierter Oberfläche (heller/dunkler Hintergrund, eigene Markenfarben, farbige Diagramme) und Monitorgröße sind die Markierungen schlecht erkennbar, zu dominant oder zu klein, und die Hilfslinien beim Aufziehen eines Rechtecks können ablenken. Schnelle Einstellungen direkt im Menüleisten-Menü beheben das ohne Neubau.

## What Changes

**Farben**
- Zwei im Menü einstellbare Farben:
  - **Akzentfarbe** – gilt für Linksklick-Ring, Cursor-Halo, Rahmen des Rechteck-Highlights sowie Fadenkreuz und Auswahlrechteck.
  - **Rechtsklick-Farbe** – gilt für den Rechtsklick-Ring.
- Auswahl je Farbe über ein Untermenü mit einer festen Palette aus 8 kräftigen, im Video-Stream gut erkennbaren Farben (Farbpunkt, Name, Häkchen bei der aktiven Farbe).
- Akzent- und Rechtsklick-Farbe können nicht gleich sein, damit Links- und Rechtsklick unterscheidbar bleiben.
- Standardwerte: Akzent **Orange**, Rechtsklick **Blau**. Bisher waren Linksklick-Ring und Halo gelb, der Highlight-Rahmen orange; künftig nutzen alle die Akzentfarbe (Annahme: ein einheitlicher Akzent ist gewollt, Default Orange).

**Größen und Hilfslinien** (nachträglich in diesen Change aufgenommen)
- Drei getrennt einstellbare Größen mit je den Stufen **Klein / Mittel / Groß**: Klick-Ring, Cursor-Halo, Spotlight. Standard ist jeweils **Mittel** = bisherige Größe.
- Zwei getrennt einstellbare **Abdunklungsstärken** mit den Stufen **Leicht / Mittel / Stark** (25 / 40 / 60 % Schwarz): für das Rechteck-Highlight und für den Spotlight. Standard ist jeweils **Mittel** = bisherige 40 %.
- Schalter **„Hilfslinien beim Aufziehen“** (Standard an): blendet die Fadenkreuz-Linien über den ganzen Bildschirm während der Rechteck-Auswahl ein oder aus. Das gestrichelte Auswahlrechteck bleibt immer sichtbar.

**Gemeinsam**
- Alle Einstellungen wirken sofort (auch auf gerade sichtbares Halo, Spotlight oder Highlight) und bleiben über App-Neustarts erhalten.
- Unverändert: Farbe der Abdunklung (Schwarz), die Farbe für Klicks mit weiteren Maustasten, Linienstärken von Halo und Highlight-Rahmen, Animationsdauer.
- Nicht enthalten: freie Farbwahl über den macOS-Farbwähler, separate Farben pro Element, stufenlose Größen oder Abdunklung, Deckkraft von Ringen/Halo einstellen, Größe des Highlight-Rahmens.

## Capabilities

### New Capabilities
- `marking-colors`: Einstellbare Farben der Markierungen – Palette, Zuordnung von Akzent- und Rechtsklick-Farbe zu den Markierungen, Auswahl im Menü, Unterscheidbarkeit und Speicherung.
- `marking-appearance`: Einstellbare Größen von Klick-Ring, Halo und Spotlight und Abdunklungsstärken von Highlight und Spotlight in je drei Stufen sowie Ein-/Ausblenden der Hilfslinien bei der Rechteck-Auswahl – Auswahl im Menü, sofortige Wirkung und Speicherung.

### Modified Capabilities
<!-- Keine. Die betroffenen Capabilities (click-visualization, area-highlighting, presenter-controls) stammen aus dem noch nicht archivierten Change add-presenter-overlay und legen keine konkreten Farben fest. Größen (Ring ca. 0,4 s, Spotlight-Kreis) und das Fadenkreuz sind dort nicht als feste Werte spezifiziert bzw. bleiben im Standard unverändert; deren Anforderungen bleiben gültig. -->

## Impact

- Baut auf dem Change `add-presenter-overlay` auf (implementiert, noch nicht archiviert); dessen Specs existieren noch nicht als Haupt-Specs, daher werden hier eigene Capabilities eingeführt statt Deltas zu bestehenden Specs.
- Code: `Sources/Presenter/Style.swift` (feste Farben und Größen werden zu abgeleiteten Werten), `OverlayView` (Farben/Größen/Hilfslinien zur Laufzeit neu anwenden), `OverlayManager`/`OverlayController` (Änderungen verteilen und speichern), `StatusMenu` (Untermenüs für Farben und Größen, Schalter für Hilfslinien), neue Einstellungslogik in `PresenterCore` mit Unit-Tests.
- Speicherung in den Benutzereinstellungen der App (`UserDefaults`, Domain `local.presenter.app`); keine neuen Abhängigkeiten, keine neuen Berechtigungen.
- README: Bedienungsabschnitt um Farben, Größen und Hilfslinien ergänzen.
