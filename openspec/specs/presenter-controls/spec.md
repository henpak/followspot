# presenter-controls Specification

## Purpose

Defines how the user operates the app during a presentation, through system-wide shortcuts and a menu bar menu, without leaving the app being presented.

## Requirements

### Requirement: System-wide shortcuts
The app SHALL provide the following shortcuts system-wide, regardless of which app is in front: `opt+F1` toggles the rectangle highlight feature (starts a selection, or cancels a running selection or removes a visible highlight), `opt+F2` toggles the spotlight, `opt+F3` toggles the cursor halo, `opt+F4` toggles the click rings. Each shortcut MUST affect only its own feature. The former shortcuts `ctrl+opt+H/S/C` MUST NOT be captured anymore.

#### Scenario: Shortcut in another app
- **WHEN** another app is in front and the user presses `opt+F2`
- **THEN** the spotlight toggles without that app losing focus

#### Scenario: Rectangle selection by shortcut
- **WHEN** neither a selection nor a highlight is active and the user presses `opt+F1`
- **THEN** the rectangle selection begins

#### Scenario: Halo by shortcut
- **WHEN** the user presses `opt+F3`
- **THEN** the cursor halo toggles

#### Scenario: Halo stays when the highlight is removed
- **WHEN** the cursor halo is on, a rectangle highlight is visible and the user presses `opt+F1`
- **THEN** the highlight disappears and the halo stays on

#### Scenario: Click rings by shortcut
- **WHEN** click rings are on and the user presses `opt+F4`
- **THEN** subsequent clicks no longer produce rings, and the menu item “Click Rings” has no check mark

#### Scenario: Former shortcuts are free
- **WHEN** the app is running and the user presses `ctrl+opt+S` in another app
- **THEN** Followspot does not react and the app in front receives the keystroke

#### Scenario: Esc stays with the app
- **WHEN** the halo, spotlight, a selection or a highlight is active and the user presses Esc
- **THEN** Followspot does not react, all features stay unchanged and the app in front receives the Esc

#### Scenario: Shortcut already taken
- **WHEN** a shortcut cannot be registered at launch
- **THEN** the app still starts and the menu shows which shortcut is unavailable

### Requirement: Menu bar menu
The app SHALL appear only as an icon in the menu bar (no Dock icon, no window at launch). The menu MUST contain toggles for click rings, cursor halo, spotlight and “Highlight Area” with a visible on/off state, the corresponding shortcuts, and “Quit Followspot”. “Highlight Area” MUST be shown as active while a selection is running or a highlight is visible, and MUST toggle like `opt+F1` when chosen.

#### Scenario: Launching the app
- **WHEN** the user launches the app
- **THEN** only an icon appears in the menu bar and no Dock icon

#### Scenario: State in the menu
- **WHEN** the spotlight was turned on by shortcut and the user opens the menu
- **THEN** the spotlight item is shown as active

#### Scenario: Highlight state in the menu
- **WHEN** a rectangle highlight is visible and the user opens the menu
- **THEN** “Highlight Area” is shown as active

#### Scenario: Quitting
- **WHEN** the user chooses “Quit Followspot” in the menu
- **THEN** all markings are removed and the app quits

### Requirement: Notice about missing permissions
If a feature needs a macOS permission that has not been granted, the app SHALL show this in the menu and offer a way to the relevant System Settings instead of failing silently.

#### Scenario: Permission missing
- **WHEN** a required permission has not been granted
- **THEN** the menu shows a notice with an item that opens System Settings
