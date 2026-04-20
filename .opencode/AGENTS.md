<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# awesome - Project Instructions

## Overview

AwesomeWM window manager configuration written in Lua. Features a custom UI system with bars, popups, lockscreen, and system service integrations. Uses upstream library overrides and custom modules.

## Technology Stack

- **Language**: Lua (LuaJIT/Lua 5.1-5.3 compatibility)
- **Framework**: AwesomeWM (window manager)
- **Runtime**: X11/Xephyr for testing
- **Formatter**: StyLua (`.stylua.toml`)
- **LSP**: lua-language-server (`.luarc.json`)

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
- Use module pattern: return table with public interface

### Error Handling
- Use `pcall()` for potentially failing operations
- Use `assert()` for critical operations that should fail fast
- Provide meaningful error messages

### Private State Pattern
- Use `_private` table for instance-private data in objects
- Access via `local wp = self._private`

### Singleton Pattern
- Services and UI components use singleton pattern with `get_default()`

### Signal Handling
- Use `connect_signal` for event-driven communication
- Define custom signals on objects using `gears.object`
- Emit signals for state changes: `self:emit_signal("property::volume", value)`

### Widget Construction
- Use declarative widget tables with `widget` key
- Use `dpi()` for scaled dimensions from `beautiful.xresources.apply_dpi`
- Define widget structure clearly with proper nesting

### Widget IDs and Access
- Use `id` property to identify widgets for later access
- Access via `:get_children_by_id("id")[1]`
- Store references to frequently accessed widgets

### Theme and Beautiful
- Access theme variables via `beautiful` module
- Use `dpi()` for all pixel measurements
- Define theme variables in `themes/<theme_name>/theme.lua`
- Access icons via `beautiful.text_icons` table

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `configuration/` | Core WM config (autostart, client, keybind, tag, theme, screen, notification) |
| `ui/` | User interface components (bar, popups, lockscreen, notification, titlebar, tabbar, wallpaper) |
| `modules/` | Reusable UI modules (animations, calendar, dropdown, hover_button, menu, shapes, text_input, snap_edge) |
| `service/` | System service integrations (audio, battery, bluetooth, brightness, network, screenshot, garbage_collection) |
| `lib/` | Utility libraries (dbus_proxy, json, inspect) |
| `themes/` | Visual themes with icons and styling |
| `wibox/` | Custom wibox widgets and layouts |
| `awful/` | Overrides for AwesomeWM awful library |
| `bin/` | Scripts (awmtt-ng.sh, glitchlock.sh) |
| `upstream/` | Modified upstream AwesomeWM libraries |

## Entry Points

| File | Purpose |
|------|---------|
| `rc.lua` | Main configuration entry point (loads configuration and ui) |
| `configuration/init.lua` | Loads all core configuration modules |
| `ui/init.lua` | Initializes UI components, bars, popups |

## Module Organization

Each module directory typically contains:
- `init.lua` - Module entry point and public interface
- Additional files for sub-components

Module pattern example:
```lua
local module = {}

function module:method() end

local function new()
    -- constructor
end

return setmetatable({ new = new }, { __call = function(_, ...) return new(...) end })
```

## For AI Agents

### Working In This Directory
- Always test changes in nested Xephyr session before considering them complete
- Use `awesome -c rc.lua --check` to validate syntax after every change
- Run `stylua .` after modifying Lua files to maintain formatting
- The `upstream/` directory contains modified AwesomeWM libraries - modify with caution
- Lua 5.1/LuaJIT compatibility is required

### Common Patterns
- Singleton services with `get_default()` function
- Signal-based communication via `gears.object`
- Declarative widget construction with `widget` key
- Private state via `_private` table pattern

### Testing Requirements
- Test in nested Xephyr session via `awmtt-ng.sh`
- Verify no Lua errors in Awesome log after changes
- Reload test session after changes
- Check syntax with `awesome -c rc.lua --check`

## Git Workflow

- Feature branches: `feature/...`
- Fix branches: `fix/...`
- Always test in nested session before committing

<!-- MANUAL: Add custom instructions below this line -->