# area-highlighting Specification

## Purpose

Draws the viewers' attention to a specific area of the screen by highlighting it and dimming the rest, either as a dragged rectangle or as a spotlight around the cursor.

## Requirements

### Requirement: One-shot rectangle selection
After the highlight shortcut is triggered, the app SHALL allow exactly one rectangle selection by dragging the mouse and then return to normal operation automatically. A crosshair cursor MUST be shown during the selection. Pressing the highlight shortcut again during the selection MUST cancel it.

#### Scenario: Dragging a rectangle
- **WHEN** the user presses the highlight shortcut and drags a rectangle
- **THEN** that area is highlighted and clicks reach the apps again afterwards

#### Scenario: Cancelling the selection
- **WHEN** the user presses the highlight shortcut again in selection mode before dragging a rectangle
- **THEN** selection mode ends without a highlight

#### Scenario: Click without dragging
- **WHEN** the user only clicks in selection mode without dragging a rectangle
- **THEN** no highlight is created and the app returns to normal operation

#### Scenario: Selection on the external display
- **WHEN** the user drags the rectangle on the external display
- **THEN** the highlight appears on the external display

### Requirement: Rectangle highlight appearance
A rectangle highlight SHALL clearly dim the area outside the rectangle on the affected display and give the rectangle a colored border. The content inside the rectangle MUST stay visible unchanged.

#### Scenario: Highlight visible
- **WHEN** a rectangle highlight is active
- **THEN** the area outside is dimmed and the area inside stays unchanged and bright, with a border

### Requirement: Spotlight
The app SHALL offer a spotlight mode that dims all displays except a circle around the mouse pointer, which follows the pointer. The spotlight MUST be toggled by shortcut and keep the overlay click-through.

#### Scenario: Turning the spotlight on
- **WHEN** the user presses the spotlight shortcut
- **THEN** everything except a circle around the mouse pointer is dimmed

#### Scenario: Spotlight follows the mouse
- **WHEN** the spotlight is active and the user moves the mouse
- **THEN** the bright circle moves with the pointer

#### Scenario: Turning the spotlight off
- **WHEN** the spotlight is active and the user presses the spotlight shortcut again
- **THEN** the dimming is removed

### Requirement: Removing the rectangle highlight by click or shortcut
An active rectangle highlight SHALL disappear with the next normal mouse click or when the highlight shortcut is pressed again. The removing click MUST still reach the app underneath. Other features (halo, spotlight, click rings) MUST NOT be affected.

#### Scenario: Clicking on removes the highlight
- **WHEN** a highlight is active and the user clicks anywhere
- **THEN** the highlight disappears and the click is handled by the app under the pointer

#### Scenario: Shortcut removes the highlight
- **WHEN** a highlight is active and the user presses the highlight shortcut again
- **THEN** the highlight disappears without starting a new selection

#### Scenario: New highlight after removal
- **WHEN** the highlight was removed by shortcut and the user presses the highlight shortcut once more
- **THEN** a new rectangle selection begins
