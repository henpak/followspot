# Tasks

## 1. Palette and rules (PresenterCore)

- [x] 1.1 Create `PaletteColor` (8 colors with stable ID, display name, sRGB values as in design.md Decision 1) in `PresenterCore`; unit tests check count/order, unique IDs and names; verify: `swift test` green
- [x] 1.2 Implement `MarkingColors` with defaults (Orange/Blue), fallback for unknown/missing IDs, correction of identical colors (accent stays, right click moves away, also for accent = Blue), `setAccent`/`setRightClick` rejecting taken colors, and `isSelectable`; unit tests for all scenarios of the spec requirements “Distinct left- and right-click colors” and “Colors are remembered”; verify: `swift test` green
- [x] 1.3 Implement `ColorStore` (load/save the palette IDs under `accentColor`/`rightClickColor` in injectable `UserDefaults`); unit tests with a dedicated defaults suite for round trip, missing keys and unknown values; verify: `swift test` green

## 2. Rendering

- [x] 2.1 Replace the fixed marking colors in `Style` with colors derived from `PaletteColor` (opacity values as in design.md Decision 5; `otherClickColor`, `dimColor`, `selectionCatcherColor` stay fixed); verify: `swift build` without warnings, the old constants are no longer used (`grep`)
- [x] 2.2 Implement `OverlayView.applyColors(_:)` (recolor halo, highlight border, crosshair and selection rectangle without animation; remember ring colors for new rings) and distribute it to all panels through `OverlayManager.applyColors(_:)`, including panels created in `rebuild()`; verify: with the default colors everything looks as before, except that the left-click ring and halo are orange instead of yellow
- [x] 2.3 `OverlayController` holds `colors` (loaded from `ColorStore` at launch), saves and distributes them on every change; verify: changing the accent color in the menu → halo and a visible highlight change color immediately, the highlight stays

## 3. Menu

- [x] 3.1 Create color dot images (about 12 pt, thin border, faded variant for disabled); verify: yellow is visible in the light and dark menu
- [x] 3.2 Add the submenus “Accent Color” and “Right-Click Color” to `StatusMenu` (color dot at the main item, 8 items with color dot + name, check mark at the active color, the color taken by the other setting disabled) and connect them to `OverlayController`; verify: walk through all scenarios of the spec requirements “Color palette”, “Choosing colors in the menu” and “Distinct left- and right-click colors” manually
- [x] 3.3 Extend the README usage section with the color choice (two settings, what they color, lock on identical colors, persistence); verify: the README describes the menu items as they appear

## 4. Sizes, dimming and guides: logic (PresenterCore)

- [x] 4.1 Create `MarkingSize` (small/medium/large with stable ID and display names Small/Medium/Large) and `AppearanceSettings` (three sizes + guide toggle, defaults Medium/on, fallback for unknown/missing values) as in design.md Decision 7; unit tests for defaults, fallbacks and independence of the three sizes; verify: `swift test` green
- [x] 4.2 Implement `AppearanceStore` (keys `clickRingSize`, `haloSize`, `spotlightSize`, `showsSelectionGuides`; missing Bool = on); unit tests with a dedicated defaults suite for round trip, missing keys and unknown values; verify: `swift test` green
- [x] 4.3 Create `DimLevel` (light/medium/strong, Light/Medium/Strong, opacity 25/40/60 %) and extend `AppearanceSettings`/`AppearanceStore` with `highlightDimming`/`spotlightDimming` (default Medium, keys as in design.md Decision 8a); unit tests for opacity values, defaults, fallbacks, independence and round trip; verify: `swift test` green

## 5. Sizes, dimming and guides: rendering and menu

- [x] 5.1 Dimensions per level in `Style` (table in design.md Decision 8, Medium = existing values) and `OverlayView.applyAppearance(_:)` (halo geometry, spotlight radius, ring dimensions for new rings, fill colors of both dimming layers, crosshair only when on) through `OverlayManager.applyAppearance(_:)` including newly created panels; `OverlayController` loads, saves and distributes `appearance`; verify: `swift build` without warnings, with the defaults ring, halo and spotlight are as large and highlight/spotlight as dark as before
- [x] 5.2 Add the submenus “Click Ring Size”, “Halo Size”, “Spotlight Size” (Small/Medium/Large), “Highlight Dimming”, “Spotlight Dimming” (Light/Medium/Strong), each with check marks, and the toggle “Crosshair While Selecting” to `StatusMenu` (order as in design.md Decision 10) and connect them to `OverlayController`; verify: walk through all scenarios of the spec `marking-appearance` manually (among others: halo/spotlight change immediately while active, guides off → only the selection rectangle is visible, changing the dimming with a visible highlight → immediately darker/lighter, the highlight stays)
- [x] 5.3 Extend the README with sizes, dimming and guides (menu items, levels, default, persistence, reset keys); verify: the README describes the menu items as they appear

## 6. Integration

- [x] 6.1 Rebuild the app with `scripts/build-app.sh --open` and check end to end: change accent and right-click color, left/right/ctrl-click on both displays, halo, crosshair and selection rectangle while dragging, rectangle highlight in the new color; all three sizes in two levels each, both dimmings Light/Strong, guides on/off; quit and relaunch the app → colors, sizes, dimming and guide toggle are kept; verify: all points confirmed by the user
