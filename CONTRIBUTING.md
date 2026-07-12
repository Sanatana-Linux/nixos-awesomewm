# Contributing

This is a Lua-only AwesomeWM 4.3 configuration. The config loads at awesome startup
— there is no build step. Code is read straight from `rc.lua` → `configuration/init.lua`
+ `ui/init.lua`.

## Project layout

```
rc.lua                 Entry point — prepends upstream/ to package.path, then
                       requires configuration + ui.
configuration/         Core WM: autostart, theme, tags, clients, keybinds, screen
ui/                    Visual components: bar, popups, lockscreen, notifications
modules/               Reusable widgets and utilities (hover_button, calendar, …)
service/               Singleton system services (audio, battery, network, …)
lib/                   Vendored libraries (json, inspect, dbus_proxy)
upstream/              Overrides for built-in AwesomeWM libraries (awful, gears, …)
themes/kailash/        Active theme + icons
bin/                   Shell scripts (awmtt-ng, showcase)
tests/                 Pure-Lua unit tests for the overlay helpers
.opencode/             AI assistant context, rules, state, project docs
```

## Development workflow

```bash
# 1. Validate syntax
awesome -c rc.lua --check

# 2. Start a Xephyr test session
./bin/awmtt-ng.sh start

# 3. Restart awesome to reload config
./bin/awmtt-ng.sh restart

# 4. Stop the session
./bin/awmtt-ng.sh stop
```

## Code style

- **Formatter**: StyLua. Config in `.stylua.toml`. Run `stylua .` before committing.
- **Linter**: `lua-language-server` with `.luarc.json`.
- **Indentation**: 4 spaces, 80-char line width, double quotes (AutoPreferDouble).
- **Imports**: `local` everything at the top of the file. Group: stdlib → external → local.
- **Types**: Use the same annotation style as the AwesomeWM codebase, which renders
  to docs via LDOC. Patterns:
  ```
  --- One-line description
  -- @tparam type name description
  -- @treturn type description
  -- @see other_function
  ```
  `@tparam` / `@treturn` for parameters and return values, `@field` for tables,
  `@see` for cross-references. See `upstream/awful/util.lua` for examples.

## Singleton pattern

Services and popups use:

```lua
local instance
local function new() ... end
local function get_default()
    if not instance then instance = new() end
    return instance
end
return { get_default = get_default }
```

Callers do `require("service.audio").get_default()`. See `service/audio/init.lua`.

## Module pattern

Reusable widgets use either:

- **Instantiable widget** (calendar, text_input): `setmetatable({ new = new }, { __call = ... })`
- **Utility library** (shapes, modules.utils): plain function table, `return M`
- **Infrastructure** (animations, snap_edge): module with `connect_signal` pattern

## Adding a new keybinding

1. Identify the right file under `configuration/keybind/` (system, launcher, hardware,
   window, focus, layout, mouse, tags).
2. Use `awful.key({ modkey }, "key", callback, { description = ..., group = ... })`.
3. The keybinding auto-appears in the F1 help popup via `hotkeys_popup`.

## Adding a new service

1. Create `service/<name>/init.lua`.
2. Use the singleton pattern with `gobject({})` + `gtable.crush`.
3. Initialize state in `new()`. Use `gears.timer` for periodic refresh.
4. Emit signals on state changes: `self:emit_signal("entity::event", ...)`.

## Adding a new layout

1. Create `modules/layouts/<name>.lua`. Return a table with `name` and `arrange(p)`.
2. Require from `modules/layouts/init.lua`.
3. Add to `common.register_custom_layouts()` (pick a handler: `tile_handler` for
   master/slave layouts, `fair_handler` for simpler ones).
4. Document the layout in the file's leading comment block.

## Testing

Pure-Lua tests in `tests/spec_*.lua` run with `lua tests/run.lua` — no X server
required. The AwesomeWM runtime is validated separately by
`awesome -c rc.lua --check` (CI step 1) and `awmtt-ng.sh` (manual).

## Layout navigation mode (Mod4+F2)

The shared keygrabber, tips, and lifecycle hooks for all custom layouts live in
`modules/layouts/widgets/common.lua`. Any layout that wants Mod4+F2 navigation
should register a `key_handler` and (optionally) `tip` and `startup`/`cleanup` hooks.

## Path conventions

- Never hardcode `/home/<user>/...`. Use `os.getenv("HOME")` or the
  `awful.util.config_path()` overlay.
- Theme icons go in `themes/<theme>/icons/`.
- Vendored libraries go in `lib/` with a comment noting the source version.

## Don'ts

- No `os.execute()` or `io.popen()` — use `awful.spawn.with_shell()` or
  `awful.spawn.easy_async_with_shell()`.
- No global writes at runtime — capture AwesomeWM APIs into a local `capi` table.
- No new `require("luarocks.*")` calls without explicit approval (NixOS path).
- No git commits without review (run `git diff` first, then `git commit`).
