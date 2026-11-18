# Spec Delta

## MODIFIED Requirements

### Requirement: System-wide shortcuts
The app SHALL provide the following shortcuts system-wide, regardless of which app is in front: `opt+F1` starts the rectangle selection, `opt+F2` toggles the spotlight, `opt+F3` toggles the cursor halo, `opt+F4` toggles the click rings. The former shortcuts `ctrl+opt+H/S/C` MUST NOT be captured anymore.

#### Scenario: Shortcut in another app
- **WHEN** another app is in front and the user presses `opt+F2`
- **THEN** the spotlight toggles without that app losing focus

#### Scenario: Rectangle selection by shortcut
- **WHEN** the user presses `opt+F1`
- **THEN** the rectangle selection begins

#### Scenario: Halo by shortcut
- **WHEN** the user presses `opt+F3`
- **THEN** the cursor halo toggles

#### Scenario: Click rings by shortcut
- **WHEN** click rings are on and the user presses `opt+F4`
- **THEN** subsequent clicks no longer produce rings, and the menu item “Click rings” has no check mark

#### Scenario: Former shortcuts are free
- **WHEN** the app is running and the user presses `ctrl+opt+S` in another app
- **THEN** Presenter does not react and the app in front receives the keystroke

#### Scenario: Shortcut already taken
- **WHEN** a shortcut cannot be registered at launch
- **THEN** the app still starts and the menu shows which shortcut is unavailable
