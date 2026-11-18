# Spec Delta

## Purpose

Defines how the user operates the app during a presentation, through system-wide shortcuts, the Esc key and a menu bar menu, without leaving the app being presented.

## ADDED Requirements

### Requirement: System-wide shortcuts
The app SHALL provide the following shortcuts system-wide, regardless of which app is in front: `ctrl+opt+H` starts the rectangle selection, `ctrl+opt+S` toggles the spotlight, `ctrl+opt+C` toggles the cursor halo.

#### Scenario: Shortcut in another app
- **WHEN** another app is in front and the user presses `ctrl+opt+S`
- **THEN** the spotlight toggles without that app losing focus

#### Scenario: Shortcut already taken
- **WHEN** a shortcut cannot be registered at launch
- **THEN** the app still starts and the menu shows which shortcut is unavailable

### Requirement: Esc removes markings
While a marking or the rectangle selection is active, Esc SHALL remove all active markings or cancel the selection. If none of these is active, Esc MUST be passed on to the app in front unchanged.

#### Scenario: Esc with an active highlight
- **WHEN** a rectangle highlight is active and the user presses Esc
- **THEN** the highlight disappears

#### Scenario: Esc without an active marking
- **WHEN** no marking is active and the user presses Esc in an app
- **THEN** the app receives the Esc as usual

### Requirement: Menu bar menu
The app SHALL appear only as an icon in the menu bar (no Dock icon, no window at launch). The menu MUST contain toggles for click rings, cursor halo and spotlight with a visible on/off state, an item to start the rectangle selection, the corresponding shortcuts, and “Quit”.

#### Scenario: Launching the app
- **WHEN** the user launches the app
- **THEN** only an icon appears in the menu bar and no Dock icon

#### Scenario: State in the menu
- **WHEN** the spotlight was turned on by shortcut and the user opens the menu
- **THEN** the spotlight item is shown as active

#### Scenario: Quitting
- **WHEN** the user chooses “Quit” in the menu
- **THEN** all markings are removed and the app quits

### Requirement: Notice about missing permissions
If a feature needs a macOS permission that has not been granted, the app SHALL show this in the menu and offer a way to the relevant System Settings instead of failing silently.

#### Scenario: Permission missing
- **WHEN** a required permission has not been granted
- **THEN** the menu shows a notice with an item that opens System Settings
