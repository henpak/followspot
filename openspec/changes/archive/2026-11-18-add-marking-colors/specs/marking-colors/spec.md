# Spec Delta

## Purpose

Lets the user choose the colors of the markings directly in the menu bar menu from a fixed palette suited to screen sharing, so they match the presented content and stay clearly visible.

## ADDED Requirements

### Requirement: Color palette
The app SHALL offer exactly these 8 colors: Orange, Yellow, Red, Pink, Purple, Blue, Teal, Green. Every color MUST be vivid and fully opaque so it stays recognizable in compressed video streams.

#### Scenario: Palette in the menu
- **WHEN** the user opens the submenu of a color setting
- **THEN** the 8 colors are shown, each with a color dot and its name

### Requirement: Accent color
The app SHALL have an adjustable accent color that is used for the left-click ring, cursor halo, rectangle highlight border, crosshair and selection rectangle. Halo and selection rectangle use the accent color semi-transparently. The default SHALL be Orange.

#### Scenario: Default color at first launch
- **WHEN** the app launches for the first time and the user left-clicks
- **THEN** the ring appears in orange and a rectangle highlight has an orange border

#### Scenario: Changing the accent color
- **WHEN** the user chooses Green in the “Accent Color” submenu, then left-clicks, turns the halo on and drags a rectangle
- **THEN** ring, halo, crosshair, selection rectangle and highlight border are green

### Requirement: Right-click color
The app SHALL have an adjustable right-click color that is used for right-click rings (including ctrl-click). The default SHALL be Blue.

#### Scenario: Changing the right-click color
- **WHEN** the user chooses Pink in the “Right-Click Color” submenu and right-clicks
- **THEN** the ring appears in pink

### Requirement: Distinct left- and right-click colors
Accent color and right-click color MUST always differ. In the submenu of one color setting, the color currently chosen for the other setting SHALL NOT be selectable.

#### Scenario: Same color is locked
- **WHEN** the accent color is Orange and the user opens the “Right-Click Color” submenu
- **THEN** Orange is disabled there and cannot be chosen

#### Scenario: Invalid stored combination
- **WHEN** at launch the stored values have both colors set to the same color
- **THEN** the app keeps the accent color and sets the right-click color to another palette color

### Requirement: Choosing colors in the menu
The menu bar menu SHALL contain the items “Accent Color” and “Right-Click Color”, each as a submenu; the active color MUST carry a check mark and the main menu MUST show the active color at the item (color dot).

#### Scenario: Active color visible
- **WHEN** the right-click color is Blue and the user opens the menu
- **THEN** the item “Right-Click Color” shows a blue color dot and Blue carries a check mark in the submenu

### Requirement: Immediate effect
A color change SHALL take effect immediately, without a restart, including on markings that are currently visible (halo, rectangle highlight). Ring animations already running finish in the old color.

#### Scenario: Halo is active
- **WHEN** the cursor halo is on and the user changes the accent color
- **THEN** the halo switches to the new color immediately

#### Scenario: Highlight is active
- **WHEN** a rectangle highlight is visible and the user changes the accent color from the menu
- **THEN** the border switches to the new color and the highlight stays

### Requirement: Colors are remembered
The chosen colors SHALL persist across quitting and relaunching the app. Unknown or missing stored values MUST fall back to the default colors.

#### Scenario: Relaunch
- **WHEN** the user sets the accent color to Teal, quits the app and launches it again
- **THEN** the accent color is still Teal

#### Scenario: Unknown stored value
- **WHEN** the stored value does not match any palette color
- **THEN** the app uses the default color for that setting
