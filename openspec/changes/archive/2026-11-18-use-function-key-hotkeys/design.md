# Design

## Context

Die Hotkeys werden per Carbon `RegisterEventHotKey` registriert (siehe `add-presenter-overlay`, Decision 6). Das braucht keine Berechtigung, und der Tastendruck wird verbraucht. Die Belegung steht fest in `HotkeyAction`:

- `keyCode`
- `carbonModifiers`
- `menuKey` und `displayShortcut` für die Anzeige im Menü

Das Menü übernimmt `menuKey` als Key-Equivalent und setzt die Modifier-Maske fest auf `[.control, .option]`.

Relevante Gegebenheiten auf diesem Mac:

- Tastaturbelegung ABC-QWERTZ.
- „F1, F2 usw. als Standard-Funktionstasten verwenden“ ist **an** (`com.apple.keyboard.fnState = 1`). Die oberen Tasten liefern also F1… ohne fn.
- `⌥F1–F3` sind weder als macOS-Systemkürzel belegt (die Tastaturnavigation nutzt `⌃F1–F8`) noch erzeugen sie ein Zeichen.

## Goals / Non-Goals

**Goals:**
- Kürzel mit einem Modifier, die einhändig zu greifen sind, ohne Zeichen- oder System-Konflikt.
- Die Anzeige im Menü (Kürzel am Eintrag, Warnhinweis) stimmt automatisch mit der Registrierung überein.

**Non-Goals:**
- Frei konfigurierbare Kürzel (Recorder im Menü, Speicherung in UserDefaults).
- Die alten `⌃⌥`-Kürzel zusätzlich als Alias behalten.
- Erkennen, ob eine andere App `⌥F1–F3` belegt: Carbon-Hotkeys haben Vorrang vor App-Kürzeln.

## Decisions

### 1. Zuordnung F1 = Highlight, F2 = Spotlight, F3 = Halo

Das Highlight wird am häufigsten genutzt und liegt auf der äußersten, am leichtesten blind zu treffenden Taste. Spotlight und Halo folgen in der Reihenfolge der bisherigen Bedienung (H, S, C).

Verworfen: die Menüreihenfolge (Halo, Spotlight, Highlight). Sie ist historisch gewachsen und nicht nach Häufigkeit sortiert.

`⌥F4` schaltet die Klick-Ringe um. Sie waren bisher nur über das Menü schaltbar und kommen als neue `HotkeyAction` hinzu, mit dem Rohwert 5, damit die IDs der bestehenden Aktionen stabil bleiben. Die Aktion wird dauerhaft registriert wie F1–F3. Esc schaltet die Klick-Ringe weiterhin nicht ab, weil sie eine Grundeinstellung sind und keine temporäre Markierung.

### 2. Modifier als Eigenschaft von `HotkeyAction`, Menü leitet die Maske daraus ab

`HotkeyAction` bekommt neben `carbonModifiers` eine passende `menuModifiers: NSEvent.ModifierFlags`. `StatusMenu` nimmt diese, statt `[.control, .option]` fest zu verdrahten. So stehen Registrierung und Anzeige an einer Stelle, und ein künftiger Wechsel betrifft nur `HotkeyAction`.

Verworfen: die Maske in `StatusMenu` auf `[.option]` ändern. Das ist kleiner, aber die Duplikation bleibt.

### 3. F-Tasten im Menü über die Funktionstasten-Codepoints

`menuKey` liefert für F1–F3 `String(UnicodeScalar(NSF1FunctionKey)!)` usw. AppKit stellt diese Codepoints im Menü als „F1“ dar, zusammen mit der Modifier-Maske also als `⌥F1`. Die Key-Codes für Carbon sind `kVK_F1`, `kVK_F2` und `kVK_F3`.

### 4. Specs kürzelneutral, wo das Kürzel nur Mittel zum Zweck ist

Die Szenarien in `marking-appearance` testen die Hilfslinien, nicht das Kürzel. Sie sprechen deshalb nur noch vom „Starten der Rechteck-Auswahl“. Die konkreten Kürzel stehen allein in `presenter-controls`.

## Risks / Trade-offs

- **fnState wird umgestellt:** Schaltet der Nutzer die Systemeinstellung „F1, F2 usw. als Standard-Funktionstasten“ aus, liefern die oberen Tasten Helligkeit usw. Die Kürzel sind dann `fn⌥F1`. → Das README nennt diese Abhängigkeit.
- **App-Kürzel werden überdeckt:** Einzelne Apps nutzen `⌥F1–F3`, z. B. JetBrains-IDEs („Select In“ auf `⌥F1`). Solange Presenter läuft, kommen diese dort nicht an. → Wird akzeptiert. Falls es stört, ist eine konfigurierbare Belegung ein eigener späterer Change.
- **Registrierung schlägt fehl:** Belegt eine andere App das Kürzel bereits global, greift der bestehende Warnhinweis im Menü. → Kein zusätzlicher Aufwand.

## Migration Plan

- Neu bauen und installieren mit `scripts/build-app.sh --open`. Die Einstellungen in UserDefaults sind nicht betroffen.
- Rollback: auf den vorherigen Commit zurückgehen und neu bauen.
- Archivierung: Zuerst `add-presenter-overlay` und `add-marking-colors` archivieren, dann diesen Change. Die MODIFIED-Deltas setzen voraus, dass `presenter-controls` und `marking-appearance` bereits als Haupt-Specs existieren.
