# Design

## Context

Leeres Repository, keine bestehenden Specs (Motivation: siehe proposal.md – Why). Zielsystem ist der eigene Mac: macOS 26, MacBook-Display plus externer QHD-Monitor. Die App wird nur lokal gebaut und genutzt. Die Xcode-Toolchain auf dem Mac ist derzeit defekt (`swift --version` scheitert beim Laden von Bibliotheken) und muss vor der Umsetzung repariert werden.

## Goals / Non-Goals

**Goals:**
- Komplett per Kommandozeile bau- und signierbar (kein Klicken in Xcode nötig, außer einmalig für das Zertifikat).
- Flüssige Darstellung (Halo/Spotlight folgen der Maus ohne Ruckeln) bei zwei Retina/QHD-Bildschirmen.
- So wenige macOS-Berechtigungen wie möglich.
- Architektur, auf die spätere Modi (Stift, Pfeile, Zoom) ohne Umbau aufsetzen können.

**Non-Goals:**
- Konfigurierbarkeit von Farben, Größen oder Hotkeys (Werte als Konstanten im Code).
- Unterstützung älterer macOS-Versionen als macOS 15.
- Verteilung, Notarisierung, Auto-Update.

## Decisions

### 1. Swift + AppKit, Swift Package statt Xcode-Projekt
Swift Package (Executable-Target) plus ein kleines Build-Skript, das `swift build -c release` ausführt, daraus ein `Presenter.app`-Bundle (mit `Info.plist`, `LSUIElement = true`) zusammensetzt und es signiert.
- *Alternative Xcode-Projekt:* `.xcodeproj` ist schlecht von Hand bzw. per CLI pflegbar. Verworfen.
- *Alternative SwiftUI-`MenuBarExtra`:* für die Menüleiste möglich, aber Overlay-Fenster, Fenster-Ebenen und Event-Monitore sind ohnehin AppKit. Eine Technologie ist einfacher. Verworfen.
- *Alternative Electron/Tauri:* zu schwergewichtig für ein Overlay-Tool. Verworfen.

### 2. Stabile Code-Signatur
Das Build-Skript signiert mit einer festen Identität, damit macOS-Berechtigungen über Rebuilds hinweg erhalten bleiben. Bevorzugt ein „Apple Development“-Zertifikat (kostenloses Personal Team, einmalig in Xcode → Settings → Accounts angelegt). Fallback ist ein selbst erstelltes Code-Signing-Zertifikat in der Schlüsselbundverwaltung. Der Name der Identität ist im Skript konfigurierbar.
- *Alternative Ad-hoc-Signatur (`-`):* Signatur ändert sich bei jedem Build, Berechtigungen müssten ständig neu erteilt werden. Verworfen.

### 3. Overlay: ein `NSPanel` pro Bildschirm
Pro `NSScreen` ein randloses, transparentes `NSPanel` (`.nonactivatingPanel`), Fensterebene `.screenSaver`, `collectionBehavior` = alle Spaces + Vollbild-Begleiter + stationär, kein Schatten. Standardmäßig `ignoresMouseEvents = true`. `sharingType` bleibt auf dem Standard, damit Bildschirmaufnahmen das Overlay einschließen. Bei `didChangeScreenParametersNotification` werden die Panels neu aufgebaut.
- *Alternative ein großes Fenster über alle Bildschirme:* macOS beschränkt Fenster nicht zuverlässig über Bildschirmgrenzen, Probleme bei unterschiedlichen Skalierungen. Verworfen.
- Ebene `.screenSaver` statt höher (z. B. Shielding-Level), damit System-Dialoge nicht blockiert werden.

### 4. Zeichnen mit Core Animation
Jedes Panel hat eine layer-backed View. Klick-Ringe sind kurzlebige `CAShapeLayer` mit Skalierungs- und Fade-Animation, die danach entfernt werden. Halo ist eine `CAShapeLayer`, deren Position bei Mausbewegung gesetzt wird. Spotlight und Rechteck-Dimmung sind eine `CAShapeLayer` mit Pfad „Bildschirmfläche + Aussparung“ und Even-Odd-Füllregel. Positionsupdates laufen ohne implizite Animationen (`CATransaction.setDisableActions`).
- *Alternative `draw(_:)` mit Core Graphics:* komplettes Neuzeichnen bei jeder Mausbewegung, auf zwei hochauflösenden Bildschirmen unnötig teuer. Verworfen.

### 5. Maus-Events über globale NSEvent-Monitore
`NSEvent.addGlobalMonitorForEvents` für Maus-Klicks (links/rechts/andere), `mouseMoved` und Drag-Events. Positionen werden immer über `NSEvent.mouseLocation` (globale Koordinaten) bestimmt und pro Panel in lokale Koordinaten umgerechnet (`screen.frame.origin` abziehen). So passen sie auch bei zwei Bildschirmen mit unterschiedlicher Anordnung und Skalierung.
- Globale Monitore sehen keine Events, die an die eigene App gehen. Das ist gewollt: Im Auswahlmodus verarbeiten die Panels die Maus lokal.
- *Fallback, falls ein Spike zeigt, dass Berechtigungen fehlen oder Events ausbleiben:* `CGEventTap` im Listen-Only-Modus (benötigt „Eingabeüberwachung“).
- **Spike-Ergebnis (macOS 26.6, 2026-11-11):** Globale Monitore für Maus-Klicks und -Bewegungen liefern Events aus allen Apps auf beiden Bildschirmen, **ohne jede Berechtigung**. `AXIsProcessTrusted()` ist `false`, trotzdem kommen die Klicks an, und Presenter steht nicht in der Liste „Bedienungshilfen“. Beim Installieren prüft der WindowServer zwar `kTCCServiceAccessibility`, das löst aber keinen Dialog aus. Ein beobachteter Dialog stammte von einem `osascript`-Testversuch (Freigabe für Terminal), nicht von Presenter. Folge: Ein `CGEventTap` ist nicht nötig, eine Berechtigungsprüfung im Menü auch nicht. Aufgabe 2.2 entfällt.

### 6. Hotkeys über Carbon `RegisterEventHotKey`
Systemweite Tastenkürzel ohne Sonderrechte. Das Kürzel wird verbraucht und erreicht die Vordergrund-App nicht. **Esc wird nur dynamisch registriert**, solange eine Markierung oder der Auswahlmodus aktiv ist, und sofort wieder abgemeldet. So bleibt Esc in allen anderen Situationen bei der Vordergrund-App (siehe Spec presenter-controls).
- *Alternative globaler Key-Monitor (`NSEvent`):* braucht Bedienungshilfen und kann Tasten nicht verbrauchen. Verworfen.
- *Alternative Bibliothek (z. B. KeyboardShortcuts):* externe Abhängigkeit für vier fixe Kürzel unnötig. Verworfen.
- **Spike-Ergebnis (2026-11-11):** `⌃⌥H/S/C` und das dynamische Esc funktionieren systemweit und brauchen keine Berechtigung. Esc erreicht die Vordergrund-App normal, solange nichts aktiv ist.

### 7. Zustandsmodell
Ein zentraler `OverlayController` hält den Zustand und verteilt ihn an die Panels:

```
  Flags (unabhaengig):  clickRings (an) | halo (aus) | spotlight (aus)

  Modus:
   NORMAL --ctrl+opt+H--> SELECTING --Drag fertig--> NORMAL + highlight(rect, screen)
     ^                      |  |
     |                      |  +--Klick ohne Drag--> NORMAL
     |                      +--Esc-----------------> NORMAL
     |
     +-- highlight wird entfernt bei: globalem Klick | Esc | neuem ctrl+opt+H

  Esc-Hotkey registriert  <=>  SELECTING || highlight != nil || spotlight || halo
```
Im Zustand SELECTING werden alle Panels auf `ignoresMouseEvents = false` gesetzt. Die Views liefern `acceptsFirstMouse = true`, damit der erste Klick ohne App-Aktivierung ankommt. Danach wird wieder auf `true` zurückgeschaltet.

Auch Spotlight und Halo werden per Esc ausgeschaltet, weil Esc laut Spec „alle aktiven Markierungen“ entfernt.

### 8. Rechteck über Bildschirmgrenzen
Die Auswahl wird auf den Bildschirm beschränkt, auf dem das Ziehen begonnen hat. Die Koordinaten werden auf dessen Rahmen begrenzt. Der Spotlight dagegen dunkelt alle Bildschirme ab und spart nur auf dem Bildschirm mit dem Cursor den Kreis aus.

### 9. Darstellungswerte (Startwerte, im Code als Konstanten)
- Klick-Ring: Linienbreite ≥ 4 pt, Startradius ca. 18 pt, wächst auf ca. 30 pt, Fade 0,4 s. Linksklick gelb/orange, Rechtsklick blau. Hoher Kontrast, damit es die Videokompression übersteht.
- Halo: Radius ca. 28 pt, halbtransparent gefüllt.
- Dimmung: Schwarz mit 40 % Deckkraft. Rechteck-Rahmen 3 pt in der Akzentfarbe.
- Spotlight-Radius: ca. 120 pt.

## Risks / Trade-offs

- [Globale Maus-Monitore liefern ohne Berechtigung keine Events] → Spike als erste Aufgabe. Falls ja: Bedienungshilfen-Hinweis im Menü und notfalls `CGEventTap`.
- [Fadenkreuz-Cursor lässt sich aus einer nicht aktiven App nicht zuverlässig setzen] → Zuerst Cursor-Rects und `cursorUpdate` auf dem Panel versuchen. Fallback: eigenes Fadenkreuz im Overlay zeichnen.
- [Esc ist verbraucht, solange etwas aktiv ist; z. B. ein Esc für die präsentierte App wird abgefangen] → Bewusst akzeptiert. Esc ist nur dann belegt, wenn tatsächlich eine Markierung sichtbar ist.
- [Dünne oder blasse Markierungen verschwinden in der Videokompression der Konferenz-Apps] → Kräftige Farben und dicke Linien (siehe Decision 9). Feinjustierung nach einem echten Test-Call.
- [Fensterebene `.screenSaver` liegt über Mission Control, Benachrichtigungen o. Ä.] → Overlay ist durchsichtig und klick-durchlässig. Falls es stört, eine Ebene niedriger gehen.
- [Freigabe nur eines Fensters zeigt das Overlay nicht] → Plattform-Einschränkung, nicht lösbar. Ist in der Spec dokumentiert.
- [Defekte Xcode-Toolchain blockiert den Build] → Reparatur als Aufgabe 0, bevor Code geschrieben wird.

## Migration Plan

Keine Migration nötig (neue App). Installation: Das Build-Skript legt `Presenter.app` nach `~/Applications` ab. Bei Bedarf manuell als Anmeldeobjekt eintragen. Rückbau: App beenden und löschen, Berechtigungen in den Systemeinstellungen entfernen.

## Open Questions

- Exakte Farben, Radien und Animationsdauern werden nach einem Test-Call mit echter Bildschirmfreigabe feinjustiert. Das ändert nur Konstanten.
- **Ergebnis Test-Call (2026-11-18):** Vom Nutzer durchgeführt. Klick-Ringe, Halo, Spotlight und Rechteck-Highlight sind beim Zuschauer erkennbar.
