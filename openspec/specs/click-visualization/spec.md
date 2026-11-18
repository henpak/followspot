# click-visualization Specification

## Purpose

Makes mouse activity visible to viewers of a shared screen, so they can always tell where the pointer is and where the user clicks.

## Requirements

### Requirement: Click ring
For every mouse click in any app, a ring SHALL appear at the click position and fade out within about 0.4 seconds. Click rings SHALL be enabled when the app starts.

#### Scenario: Left click
- **WHEN** the user left-clicks anywhere on the screen
- **THEN** a ring appears at exactly that position and then fades out

#### Scenario: Click on the second display
- **WHEN** the user clicks on the external display
- **THEN** the ring appears on the external display at the click position

#### Scenario: Rapid clicks
- **WHEN** the user clicks several times in quick succession
- **THEN** a separate ring appears for every click

### Requirement: Distinguishing left and right clicks
Click rings for left and right clicks MUST differ clearly in color.

#### Scenario: Right click
- **WHEN** the user right-clicks (including ctrl-click or a two-finger tap)
- **THEN** a ring appears in the right-click color instead of the left-click color

### Requirement: Toggling click rings
The user SHALL be able to turn click rings on and off from the menu bar menu.

#### Scenario: Click rings disabled
- **WHEN** the user turns click rings off in the menu and then clicks
- **THEN** no ring appears

### Requirement: Cursor halo
The app SHALL be able to show a permanently visible, semi-transparent circle around the mouse pointer that follows the pointer without noticeable delay, also across display boundaries. The halo SHALL be off when the app starts.

#### Scenario: Turning the halo on
- **WHEN** the user turns the cursor halo on via shortcut or menu and moves the mouse
- **THEN** a circle follows the mouse pointer

#### Scenario: Moving to another display
- **WHEN** the user moves the mouse to the other display while the halo is active
- **THEN** the halo is shown around the pointer on the other display

#### Scenario: Turning the halo off
- **WHEN** the user toggles the halo again
- **THEN** the circle disappears
