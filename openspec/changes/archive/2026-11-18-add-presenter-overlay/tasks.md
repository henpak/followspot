# Tasks

## 0. Voraussetzungen

- [x] 0.1 Xcode-Toolchain reparieren (Xcode öffnen und „Additional Components“ installieren bzw. Xcode aktualisieren); verifizieren: `swift --version` gibt eine Version ohne Fehler aus
- [x] 0.2 Stabile Signatur-Identität bereitstellen (Apple ID als Personal Team in Xcode → Settings → Accounts hinzufügen und „Apple Development“-Zertifikat erzeugen, sonst selbst erstelltes Code-Signing-Zertifikat); verifizieren: `security find-identity -v -p codesigning` listet die Identität

## 1. Projektgerüst und Build

- [x] 1.1 Swift Package mit Executable-Target `Presenter` (macOS 15+) und Test-Target anlegen, App startet als reine Menüleisten-App mit Symbol und „Beenden“; verifizieren: `swift build` erfolgreich
- [x] 1.2 Build-Skript schreiben, das Release-Build erzeugt, `Presenter.app` mit `Info.plist` (`LSUIElement = true`) zusammensetzt, mit der konfigurierbaren Identität signiert und nach `~/Applications` kopiert; verifizieren: `codesign -dv ~/Applications/Presenter.app` zeigt die Identität, App startet ohne Dock-Symbol
- [x] 1.3 README mit Voraussetzungen, Build-/Installationsbefehl und Signatur-Einrichtung anlegen; verifizieren: der dokumentierte Befehl läuft wie beschrieben

## 2. Spike: Berechtigungen und Event-Zugriff

- [x] 2.1 Spike: globalen Maus-Monitor (Klicks, `mouseMoved`) und eine Carbon-Hotkey-Registrierung ohne erteilte Berechtigungen testen und Ergebnis in design.md (Decision 5/6) festhalten; verifizieren: Log zeigt Klick-Events aus fremden Apps bzw. Notiz, welche Berechtigung nötig ist
- [x] 2.2 Falls nötig (**entfällt – Spike: keine Berechtigung nötig, siehe design.md Decision 5**): Berechtigungsprüfung implementieren und im Menü Hinweis + Eintrag „Systemeinstellungen öffnen“ anzeigen (Spec presenter-controls: Hinweis auf fehlende Berechtigungen); verifizieren: bei entzogener Berechtigung erscheint der Hinweis, der Eintrag öffnet den richtigen Einstellungsbereich

## 3. Overlay-Ebene (screen-overlay)

- [x] 3.1 Koordinaten-Umrechnung global → bildschirmlokal als reine Funktion implementieren und mit Unit-Tests für zwei Bildschirme (unterschiedliche Anordnung, negative Ursprünge) absichern; verifizieren: `swift test` grün
- [x] 3.2 Pro `NSScreen` ein transparentes, klick-durchlässiges `NSPanel` (Ebene `.screenSaver`, alle Spaces, Vollbild-Begleiter) anlegen; verifizieren: Test-Markierung erscheint auf beiden Bildschirmen, auch über einer Vollbild-App und nach Space-Wechsel, Klicks erreichen darunterliegende Apps
- [x] 3.3 Panels bei Bildschirm-Änderungen neu aufbauen; verifizieren: externen Monitor im laufenden Betrieb trennen und wieder anschließen, Markierungen erscheinen danach korrekt positioniert, kein Absturz

## 4. Zentraler Zustand und Hotkeys (presenter-controls)

- [x] 4.1 `OverlayController` mit Flags (Klick-Ringe, Halo, Spotlight), Modus (NORMAL/SELECTING) und Highlight-Zustand gemäß design.md Decision 7 implementieren, inkl. der Bedingung „Esc registriert“; Zustandsübergänge per Unit-Tests abdecken; verifizieren: `swift test` grün
- [x] 4.2 Globale Hotkeys `ctrl+opt+H/S/C` per Carbon registrieren und an den Controller anbinden; fehlgeschlagene Registrierung im Menü anzeigen; verifizieren: Hotkeys wirken in fremder App ohne Fokuswechsel (Log/Menüzustand)
- [x] 4.3 Esc dynamisch registrieren/abmelden je nach Zustand; verifizieren: ohne aktive Markierung erhält z. B. ein Texteditor-Dialog Esc normal, mit aktiver Markierung entfernt Esc die Markierung
- [x] 4.4 Menüleisten-Menü mit Schaltern (Häkchen-Zustand) für Klick-Ringe, Halo, Spotlight, Eintrag „Bereich hervorheben“, angezeigten Kürzeln und „Beenden“ (entfernt alle Markierungen) vervollständigen; verifizieren: per Hotkey geänderter Zustand ist beim Öffnen des Menüs korrekt markiert
- [x] 4.5 Hotkeys und Esc-Verhalten im README dokumentieren; verifizieren: README-Tabelle stimmt mit Menü überein

## 5. Klick-Visualisierung (click-visualization)

- [x] 5.1 Klick-Ringe als animierte `CAShapeLayer` (Links-/Rechtsklick farblich unterschieden, Fade ca. 0,4 s) über den globalen Maus-Monitor; verifizieren: Links-, Rechts- und ctrl+Klick auf beiden Bildschirmen zeigen Ringe in korrekter Farbe an exakter Position, schnelle Klickfolge erzeugt mehrere Ringe
- [x] 5.2 Klick-Ringe über Menü abschaltbar machen; verifizieren: nach Abschalten erscheinen keine Ringe mehr
- [x] 5.3 Cursor-Halo, das dem Zeiger ohne implizite Animation über beide Bildschirme folgt, standardmäßig aus; verifizieren: `ctrl+opt+C` schaltet um, Halo folgt der Maus flüssig auch beim Bildschirmwechsel

## 6. Bereiche hervorheben (area-highlighting)

- [x] 6.1 Dimm-Pfad-Berechnung (Bildschirmfläche minus Rechteck bzw. Kreis) und Begrenzung des Rechtecks auf den Start-Bildschirm als reine Funktionen mit Unit-Tests; verifizieren: `swift test` grün
- [x] 6.2 Spotlight-Modus: alle Bildschirme abdunkeln, Kreis um Cursor aussparen, Overlay bleibt klick-durchlässig; verifizieren: `ctrl+opt+S` schaltet um, Kreis folgt der Maus, Klicks erreichen Apps
- [x] 6.3 Ein-Schuss-Rechteckauswahl: Panels nehmen Maus an (`acceptsFirstMouse`), Fadenkreuz-Cursor (Fallback: selbst gezeichnet), Drag zeichnet Live-Rechteck, danach zurück in NORMAL; Klick ohne Drag und Esc brechen ab; verifizieren: alle Szenarien aus Spec „Rechteck-Auswahl im Ein-Schuss-Modus“ manuell durchspielen
- [x] 6.4 Highlight-Darstellung (40 % Dimmung, Rahmen) und Entfernen bei nächstem globalen Klick, Esc oder neuem `ctrl+opt+H`; verifizieren: Klick nach Highlight entfernt es **und** löst in der App darunter aus

## 7. Integration

- [x] 7.1 Test-Call mit Vollbild-Freigabe (z. B. Zoom/Teams/Meet, zweites Gerät als Zuschauer): Klick-Ringe, Halo, Spotlight und Rechteck-Highlight sind beim Zuschauer gut erkennbar; Farben/Größen in den Konstanten nachjustieren; verifizieren: alle vier Effekte beim Zuschauer sichtbar, Ergebnis in design.md (Open Questions) vermerkt
- [x] 7.2 Bekannte Einschränkung (Freigabe eines einzelnen Fensters zeigt Overlay nicht) im README dokumentieren; verifizieren: Abschnitt „Einschränkungen“ vorhanden

## Workflow follow-up

- Nach erfolgreicher Umsetzung `/opsx:verify` ausführen und danach den Change mit `/opsx:archive` archivieren.
