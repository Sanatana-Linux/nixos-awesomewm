# AwesomeWM Dev Context

## Key Commands

| Command | Purpose |
|---------|---------|
| `awesome -c rc.lua --check` | Validate config syntax |
| `stylua .` | Format all Lua files |
| `stylua --check <file>` | Check single file formatting |
| `./bin/awmtt-ng.sh start` | Start Xephyr nested test session |
| `./bin/awmtt-ng.sh restart` | Restart Awesome in test session |
| `./bin/awmtt-ng.sh stop` | Stop test session |
| `./bin/awmtt-ng.sh run <cmd>` | Run command in test session |

## File Structure

| Path | Purpose |
|------|---------|
| `service/*.lua` | System service singletons (audio, battery, brightness, etc.) |
| `ui/*.lua` / `ui/*/init.lua` | UI components (bar, popups, lockscreen, notifications) |
| `modules/*/init.lua` | Reusable widgets and utilities (shapes, calendar, menu, etc.) |
| `configuration/*/init.lua` | WM config (keybind, tag, client, theme, screen) |
| `lib/*.lua` | Utility libraries (dbus_proxy, json, inspect) |
| `themes/kailash/` | Current theme (icons, colors, assets) |
| `upstream/` | Modified AwesomeWM core libraries (modify with caution) |

## Four Module Archetypes

### Service (service/*.lua)
- **Constructor**: `gobject({})` → `gtable.crush(ret, module, true)` → init state → return ret
- **Export**: `get_default()` singleton
- **Signals**: `entity::event` (e.g. `default-sink::volume`, `brightness::updated`)
- **State**: Direct properties or `ret._private = { ... }`
- **Timer**: `gears.timer({ timeout=N, autostart=true, callback=fn })`
- **Reference**: `service/audio.lua` (simplest), `service/brightness.lua` (_private)

### UI Popup (ui/popups/*/init.lua)
- **Constructor**: `awful.popup({...})` → `gtable.crush(ret, module, true)` → `local wp = ret._private` → setup
- **Export**: `get_default()` singleton
- **Signals**: `property::shown` on show/hide
- **State**: `self._private.shown`, `self._private.select_index`, etc.
- **Show/Hide**: Guard with early return, emit signal, toggle `backdrop`
- **Widget access**: `self.widget:get_children_by_id("id")[1]`
- **Reference**: `ui/popups/powermenu/init.lua`

### Instantiable Widget (modules/*/init.lua)
- **Constructor**: `wibox.widget({...})` → `gtable.crush(ret, module, true)` → `local wp = ret._private` → setup
- **Export**: `setmetatable({ new = new }, { __call = function(_, ...) return new(...) end })`
- **State**: `self._private.*` from `args`
- **Widget access**: `self:get_children_by_id("id")[1]`
- **Signals**: `mouse::enter`, `mouse::leave` on hover
- **Reference**: `modules/calendar/init.lua`

### Utility Library (modules/*/init.lua)
- **Constructor**: None — plain table
- **Export**: `return M` (plain table of pure functions)
- **Signals**: None
- **State**: None
- **Reference**: `modules/shapes/init.lua`

## Code Style

- 4-space indent, 80-char line width, double quotes (StyLua)
- `local` for everything; capture AwesomeWM globals: `local capi = { screen = screen, client = client }`
- Require order: standard (awful, wibox, gears, beautiful) → external (lgi.Gio) → local (modules, service)
- `dpi()` for all pixel measurements, `beautiful.*` for all colors
- `pcall` all lgi/Gio calls; `gdebug.print_error` for loggable errors; no `assert` in project code
- Early return to reduce nesting

## Workflow Rules

1. Always read a sibling module from the target directory before writing
2. After changes: `awesome -c rc.lua --check` then `stylua .`
3. Test in nested session: `./bin/awmtt-ng.sh restart`
4. Never modify `upstream/` without explicit approval

## Common Patterns

| Pattern | When to Use |
|---------|-------------|
| `gobject({}) + gtable.crush + get_default` | New service or popup singleton |
| `wibox.widget({}) + setmetatable __call` | New instantiable widget |
| `plain return M` | New utility library |
| `gears.timer({ ... })` | Periodic data refresh |
| `gtimer.delayed_call(fn)` | Deferred initialization |
| `pcall(fn)` | Any lgi/Gio/native call |
| `self._private` via `local wp` | Instance state in popups/widgets |
| `self:emit_signal("property::name", val)` | State change notification |