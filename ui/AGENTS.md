<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# ui

## Purpose
User interface components — the wibar, popups, lockscreen, notifications, titlebar, tabbar, and wallpaper. Initialized by `ui/init.lua` which creates per-screen bars and instantiates all popup singletons with mutual exclusion wiring.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | UI orchestrator — creates bars, instantiates popups, wires mutual-exclusion signals |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `bar/` | Wibar (dock) — hover-reveal bar with module widgets (see `bar/AGENTS.md`) |
| `lockscreen/` | Screen locker with PAM authentication (see `lockscreen/AGENTS.md`) |
| `notification/` | Notification daemon replacement and screenshot handler (see `notification/AGENTS.md`) |
| `popups/` | All popup overlays — powermenu, launcher, control panel, etc. (see `popups/AGENTS.md`) |
| `tabbar/` | Tabbed client header bar (see `tabbar/AGENTS.md`) |
| `titlebar/` | Window titlebar with close/maximize buttons (see `titlebar/AGENTS.md`) |
| `wallpaper/` | Wallpaper setter with random selection support (see `wallpaper/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- New UI components must be registered in `ui/init.lua`
- Popup singletons use mutual-exclusion: when one shows, others hide via `property::shown` signals
- All popups that use the backdrop must call `backdrop.show(self)` / `backdrop.hide()` in their show/hide methods
- Use `pcall` around widget creation to avoid one bad screen breaking all bars

### Common Patterns
- **Bar**: `wibox({})` with `type = "utility"`, per-pixel alpha bg (`beautiful.bg .. "99"`)
- **Popup**: `awful.popup({})` with `bg = "#00000000"` (transparent popup), content bg with alpha
- **Wiring**: `popup:connect_signal("property::shown", function(_, shown) if shown then other:hide() end end)`