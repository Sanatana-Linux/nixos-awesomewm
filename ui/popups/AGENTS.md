<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# ui/popups

## Purpose
Popup overlays — modal dialogs that appear over the desktop with a backdrop. Each popup is a singleton (except hotkeys_popup) using `awful.popup` with `get_default()` export and mutual-exclusion signals.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `battery/` | Battery detail popup (see `battery/AGENTS.md`) |
| `control_panel/` | Main controls panel — audio, brightness, WiFi, Bluetooth, notifications (see `control_panel/AGENTS.md`) |
| `day_info_panel/` | Day/date info popup (see `day_info_panel/AGENTS.md`) |
| `hotkeys_popup/` | Keyboard shortcut help overlay |
| `launcher/` | App launcher popup with search (see `launcher/AGENTS.md`) |
| `menu/` | Right-click desktop menu (see `menu/AGENTS.md`) |
| `on_screen_display/` | OSD overlays for volume, brightness, layout (see `on_screen_display/AGENTS.md`) |
| `powermenu/` | Power/logout/sleep/restart popup (see `powermenu/AGENTS.md`) |
| `screenshot_popup/` | Screenshot mode selection popup (see `screenshot_popup/AGENTS.md`) |
| `window_switcher/` | Alt-tab window switcher (see `window_switcher/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- All popups use the `awful.popup` constructor → `gtable.crush` → `_private` state pattern
- `bg = "#00000000"` on the popup itself; actual bg via `wibox.container.background` with alpha
- Show/hide pattern: guard on `_private.shown` flag + backdrop.show(self)/backdrop.hide()
- Mutual exclusion: `popup:connect_signal("property::shown", ...)` hides others
- Adding a new popup requires: (1) create directory with `init.lua`, (2) wire in `ui/init.lua`