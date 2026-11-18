# Design

## Context

Siehe proposal.md – Why. Ist-Stand (aus `add-presenter-overlay`): Alle Farben sind `static let`-Konstanten in `Sources/Presenter/Style.swift`. `OverlayView` setzt Halo-, Rahmen-, Fadenkreuz- und Auswahlfarben einmalig in `setUpLayers()` und liest die Klickfarben in `showRing(at:kind:)`. Laufzeitzustand fließt über `OverlayController` → `OverlayManager.apply(_:)` → `OverlayView.apply(_:displayID:)`. Das Menü (`StatusMenu`) wird bei jedem Öffnen neu aufgebaut (`menuNeedsUpdate`). Es gibt noch keine persistierten Einstellungen.

## Goals / Non-Goals

**Goals:**
- Farb-, Größen- und Hilfslinien-Einstellungen ohne Neubau, sofort wirksam auf alle Bildschirme.
- Palette, Größenstufen und Regeln (Defaults, Unterscheidbarkeit, Fallbacks) als reine, getestete Logik in `PresenterCore`.
- Spätere Erweiterung (z. B. eigene Farbe per Farbwähler) ohne Umbau möglich.

**Non-Goals:**
- Einstellungsfenster; die Farbwahl bleibt im Menü.
- Live-Vorschau beim Überfahren der Menüeinträge.
- Farbe für Klicks mit weiteren Maustasten, Abdunklungsfarbe oder Deckkraft einstellbar machen.
- Stufenlose Größen, Größe des Highlight-Rahmens, Linienstärke von Halo/Fadenkreuz.

## Decisions

### 1. Palette als Enum in `PresenterCore`
`PaletteColor: String, CaseIterable` mit stabilen IDs als Rohwert (`orange`, `yellow`, `red`, `pink`, `purple`, `blue`, `teal`, `green`), deutschem Anzeigenamen und sRGB-Werten:

| ID | Name | sRGB |
|---|---|---|
| orange | Orange | 1.00 / 0.60 / 0.00 |
| yellow | Gelb | 1.00 / 0.80 / 0.00 |
| red | Rot | 1.00 / 0.23 / 0.19 |
| pink | Pink | 1.00 / 0.18 / 0.57 |
| purple | Lila | 0.69 / 0.32 / 0.87 |
| blue | Blau | 0.18 / 0.55 / 1.00 |
| teal | Türkis | 0.00 / 0.78 / 0.80 |
| green | Grün | 0.20 / 0.80 / 0.35 |

Die IDs werden gespeichert, nicht die Namen oder RGB-Werte. Dadurch können Namen und Farbtöne später nachjustiert werden, ohne dass gespeicherte Werte ungültig werden.
- *Alternative: RGB speichern:* Das würde zwar beliebige Farben erlauben, aber Validierung und Unterscheidbarkeit werden unscharf (ab wann sind zwei Farben „gleich“?). Verworfen, freie Farben sind Non-Goal.

### 2. `MarkingColors` als eigener Wert, getrennt von `OverlayState`
Struct `MarkingColors { accent, rightClick }` mit:
- `init(accentID: String?, rightClickID: String?)`: Unbekannte oder fehlende Werte werden zum Default (Orange/Blau). Sind beide Farben gleich, bleibt der Akzent erhalten, und Rechtsklick wird Blau. Ist der Akzent selbst Blau, wird Rechtsklick die erste andere Palettenfarbe (Orange).
- `mutating func setAccent(_:) -> Bool` / `setRightClick(_:) -> Bool`: Die Methoden lehnen eine Farbe ab, wenn die andere Einstellung sie bereits nutzt.
- `func isSelectable(_ color:, forAccent:) -> Bool` für die Menülogik.

Die Farben gehören nicht in `OverlayState`. `OverlayState` beschreibt den flüchtigen Sitzungszustand (Modus, Markierungen, Esc-Logik), die Farben sind dauerhafte Einstellungen. Getrennt bleiben die bestehenden Zustandstests unberührt, und Esc bzw. `clearAll()` müssen Farben nicht berücksichtigen.

### 3. Speicherung über `ColorStore` mit injizierbaren `UserDefaults`
`ColorStore` in `PresenterCore` liest und schreibt die Schlüssel `accentColor` und `rightClickColor` (Palette-IDs) in einer übergebenen `UserDefaults`-Instanz. Die App nutzt `.standard` (Domain `local.presenter.app`), die Tests nutzen eine eigene Suite. Gespeichert wird bei jeder Änderung, ein „Speichern“-Schritt existiert nicht.

### 4. Laufzeitverteilung: eigener Pfad `applyColors`
`OverlayController` hält `colors: MarkingColors`. Bei jeder Änderung (`didSet`) speichert er die Farben und ruft `OverlayManager.applyColors(_:)` auf. Das reicht die Farben an jede `OverlayView.applyColors(_:)` weiter, und die View setzt dort ohne implizite Animation die Farben von Halo, Highlight-Rahmen, Fadenkreuz und Auswahlrechteck neu. Die View merkt sich die Farben für neue Klick-Ringe. Neu angelegte Panels (Monitor angesteckt) bekommen die aktuellen Farben in `rebuild()`.
- *Alternative: Farben über `apply(_ state:)` mitschicken:* Die Farben würden dann bei jeder Mausbewegung oder Zustandsänderung neu gesetzt. Verworfen, siehe Decision 2.

### 5. Abgeleitete Farbtöne in `Style`
`Style` behält Größen und Dauern als Konstanten. Die festen Farben `leftClickColor`, `rightClickColor`, `haloFill`, `haloStroke`, `accent`, `crosshairColor` und `selectionFill` werden zu Funktionen der gewählten Palettenfarbe, mit den bisherigen Deckkraftwerten: Halo-Füllung 28 %, Halo-Rand 75 %, Fadenkreuz 80 %, Auswahlfüllung 8 %, Ring-Füllung 18 %. `otherClickColor`, `dimColor` und `selectionCatcherColor` bleiben fest.

### 6. Menü: zwei Untermenüs mit Farbpunkten
`StatusMenu` bekommt nach den Funktionsschaltern die Einträge „Akzentfarbe“ und „Rechtsklick-Farbe“. Jeder Eintrag zeigt als Bild einen Farbpunkt der aktiven Farbe und hat ein Untermenü mit 8 Einträgen (Farbpunkt plus Name). Die aktive Farbe trägt ein Häkchen (`state = .on`). Die von der anderen Einstellung belegte Farbe ist `isEnabled = false`, ihr Farbpunkt wird abgeschwächt gezeichnet (35 % Deckkraft), weil Nicht-Template-Bilder nicht automatisch ausgegraut werden. Die Farbpunkte sind ca. 12 pt große, per `NSImage(size:flipped:drawingHandler:)` gezeichnete Kreise mit dünnem, halbtransparentem Rand, damit Gelb auch auf hellem Menü-Hintergrund erkennbar ist. Den Menü-Eintrag selbst anzuklicken gilt nicht als globaler Klick (eigene App), ein sichtbares Highlight bleibt also bestehen.

### 7. Größenstufen und Erscheinungs-Einstellungen in `PresenterCore`
`MarkingSize: String, CaseIterable` (`small`, `medium`, `large`; Anzeigenamen Klein/Mittel/Groß) und Struct `AppearanceSettings { clickRingSize, haloSize, spotlightSize, showsSelectionGuides }` mit Defaults Mittel/Mittel/Mittel/an. `AppearanceStore` liest und schreibt diese Werte wie `ColorStore` in injizierbare `UserDefaults`. Schlüssel: `clickRingSize`, `haloSize`, `spotlightSize` (IDs), `showsSelectionGuides` (Bool). Fehlt der Bool-Schlüssel, gilt `true` (`object(forKey:) == nil`-Prüfung, weil `bool(forKey:)` sonst `false` liefert). Die Werte liegen getrennt von `MarkingColors`, weil zwischen Farben und Größen keine Regel besteht.
- *Alternative: alles in einem `Settings`-Struct:* Weniger Typen, aber die bereits getesteten Farbregeln müssten umgebaut werden. Verworfen.

### 8. Konkrete Maße je Stufe in `Style`
Die Pixelwerte sind Darstellung und gehören in die App, nicht in `PresenterCore`. „Mittel“ entspricht exakt den bisherigen Konstanten:

| | Klein | Mittel | Groß |
|---|---|---|---|
| Klick-Ring Start-/Endradius | 12 / 20 pt | 18 / 30 pt | 26 / 44 pt |
| Klick-Ring Linienstärke | 3 pt | 4 pt | 5 pt |
| Halo-Radius | 20 pt | 28 pt | 40 pt |
| Spotlight-Radius | 80 pt | 120 pt | 180 pt |

Die Stufen sind etwa Faktor 1,4–1,5 auseinander und damit im Video-Stream klar unterscheidbar.

### 8a. Abdunklungsstufen
`DimLevel: String, CaseIterable` (`light`, `medium`, `strong`; Anzeigenamen Leicht/Mittel/Stark) mit der Deckkraft als Wert im Core (25 / 40 / 60 %). Anders als die Pixelmaße ist die Deckkraft Teil der Spec und wird deshalb im Core getestet. `AppearanceSettings` bekommt `highlightDimming` und `spotlightDimming` (Default Mittel). Gespeichert wird unter den Schlüsseln `highlightDimming` und `spotlightDimming`. In `OverlayView` erhalten `highlightDimLayer` und `spotlightLayer` je eine eigene `fillColor` (Schwarz mit der jeweiligen Deckkraft). `Style.dimColor` wird zu `Style.dimColor(_ level:)`. Den Wert 60 % als Obergrenze habe ich gewählt, damit der Inhalt außerhalb im Video noch erkennbar bleibt.

### 9. Laufzeitverteilung analog zu den Farben
`OverlayController` hält `appearance: AppearanceSettings` (beim Start geladen). `didSet` speichert und ruft `OverlayManager.applyAppearance(_:)` auf, das auch an später angelegte Panels geht. `OverlayView.applyAppearance(_:)` setzt `bounds`/`path` des Halo-Layers und die Füllfarben der beiden Dimm-Layer neu, merkt sich den Spotlight-Radius sowie Ring-Maße und Hilfslinien-Schalter und ruft `refreshCursorDependent()` auf. So ändern sich ein aktives Halo, ein aktiver Spotlight, ein sichtbares Highlight und ein sichtbares Fadenkreuz sofort. Das Fadenkreuz wird nur gezeichnet, wenn `isSelecting && showsSelectionGuides`. Das Auswahlrechteck ist davon unabhängig, der System-Cursor bleibt ein Fadenkreuz-Cursor.

### 10. Menü-Anordnung
Nach den Farb-Untermenüs folgen, durch einen Trenner abgesetzt, die Untermenüs „Größe Klick-Ring“, „Größe Halo“ und „Größe Spotlight“ (je Klein/Mittel/Groß mit Häkchen), dann „Abdunklung Highlight“ und „Abdunklung Spotlight“ (je Leicht/Mittel/Stark mit Häkchen) und der Schalter „Hilfslinien beim Aufziehen“ (Häkchen = an). Die Menülogik nutzt denselben Aufbau-bei-Öffnen-Mechanismus wie die Farben.

## Risks / Trade-offs

- [Großer Spotlight auf kleinem Display bzw. großes Halo verdeckt viel] → Gewollt einstellbar, Default bleibt Mittel.
- [Das Menü wird deutlich länger (5 Untermenüs + Schalter)] → Gruppiert durch Trenner. Ein Einstellungsfenster bleibt Non-Goal, solange das Menü überschaubar ist.
- [Einheitlicher Akzent ändert das bisherige Aussehen: Der Linksklick-Ring wird von Gelb zu Orange] → Bewusst so gewollt (Proposal). Wer Gelb bevorzugt, stellt es im Menü ein.
- [Einige Palettenfarben sind auf bestimmten Inhalten schlecht sichtbar, z. B. Gelb auf Weiß] → Das ist der Sinn der Auswahl. Der Rand der Ringe ist kräftig, die Füllung leicht transparent.
- [Rot/Grün sind für Menschen mit Rot-Grün-Schwäche schwer zu unterscheiden] → Die Defaults Orange/Blau sind gut unterscheidbar. Die Wahl liegt beim Nutzer.
- [Die Sperre gleicher Farben könnte verwirren („warum ist Orange grau?“)] → Der deaktivierte Eintrag ist klar ausgegraut. Bei Bedarf später ein Tooltip.

## Migration Plan

Keine Datenmigration: Fehlen die Schlüssel (erster Start nach dem Update), gelten die Defaults Orange/Blau, alle Größen Mittel und Hilfslinien an. Rückbau: Die Schlüssel bleiben ungenutzt in den Defaults liegen und lassen sich mit `defaults delete local.presenter.app <Schlüssel>` entfernen (`accentColor`, `rightClickColor`, `clickRingSize`, `haloSize`, `spotlightSize`, `highlightDimming`, `spotlightDimming`, `showsSelectionGuides`).
