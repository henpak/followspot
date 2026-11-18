# Design

## Context

See proposal.md, Why. Current state (from `add-presenter-overlay`): all colors are `static let` constants in `Sources/Presenter/Style.swift`. `OverlayView` sets the halo, border, crosshair and selection colors once in `setUpLayers()` and reads the click colors in `showRing(at:kind:)`. Runtime state flows through `OverlayController` → `OverlayManager.apply(_:)` → `OverlayView.apply(_:displayID:)`. The menu (`StatusMenu`) is rebuilt every time it opens (`menuNeedsUpdate`). There are no persisted settings yet.

## Goals / Non-Goals

**Goals:**
- Color, size and guide settings without rebuilding, effective immediately on all displays.
- Palette, size levels and rules (defaults, distinctness, fallbacks) as pure, tested logic in `PresenterCore`.
- Later extensions (e.g. a custom color through a color picker) possible without restructuring.

**Non-Goals:**
- A settings window; color choice stays in the menu.
- Live preview while hovering menu items.
- Making the color for clicks with other mouse buttons, the dimming color or the opacity adjustable.
- Continuous sizes, size of the highlight border, line width of halo/crosshair.

## Decisions

### 1. Palette as an enum in `PresenterCore`
`PaletteColor: String, CaseIterable` with stable IDs as raw values (`orange`, `yellow`, `red`, `pink`, `purple`, `blue`, `teal`, `green`), a display name and sRGB values:

| ID | Name | sRGB |
|---|---|---|
| orange | Orange | 1.00 / 0.60 / 0.00 |
| yellow | Yellow | 1.00 / 0.80 / 0.00 |
| red | Red | 1.00 / 0.23 / 0.19 |
| pink | Pink | 1.00 / 0.18 / 0.57 |
| purple | Purple | 0.69 / 0.32 / 0.87 |
| blue | Blue | 0.18 / 0.55 / 1.00 |
| teal | Teal | 0.00 / 0.78 / 0.80 |
| green | Green | 0.20 / 0.80 / 0.35 |

The IDs are stored, not the names or RGB values. Names and tones can therefore be adjusted later without invalidating stored values.
- *Alternative: storing RGB:* this would allow arbitrary colors, but validation and distinctness become fuzzy (when are two colors “the same”?). Rejected; free colors are a non-goal.

### 2. `MarkingColors` as a separate value, apart from `OverlayState`
Struct `MarkingColors { accent, rightClick }` with:
- `init(accentID: String?, rightClickID: String?)`: unknown or missing values become the default (Orange/Blue). If both colors are the same, the accent is kept and the right-click color becomes Blue. If the accent itself is Blue, the right-click color becomes the first other palette color (Orange).
- `mutating func setAccent(_:) -> Bool` / `setRightClick(_:) -> Bool`: reject a color that the other setting already uses.
- `func isSelectable(_ color:, forAccent:) -> Bool` for the menu logic.

The colors do not belong in `OverlayState`. `OverlayState` describes the transient session state (mode, markings, Esc logic); the colors are persistent settings. Keeping them apart leaves the existing state tests untouched, and Esc or `clearAll()` do not have to consider colors.

### 3. Persistence through `ColorStore` with injectable `UserDefaults`
`ColorStore` in `PresenterCore` reads and writes the keys `accentColor` and `rightClickColor` (palette IDs) in a given `UserDefaults` instance. The app uses `.standard` (domain `local.presenter.app`), the tests use their own suite. Values are saved on every change; there is no separate “save” step.

### 4. Runtime distribution: a separate `applyColors` path
`OverlayController` holds `colors: MarkingColors`. On every change (`didSet`) it saves the colors and calls `OverlayManager.applyColors(_:)`. That passes the colors to every `OverlayView.applyColors(_:)`, where the view re-applies the colors of halo, highlight border, crosshair and selection rectangle without implicit animation. The view remembers the colors for new click rings. Newly created panels (display connected) get the current colors in `rebuild()`.
- *Alternative: sending colors along with `apply(_ state:)`:* the colors would then be set again on every mouse movement or state change. Rejected, see Decision 2.

### 5. Derived tones in `Style`
`Style` keeps sizes and durations as constants. The fixed colors `leftClickColor`, `rightClickColor`, `haloFill`, `haloStroke`, `accent`, `crosshairColor` and `selectionFill` become functions of the chosen palette color, with the existing opacity values: halo fill 28 %, halo stroke 75 %, crosshair 80 %, selection fill 8 %, ring fill 18 %. `otherClickColor`, `dimColor` and `selectionCatcherColor` stay fixed.

### 6. Menu: two submenus with color dots
After the feature toggles, `StatusMenu` gets the items “Accent Color” and “Right-Click Color”. Each item shows a color dot of the active color as its image and has a submenu with 8 items (color dot plus name). The active color carries a check mark (`state = .on`). The color taken by the other setting has `isEnabled = false`, and its dot is drawn faded (35 % opacity), because non-template images are not grayed out automatically. The dots are circles of about 12 pt drawn with `NSImage(size:flipped:drawingHandler:)`, with a thin semi-transparent border so yellow stays visible on a light menu background. Clicking the menu item itself does not count as a global click (own app), so a visible highlight stays.

### 7. Size levels and appearance settings in `PresenterCore`
`MarkingSize: String, CaseIterable` (`small`, `medium`, `large`; display names Small/Medium/Large) and struct `AppearanceSettings { clickRingSize, haloSize, spotlightSize, showsSelectionGuides }` with defaults Medium/Medium/Medium/on. `AppearanceStore` reads and writes these values in injectable `UserDefaults` like `ColorStore`. Keys: `clickRingSize`, `haloSize`, `spotlightSize` (IDs), `showsSelectionGuides` (Bool). If the Bool key is missing, `true` applies (an `object(forKey:) == nil` check, because `bool(forKey:)` would return `false`). These values are kept apart from `MarkingColors` because there is no rule linking colors and sizes.
- *Alternative: everything in one `Settings` struct:* fewer types, but the already tested color rules would have to be restructured. Rejected.

### 8. Concrete dimensions per level in `Style`
Pixel values are presentation and belong in the app, not in `PresenterCore`. “Medium” matches the existing constants exactly:

| | Small | Medium | Large |
|---|---|---|---|
| Click ring start/end radius | 12 / 20 pt | 18 / 30 pt | 26 / 44 pt |
| Click ring line width | 3 pt | 4 pt | 5 pt |
| Halo radius | 20 pt | 28 pt | 40 pt |
| Spotlight radius | 80 pt | 120 pt | 180 pt |

The levels are about a factor of 1.4–1.5 apart, which keeps them clearly distinguishable in a video stream.

### 8a. Dimming levels
`DimLevel: String, CaseIterable` (`light`, `medium`, `strong`; display names Light/Medium/Strong) with the opacity as a value in the core (25 / 40 / 60 %). Unlike the pixel dimensions, the opacity is part of the spec and is therefore tested in the core. `AppearanceSettings` gets `highlightDimming` and `spotlightDimming` (default Medium), stored under the keys `highlightDimming` and `spotlightDimming`. In `OverlayView`, `highlightDimLayer` and `spotlightLayer` each get their own `fillColor` (black at the respective opacity). `Style.dimColor` becomes `Style.dimColor(_ level:)`. 60 % was chosen as the upper limit so the content outside stays recognizable in the video.

### 9. Runtime distribution like the colors
`OverlayController` holds `appearance: AppearanceSettings` (loaded at launch). `didSet` saves it and calls `OverlayManager.applyAppearance(_:)`, which also reaches panels created later. `OverlayView.applyAppearance(_:)` resets `bounds`/`path` of the halo layer and the fill colors of the two dimming layers, remembers the spotlight radius, ring dimensions and guide toggle, and calls `refreshCursorDependent()`. This way an active halo, an active spotlight, a visible highlight and a visible crosshair change immediately. The crosshair is drawn only when `isSelecting && showsSelectionGuides`. The selection rectangle does not depend on it, and the system cursor stays a crosshair cursor.

### 10. Menu order
After the color submenus, separated by a divider, come the submenus “Click Ring Size”, “Halo Size” and “Spotlight Size” (each Small/Medium/Large with check mark), then “Highlight Dimming” and “Spotlight Dimming” (each Light/Medium/Strong with check mark) and the toggle “Crosshair While Selecting” (check mark = on). The menu logic uses the same rebuild-on-open mechanism as the colors.

## Risks / Trade-offs

- [A large spotlight on a small display or a large halo covers a lot] → Adjustable on purpose; the default stays Medium.
- [The menu gets considerably longer (5 submenus + toggle)] → Grouped by dividers. A settings window stays a non-goal while the menu remains manageable.
- [A single accent changes the existing look: the left-click ring turns from yellow to orange] → Intended (see proposal). Anyone who prefers yellow can choose it in the menu.
- [Some palette colors are hard to see on certain content, e.g. yellow on white] → That is what the choice is for. The ring border is strong, the fill slightly transparent.
- [Red and green are hard to tell apart for people with red-green color blindness] → The defaults Orange/Blue are easy to distinguish. The choice is up to the user.
- [Locking identical colors could confuse (“why is Orange gray?”)] → The disabled item is clearly grayed out. A tooltip can be added later if needed.

## Migration Plan

No data migration: if the keys are missing (first launch after the update), the defaults Orange/Blue, all sizes Medium and guides on apply. Removal: the keys remain unused in the defaults and can be removed with `defaults delete local.presenter.app <key>` (`accentColor`, `rightClickColor`, `clickRingSize`, `haloSize`, `spotlightSize`, `highlightDimming`, `spotlightDimming`, `showsSelectionGuides`).
