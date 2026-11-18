# marking-appearance Specification

## Purpose

Lets the user adjust the size of click ring, cursor halo and spotlight as well as the dimming strength of highlight and spotlight in three levels each, and show or hide the crosshair guides during rectangle selection, so the markings fit the display size and presentation style.

## Requirements

### Requirement: Size levels
The app SHALL offer a separate size setting each for click ring, cursor halo and spotlight, with the levels Small, Medium and Large. Medium MUST match the original size and SHALL be the default; Small MUST be visibly smaller and Large visibly larger.

#### Scenario: Default at first launch
- **WHEN** the app launches for the first time
- **THEN** click ring, halo and spotlight are set to Medium and have their original size

#### Scenario: Settings are independent
- **WHEN** the user sets the click ring size to Small and the halo size to Large
- **THEN** click rings appear small, the halo appears large and the spotlight size stays unchanged

### Requirement: Click ring size
The chosen click ring size SHALL determine the start and end size and the line width of the ring, equally for left, right and other clicks. It SHALL apply to every ring that appears after the change; ring animations already running finish in the old size.

#### Scenario: Large click ring
- **WHEN** the user sets the click ring size to Large and then clicks
- **THEN** a noticeably larger ring with a thicker line than at Medium appears

### Requirement: Halo and spotlight size
The chosen halo size SHALL determine the radius of the cursor halo, the chosen spotlight size the radius of the bright circle of the spotlight. A change MUST take effect immediately, even while the halo or spotlight is on.

#### Scenario: Changing the halo size while the halo is on
- **WHEN** the halo is on and the user sets the halo size to Small
- **THEN** the halo becomes smaller immediately and keeps following the pointer

#### Scenario: Changing the spotlight size while the spotlight is on
- **WHEN** the spotlight is on and the user sets the spotlight size to Large
- **THEN** the bright circle becomes larger immediately

### Requirement: Dimming strength
The app SHALL offer two separate dimming settings, one for the rectangle highlight and one for the spotlight, each with the levels Light (25 %), Medium (40 %) and Strong (60 %) black. Medium SHALL be the default. The highlighted area or bright circle MUST stay unchanged and bright regardless of the level. A change MUST take effect immediately, including on a visible highlight or an active spotlight.

#### Scenario: Dimming the highlight more strongly
- **WHEN** a rectangle highlight is visible and the user sets “Highlight Dimming” to Strong
- **THEN** the area outside the rectangle becomes darker immediately, the rectangle itself stays bright and the highlight stays

#### Scenario: Settings are separate
- **WHEN** the user sets “Spotlight Dimming” to Light and leaves “Highlight Dimming” at Medium
- **THEN** the spotlight dims less than a rectangle highlight

### Requirement: Crosshair guides during rectangle selection
The app SHALL offer a toggle “Crosshair While Selecting”, on by default. When it is on, a crosshair of lines across the whole display through the mouse pointer MUST be shown during rectangle selection; when it is off, this crosshair MUST be omitted. The selection rectangle while dragging and the finished highlight MUST be shown in both cases.

#### Scenario: Guides turned off
- **WHEN** the user turns “Crosshair While Selecting” off and starts a rectangle selection
- **THEN** no lines appear across the display, but the dashed selection rectangle is visible while dragging

#### Scenario: Guides turned on
- **WHEN** the toggle is on and the user starts a rectangle selection
- **THEN** crosshair lines run across the whole display through the mouse pointer

### Requirement: Menu controls
The menu bar menu SHALL contain the submenus “Click Ring Size”, “Halo Size” and “Spotlight Size” with the items Small, Medium, Large, and “Highlight Dimming” and “Spotlight Dimming” with the items Light, Medium, Strong, with the active level carrying a check mark, as well as the toggle “Crosshair While Selecting” with a visible on/off state.

#### Scenario: Active level visible
- **WHEN** the halo size is Large and the user opens the “Halo Size” submenu
- **THEN** Large carries a check mark

#### Scenario: Toggle state visible
- **WHEN** the crosshair guides are off and the user opens the menu
- **THEN** “Crosshair While Selecting” has no check mark

### Requirement: Settings are remembered
Sizes, dimming levels and the crosshair toggle SHALL persist across quitting and relaunching the app. Missing or unknown stored values MUST fall back to the defaults (Medium, crosshair on). Settings chosen under the app's former name “Presenter” SHALL be taken over.

#### Scenario: Relaunch
- **WHEN** the user sets the spotlight size to Small, turns the crosshair off, quits the app and launches it again
- **THEN** the spotlight size is still Small and the crosshair is off

#### Scenario: Unknown stored value
- **WHEN** an unknown value is stored for the click ring size
- **THEN** the app uses the level Medium

#### Scenario: Takeover from Presenter
- **WHEN** the user previously used the app under the name “Presenter” and launches Followspot for the first time
- **THEN** the previously chosen sizes, dimming levels and crosshair toggle still apply
