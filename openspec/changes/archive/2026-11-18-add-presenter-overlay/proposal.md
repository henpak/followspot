# Proposal

## Why

Beim Präsentieren mit geteiltem Bildschirm (Zoom, Teams, Meet) sehen Zuschauer nicht, wo geklickt wird, und es gibt keine einfache Möglichkeit, einen Bereich gezielt hervorzuheben. Kommerzielle Tools wie Presentify lösen das, kosten aber Geld; eine schlanke, eigene macOS-App für den persönlichen Gebrauch deckt den benötigten Kern ab.

## What Changes

- Neue native macOS-Menüleisten-App (Swift + AppKit), ohne Dock-Icon, nur für den persönlichen Gebrauch (keine Verteilung, kein App Store).
- Transparentes, klick-durchlässiges Overlay auf jedem angeschlossenen Bildschirm, das bei Vollbild-Freigabe im geteilten Bild sichtbar ist.
- Klick-Visualisierung: kurzer, verblassender Ring an jeder Klickposition, Links- und Rechtsklick farblich unterschieden.
- Cursor-Halo: dauerhafter Kreis um den Mauszeiger, per Hotkey ein-/ausschaltbar.
- Spotlight: Bildschirm abgedunkelt bis auf einen Kreis um den Cursor, per Hotkey ein-/ausschaltbar, Overlay bleibt dabei klick-durchlässig.
- Rechteck-Highlight im Ein-Schuss-Modus: Hotkey drücken, ein Rechteck aufziehen, Rest wird abgedunkelt; danach automatisch zurück in den Normalmodus. Das Highlight verschwindet beim nächsten normalen Klick oder per Esc.
- Globale Hotkeys (`ctrl+opt` + Buchstabe) und Esc zum Entfernen aller Markierungen.
- Menüleisten-Menü mit Schaltern für die Modi und „Beenden“.
- Bewusst nicht enthalten (spätere Changes): Freihand-Stift/Pfeile, Tastatur-Anzeige, Zoom/Lupe, Einstellungsfenster, Start bei Anmeldung.

## Capabilities

### New Capabilities
- `screen-overlay`: Transparente Overlay-Ebene über allen Bildschirmen – Klick-Durchlässigkeit, Sichtbarkeit bei Bildschirmfreigabe, Reaktion auf Bildschirm-Änderungen.
- `click-visualization`: Sichtbarmachen von Mausaktivität – Klick-Ringe und Cursor-Halo.
- `area-highlighting`: Hervorheben von Bildschirmbereichen – Rechteck-Highlight (Ein-Schuss) und Spotlight.
- `presenter-controls`: Bedienung der App – globale Hotkeys, Esc-Verhalten und Menüleisten-Menü.

### Modified Capabilities
<!-- Keine – das Projekt hat noch keine Specs. -->

## Impact

- Neues Swift Package mit Build-Skript, das ein signiertes App-Bundle erzeugt; keine externen Abhängigkeiten.
- Nutzt macOS-Systemschnittstellen: Fenster-Ebenen, globale Maus-Event-Monitore, systemweite Hotkey-Registrierung. Möglicherweise wird die Freigabe „Bedienungshilfen“ benötigt (wird zu Beginn geprüft).
- Signierung mit stabiler Identität (kostenloses „Personal Team“-Zertifikat oder lokal selbst erstellt), damit macOS-Berechtigungen über Builds hinweg erhalten bleiben.
- Voraussetzung: funktionierende Xcode-Toolchain auf dem Entwicklungs-Mac (aktuell defekt, muss vor der Umsetzung repariert werden).
- Einschränkung: Teilt man in der Konferenz-App nur ein einzelnes Fenster statt des ganzen Bildschirms, ist das Overlay für Zuschauer nicht sichtbar.
