# Proposal

## Why

The colors and sizes of the markings are hard-coded. Depending on the presented UI (light or dark background, brand colors, colorful charts) and the display size, the markings are hard to see, too dominant or too small, and the guide lines while dragging a rectangle can be distracting. Quick settings directly in the menu bar menu fix this without rebuilding the app.

## What Changes

**Colors**
- Two colors adjustable in the menu:
  - **Accent color**: used for the left-click ring, cursor halo, rectangle highlight border, crosshair and selection rectangle.
  - **Right-click color**: used for the right-click ring.
- Each color is chosen from a submenu with a fixed palette of 8 vivid colors that stay recognizable in a video stream (color dot, name, check mark at the active color).
- Accent and right-click color cannot be the same, so left and right clicks stay distinguishable.
- Defaults: accent **Orange**, right click **Blue**. So far the left-click ring and halo were yellow and the highlight border orange; from now on all of them use the accent color (assumption: a single accent is wanted, default Orange).

**Sizes and guides** (added to this change later)
- Three separately adjustable sizes with the levels **Small / Medium / Large** each: click ring, cursor halo, spotlight. The default is **Medium** = the current size.
- Two separately adjustable **dimming strengths** with the levels **Light / Medium / Strong** (25 / 40 / 60 % black): for the rectangle highlight and for the spotlight. The default is **Medium** = the current 40 %.
- Toggle **“Crosshair While Selecting”** (on by default): shows or hides the crosshair lines across the whole display during rectangle selection. The dashed selection rectangle is always visible.

**Shared**
- All settings take effect immediately (including on a halo, spotlight or highlight that is currently visible) and persist across app restarts.
- Unchanged: the dimming color (black), the color for clicks with other mouse buttons, the line widths of halo and highlight border, the animation duration.
- Not included: free color choice through the macOS color picker, separate colors per element, continuous sizes or dimming, adjustable opacity of rings/halo, size of the highlight border.

## Capabilities

### New Capabilities
- `marking-colors`: adjustable marking colors: palette, assignment of accent and right-click color to the markings, choice in the menu, distinctness and persistence.
- `marking-appearance`: adjustable sizes of click ring, halo and spotlight and dimming strengths of highlight and spotlight in three levels each, plus showing or hiding the guides during rectangle selection: choice in the menu, immediate effect and persistence.

### Modified Capabilities
<!-- None. The affected capabilities (click-visualization, area-highlighting, presenter-controls) come from the not yet archived change add-presenter-overlay and do not define concrete colors. Sizes (ring about 0.4 s, spotlight circle) and the crosshair are not specified as fixed values there or stay unchanged by default; their requirements remain valid. -->

## Impact

- Builds on the change `add-presenter-overlay` (implemented, not archived yet); its specs do not exist as main specs yet, so this change introduces its own capabilities instead of deltas to existing specs.
- Code: `Sources/Presenter/Style.swift` (fixed colors and sizes become derived values), `OverlayView` (apply colors/sizes/guides again at runtime), `OverlayManager`/`OverlayController` (distribute and persist changes), `StatusMenu` (submenus for colors and sizes, toggle for guides), new settings logic in `PresenterCore` with unit tests.
- Stored in the app's user defaults (`UserDefaults`, domain `local.presenter.app`); no new dependencies, no new permissions.
- README: extend the usage section with colors, sizes and guides.
