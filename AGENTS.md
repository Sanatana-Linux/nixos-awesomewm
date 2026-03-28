# AGENTS.md

## Build, Lint, and Test Commands

### Testing
- **Start test environment**: `./bin/awmtt-ng.sh start` (Xephyr nested Awesome session)
- **Stop test environment**: `./bin/awmtt-ng.sh stop`
- **Stop all instances**: `./bin/awmtt-ng.sh stop all`
- **Restart Awesome in test**: `./bin/awmtt-ng.sh restart`
- **Run command in test**: `./bin/awmtt-ng.sh run <command>`
- **Single module test**: Manually reload Awesome in nested session (Super+Shift+R)
- **IMPORTANT**: After making changes, always test with `./bin/awmtt-ng.sh restart` and work through any errors in the log until resolved

### Configuration Validation
- **Check config syntax**: `awesome -c rc.lua --check`
- **Use test config file**: Create `rc.lua.test` symlink to test without affecting main config
- **Always validate syntax after changes**: `awesome -c /home/tlh/.config/awesome/rc.lua.test --check`

### Formatting and Linting
- **Format code**: `stylua .` (uses `.stylua.toml`)
- **Lint/diagnostics**: Use `lua-language-server` with `.luarc.json`
- **Check single file**: `stylua --check <file>`

### Auto-reload Testing
- **Enable auto-reload**: `./bin/awmtt-ng.sh start -R` (requires `entr`)

## Code Style Guidelines

### Formatting (StyLua Config)
- **Indentation**: 4 spaces
- **Line width**: 80 characters max
- **Quotes**: Prefer double quotes (AutoPreferDouble)
- **Line endings**: Unix (LF)

### Imports and Requires
- Group all `require` statements at the top of files
- Order: standard libraries first, then external, then local modules
- Use local variables for all requires: `local awful = require("awful")`
- For submodules, use dot notation: `local gtimer = require("gears.timer")`

### Variable Naming
- Always use `local` keyword (no global variables unless required by AwesomeWM)
- Use `snake_case` for variables and functions
- Use descriptive names: `default_sink_volume`, not `dsv`
- Constants can use SCREAMING_SNAKE_CASE: `local MAX_ROWS = 6`

### Function Definitions
- Use `snake_case` for function names
- Document parameters with comments for complex functions
- Use local functions for module-internal helpers
- Return early to reduce nesting

```lua
-- Good: local function with clear purpose
local function center_and_keep_on_screen(c, opts)
    if not c then return end
    -- implementation
end

-- Module pattern: return table with public interface
return {
    get_default = get_default,
}
```

### Types and Type Hints
- Lua is dynamically typed; use clear naming for intent
- Use `---@diagnostic disable: undefined-global` for AwesomeWM globals at file top
- Add AwesomeWM globals to `.luarc.json` `diagnostics.globals` if needed
- Use `capi` table to capture AwesomeWM native APIs:

```lua
local capi = {
    screen = screen,
    client = client,
    awesome = awesome,
    tag = tag,
    mouse = mouse,
}
```

### Error Handling
- Use `pcall()` for potentially failing operations
- Use `assert()` for critical operations that should fail fast
- Provide meaningful error messages

```lua
-- Safe call with error handling
local success, result = pcall(function()
    return Gio.AppInfo.get_all()
end)
if success then
    -- use result
else
    -- handle error
end

-- Critical assertion
local inspected = assert(lib.inspect(tbl, { indent = "\t" }))
```

### Private State Pattern
- Use `_private` table for instance-private data in objects
- Access via `local wp = self._private`

```lua
function launcher:show()
    local wp = self._private
    if wp.shown then return end
    wp.shown = true
    -- ...
end
```

### Singleton Pattern
Services and UI components use singleton pattern:

```lua
local instance = nil

local function new()
    local ret = gobject({})
    gtable.crush(ret, module, true)
    -- initialization
    return ret
end

local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
```

### Signal Handling
- Use `connect_signal` for event-driven communication
- Define custom signals on objects using `gears.object`
- Emit signals for state changes: `self:emit_signal("property::volume", value)`

```lua
-- Connect to signals
capi.client.connect_signal("request::manage", function(c)
    -- handle new client
end)

-- Emit custom signals
self:emit_signal("default-sink::volume", self.default_sink_volume)
```

### Comments
- Use `--` for single-line comments
- Use `--[[ ... --]]` for multi-line block comments
- Comment complex logic, not obvious operations
- Disable diagnostics at file top when needed

```lua
--[[ 
Module description here.
Explains purpose and key features.
--]]

---@diagnostic disable: undefined-global
```

### Widget Construction
- Use declarative widget tables with `widget` key
- Use `dpi()` for scaled dimensions from `beautiful.xresources.apply_dpi`
- Define widget structure clearly with proper nesting

```lua
wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.bg,
    shape = shapes.rrect(10),
    {
        widget = wibox.widget.textbox,
        markup = "Text content",
    },
})
```

### Widget IDs and Access
- Use `id` property to identify widgets for later access
- Access via `:get_children_by_id("id")[1]`
- Store references to frequently accessed widgets

```lua
local text_input = widget:get_children_by_id("text-input")[1]
text_input:set_input("")
```

### Theme and Beautiful
- Access theme variables via `beautiful` module
- Use `dpi()` for all pixel measurements
- Define theme variables in `themes/<theme_name>/theme.lua`
- Access icons via `beautiful.text_icons` table

```lua
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Use theme colors
bg = beautiful.bg,
fg = beautiful.fg,
-- Use text icons
markup = beautiful.text_icons.search,
```

## Project Structure

### Directory Layout
- `core/` - Core AwesomeWM functionality (autostart, client, keybind, tag, theme, screen, error, notification)
- `ui/` - User interface components (bar, popups, lockscreen, notification, titlebar, tabbar, wallpaper)
- `modules/` - Reusable UI modules (animations, calendar, dropdown, hover_button, menu, shapes, text_input, snap_edge)
- `service/` - System service integrations (audio, battery, bluetooth, brightness, network, screenshot, garbage_collection)
- `lib/` - Utility libraries (dbus_proxy, json, inspect)
- `themes/` - Visual themes with icons and styling
- `wibox/` - Custom wibox widgets and layouts
- `awful/` - Overrides for AwesomeWM awful library
- `bin/` - Scripts (awmtt-ng.sh, glitchlock.sh)

### Entry Points
- `rc.lua` - Main configuration entry point (loads core and ui)
- `core/init.lua` - Loads all core modules
- `ui/init.lua` - Initializes UI components, bars, popups

### Module Organization
Each module directory typically contains:
- `init.lua` - Module entry point and public interface
- Additional files for sub-components

```lua
-- Module pattern (init.lua)
local module = {}

function module:method() end

local function new(args)
    -- constructor
end

return setmetatable({ new = new }, { __call = function(_, ...) return new(...) end })
```

## Common Patterns

### Adding New UI Component
1. Create directory in `ui/` or appropriate location
2. Create `init.lua` with module pattern
3. Register in parent module or `ui/init.lua`
4. Test in nested session

### Adding New Service
1. Create file in `service/` directory
2. Use singleton pattern with `get_default()`
3. Extend `gears.object` for signals
4. Initialize values in `new()` function
5. Test integration with UI components

### Adding Keybinding
1. Identify appropriate file in `core/keybind/`
2. Use `awful.key()` or `awful.button()` 
3. Use `Mod4` (Super) as primary modifier
4. Test in nested session
