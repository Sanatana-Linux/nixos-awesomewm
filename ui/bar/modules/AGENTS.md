<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# ui/bar/modules

## Purpose
Widget modules that populate the wibar — each module provides a section (taglist, tasklist, tray, clock, buttons) that the bar assembles in its layout.

## Key Files

| File | Description |
|------|-------------|
| `taglist_and_tasklist_buttons.lua` | Button bindings for taglist and tasklist widgets |
| `time_widget.lua` | Clock/time display widget |
| `layoutbox_widget.lua` | Layout indicator widget |
| `battery.lua` | Battery percentage widget for bar |
| `control_panel_button.lua` | Button to toggle control panel popup |
| `launcher_button.lua` | Button to toggle launcher popup |
| `tray_widget.lua` | System tray (systray) widget |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `control_panel_button/` | Control panel button with icons |
| `launcher_button/` | Launcher button with icons |
| `tray_widget/` | Tray widget with icons |

## For AI Agents

### Working In This Directory
- Widgets use `beautiful.text_icons` for Nerd Font glyphs instead of image icons where possible
- Services like `audio`, `battery`, `brightness` are consumed via `get_default()` singletons
- New widgets should follow the pattern: require service → create widget → return widget