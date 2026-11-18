# screen-overlay Specification

## Purpose

Provides a transparent drawing layer above all displays on which click visualizations and highlights appear, without interfering with the apps underneath.

## Requirements

### Requirement: Overlay on all displays
The app SHALL show a transparent overlay layer on every connected display that sits above all regular app windows, including full-screen apps and all Spaces.

#### Scenario: Two displays connected
- **WHEN** the app is running and two displays are connected
- **THEN** markings can be shown on both displays

#### Scenario: Full-screen app
- **WHEN** another app runs in full-screen mode
- **THEN** markings still appear above that app

#### Scenario: Switching Spaces
- **WHEN** the user switches to another Space
- **THEN** the overlay remains available there

### Requirement: Click-through in normal operation
Outside the rectangle selection mode the overlay SHALL NOT intercept mouse or keyboard input; all input MUST reach the apps underneath unchanged.

#### Scenario: Clicking through the overlay
- **WHEN** the user clicks a button of an app during normal operation
- **THEN** the button triggers in the app as usual

#### Scenario: Clicking with an active spotlight
- **WHEN** the spotlight or cursor halo is active and the user clicks
- **THEN** the click reaches the app underneath

### Requirement: Visibility when screen sharing
The overlay MUST be included in the transmitted picture when a conferencing app shares the entire screen, and MUST NOT exclude itself from screen capture.

#### Scenario: Sharing the entire screen
- **WHEN** the user shares the entire screen in a conferencing app and clicks
- **THEN** viewers see the click ring

#### Scenario: Sharing a single window
- **WHEN** the user shares only a single app window
- **THEN** the overlay is not visible to viewers (known, accepted limitation)

### Requirement: Reacting to display changes
The app SHALL adapt the overlay when displays are connected, disconnected, or change resolution or arrangement, without restarting the app.

#### Scenario: External display connected
- **WHEN** an external display is connected while the app is running
- **THEN** markings also appear on the new display at the correct position

#### Scenario: Display disconnected
- **WHEN** a display is disconnected
- **THEN** the app keeps running without errors on the remaining displays
