# Spec Delta

## MODIFIED Requirements

### Requirement: Crosshair guides during rectangle selection
The app SHALL offer a toggle “Crosshair While Selecting”, on by default. When it is on, a crosshair of lines across the whole display through the mouse pointer MUST be shown during rectangle selection; when it is off, this crosshair MUST be omitted. The selection rectangle while dragging and the finished highlight MUST be shown in both cases.

#### Scenario: Guides turned off
- **WHEN** the user turns “Crosshair While Selecting” off and starts a rectangle selection
- **THEN** no lines appear across the display, but the dashed selection rectangle is visible while dragging

#### Scenario: Guides turned on
- **WHEN** the toggle is on and the user starts a rectangle selection
- **THEN** crosshair lines run across the whole display through the mouse pointer
