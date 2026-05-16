# AwesomeWM Development Guidelines

## Project Architecture
- This is a Lua-only AwesomeWM 4.3 config on NixOS
- Entry point: `rc.lua` → `configuration/init.lua` + `ui/init.lua`
- Uses "upstream override" pattern: modified AwesomeWM libs in `upstream/` prepended to `package.path`
- No build step — pure Lua configuration loaded at runtime

## Testing
- Use `./bin/awmtt-ng.sh` for Xephyr-based nested session testing
- Always validate syntax: `awesome -c rc.lua --check` or with test config
- After changes: `./bin/awmtt-ng.sh restart` then check errors in log
- No unit test framework (no busted) — manual reload testing

## Key Patterns
- **Singleton**: Services/popups use `gobject({})` + `gtable.crush(ret, module, true)` + `get_default()` with cached `instance` closure
- **Signals**: Custom signals emitted via `self:emit_signal("name")`, connected via `connect_signal`. Signal naming convention: `entity::event` for service events (e.g. `"default-sink::volume"`)
- **capi table**: Capture native AwesomeWM globals at top of files — `local capi = { screen = screen, client = client, ... }` — to avoid global lookups
- **Private state**: Instance data in `self._private` table, accessed as `local wp = self._private`
- **Mutual exclusion**: Popups hide each other via `property::shown` signal wiring in `ui/init.lua` — when one popup shows, all others hide

## Directories
- `configuration/` — Core WM: autostart, theme, tags, clients, keybinds, screen
- `ui/` — Visual components: bar, popups, lockscreen, titlebar, tabbar, wallpaper
- `modules/` — Shared widgets: animations, calendar, dropdown, shapes, text_input, menu, applet_button, hover_button, snap_edge, page_container, layouts
- `service/` — System backends: audio, battery, bluetooth, brightness, network, screenshot, caps, system_info, garbage_collection
- `lib/` — Utilities: dbus_proxy, json.lua, inspect.lua
- `upstream/` — Modified AwesomeWM builtins: awful, beautiful, gears, menubar, naughty, ruled, wibox
- `themes/kailash/` — Active theme (Monokai Pro Spectrum palette)
- `bin/` — Scripts: awmtt-ng.sh, glitchlock.sh

## Common Operations
- **Format**: `stylua .` (uses `.stylua.toml`)
- **Lint**: lua-language-server with `.luarc.json`
- **Syntax check**: `awesome -c rc.lua --check`
- **Test reload**: `./bin/awmtt-ng.sh restart`
- **Add new service**: Create directory in `service/`, write `init.lua` with singleton pattern, no registration needed (callers require directly)
- **Add new UI component**: Create directory in `ui/`, register in `ui/init.lua`, add mutual-exclusion wiring if it's a popup

## Don'ts
- Don't install luarocks packages unless critical — NixOS manages dependencies via Nix
- Don't write to global AwesomeWM state at runtime
- Don't use `os.execute()` or `io.popen()` — use `awful.spawn()` or `awful.spawn.easy_async_with_shell()` instead
- Don't assume XDG paths exist — check first or use `gears.filesystem`
- Don't use global variables unless required by AwesomeWM (tag, client, screen, etc.) — use `capi` table to capture them explicitly
