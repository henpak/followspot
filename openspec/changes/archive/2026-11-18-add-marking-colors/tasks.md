# Tasks

## 1. Palette und Regeln (PresenterCore)

- [x] 1.1 `PaletteColor` (8 Farben mit stabiler ID, deutschem Namen, sRGB-Werten laut design.md Decision 1) in `PresenterCore` anlegen; Unit-Tests prüfen Anzahl/Reihenfolge, eindeutige IDs und Namen; verifizieren: `swift test` grün
- [x] 1.2 `MarkingColors` mit Defaults (Orange/Blau), Fallback für unbekannte/fehlende IDs, Korrektur gleicher Farben (Akzent bleibt, Rechtsklick weicht aus – auch für Akzent = Blau), `setAccent`/`setRightClick` mit Ablehnung belegter Farben und `isSelectable` implementieren; Unit-Tests für alle Szenarien der Spec-Anforderungen „Unterscheidbarkeit“ und „Farben bleiben gespeichert“; verifizieren: `swift test` grün
- [x] 1.3 `ColorStore` (Laden/Speichern der Palette-IDs unter `accentColor`/`rightClickColor` in injizierbaren `UserDefaults`) implementieren; Unit-Tests mit eigener Defaults-Suite für Round-Trip, fehlende Schlüssel und unbekannte Werte; verifizieren: `swift test` grün

## 2. Darstellung

- [x] 2.1 Feste Markierungsfarben in `Style` durch von `PaletteColor` abgeleitete Farben ersetzen (Deckkraftwerte laut design.md Decision 5; `otherClickColor`, `dimColor`, `selectionCatcherColor` bleiben fest); verifizieren: `swift build` ohne Warnungen, keine Verwendung der alten Konstanten mehr (`grep`)
- [x] 2.2 `OverlayView.applyColors(_:)` implementieren (Halo, Highlight-Rahmen, Fadenkreuz, Auswahlrechteck ohne Animation umfärben; Ringfarben für neue Ringe merken) und über `OverlayManager.applyColors(_:)` an alle Panels verteilen, inkl. neu angelegter Panels in `rebuild()`; verifizieren: mit Default-Farben sieht alles wie bisher aus, außer dass Linksklick-Ring und Halo orange statt gelb sind
- [x] 2.3 `OverlayController` hält `colors` (beim Start aus `ColorStore` geladen), speichert und verteilt bei jeder Änderung; verifizieren: Akzentfarbe per Menü ändern → Halo und sichtbares Highlight wechseln sofort die Farbe, Highlight bleibt bestehen

## 3. Menü

- [x] 3.1 Farbpunkt-Bilder (ca. 12 pt, dünner Rand, abgeschwächte Variante für deaktiviert) erzeugen; verifizieren: Gelb ist im hellen und dunklen Menü erkennbar
- [x] 3.2 Untermenüs „Akzentfarbe“ und „Rechtsklick-Farbe“ in `StatusMenu` (Farbpunkt am Haupteintrag, 8 Einträge mit Farbpunkt + Name, Häkchen für aktive Farbe, belegte Farbe der anderen Einstellung deaktiviert) und an `OverlayController` anbinden; verifizieren: alle Szenarien der Spec-Anforderungen „Farbpalette“, „Farbwahl im Menü“ und „Unterscheidbarkeit“ manuell durchspielen
- [x] 3.3 README-Abschnitt „Bedienung“ um die Farbwahl ergänzen (zwei Einstellungen, was sie färben, Sperre gleicher Farben, Speicherung); verifizieren: README beschreibt die Menüeinträge so, wie sie erscheinen

## 4. Größen, Abdunklung und Hilfslinien: Logik (PresenterCore)

- [x] 4.1 `MarkingSize` (small/medium/large mit stabiler ID und Anzeigenamen Klein/Mittel/Groß) und `AppearanceSettings` (drei Größen + Hilfslinien-Schalter, Defaults Mittel/an, Fallback für unbekannte/fehlende Werte) laut design.md Decision 7 anlegen; Unit-Tests für Defaults, Fallbacks und Unabhängigkeit der drei Größen; verifizieren: `swift test` grün
- [x] 4.2 `AppearanceStore` (Schlüssel `clickRingSize`, `haloSize`, `spotlightSize`, `showsSelectionGuides`; fehlender Bool = an) implementieren; Unit-Tests mit eigener Defaults-Suite für Round-Trip, fehlende Schlüssel und unbekannte Werte; verifizieren: `swift test` grün
- [x] 4.3 `DimLevel` (light/medium/strong, Leicht/Mittel/Stark, Deckkraft 25/40/60 %) anlegen und `AppearanceSettings`/`AppearanceStore` um `highlightDimming`/`spotlightDimming` (Default Mittel, Schlüssel laut design.md Decision 8a) erweitern; Unit-Tests für Deckkraftwerte, Defaults, Fallbacks, Unabhängigkeit und Round-Trip; verifizieren: `swift test` grün

## 5. Größen, Abdunklung und Hilfslinien: Darstellung und Menü

- [x] 5.1 Maße je Stufe in `Style` (Tabelle design.md Decision 8, Mittel = bisherige Werte) und `OverlayView.applyAppearance(_:)` (Halo-Geometrie, Spotlight-Radius, Ring-Maße für neue Ringe, Füllfarben der beiden Dimm-Layer, Fadenkreuz nur bei an) über `OverlayManager.applyAppearance(_:)` inkl. neu angelegter Panels; `OverlayController` lädt, speichert und verteilt `appearance`; verifizieren: `swift build` ohne Warnungen, mit Defaults sind Ring, Halo und Spotlight so groß und Highlight/Spotlight so dunkel wie vorher
- [x] 5.2 Untermenüs „Größe Klick-Ring“, „Größe Halo“, „Größe Spotlight“ (Klein/Mittel/Groß), „Abdunklung Highlight“, „Abdunklung Spotlight“ (Leicht/Mittel/Stark), jeweils mit Häkchen, und Schalter „Hilfslinien beim Aufziehen“ in `StatusMenu` (Anordnung design.md Decision 10) und an `OverlayController` anbinden; verifizieren: alle Szenarien der Spec `marking-appearance` manuell durchspielen (u. a. Halo/Spotlight ändern sich sofort bei aktivem Modus, Hilfslinien aus → nur Auswahlrechteck sichtbar, Abdunklung bei sichtbarem Highlight ändern → sofort dunkler/heller, Highlight bleibt)
- [x] 5.3 README um Größen, Abdunklung und Hilfslinien ergänzen (Menüeinträge, Stufen, Standard, Speicherung, Reset-Schlüssel); verifizieren: README beschreibt die Menüeinträge so, wie sie erscheinen

## 6. Integration

- [x] 6.1 App per `scripts/build-app.sh --open` neu bauen und Ende-zu-Ende prüfen: Akzent und Rechtsklick ändern, Links-/Rechts-/ctrl+Klick auf beiden Monitoren, Halo, Fadenkreuz und Auswahlrechteck beim Aufziehen, Rechteck-Highlight in neuer Farbe; alle drei Größen in je zwei Stufen, beide Abdunklungen Leicht/Stark, Hilfslinien an/aus; App beenden und neu starten → Farben, Größen, Abdunklung und Hilfslinien-Schalter bleiben erhalten; verifizieren: alle Punkte vom Nutzer bestätigt
