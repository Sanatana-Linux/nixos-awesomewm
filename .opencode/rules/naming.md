# Lua Naming Conventions

## General Rules

- Use `snake_case` for all variables, functions, and module names
- Use `SCREAMING_SNAKE_CASE` for constants: `local MAX_RETRIES = 3`
- Use `local` keyword for all declarations unless global scope is required by AwesomeWM
- Use descriptive names: `default_sink_volume`, not `dsv`

## Module Naming

- Module files use `snake_case`: `dbus_proxy.lua`, `text_input.lua`
- Module directories use `snake_case`: `hover_button/`, `snap_edge/`
- Entry points are always `init.lua`

## Function Naming

- Public methods use `snake_case`: `get_default()`, `emit_signal()`
- Private/helpers use `snake_case` with local scope
- Factory functions use `new()` pattern
- Boolean predicates use `is_` or `has_` prefix: `is_visible()`, `has_focus()`

## Variable Naming

- Loop variables: `i`, `j`, `k` for numeric; descriptive names otherwise
- Accumulators: `result`, `output`, `items`
- Booleans: prefix with `is_`, `has_`, `should_`, `can_`
- Callbacks: suffix with `_cb` or `_handler` when needed for clarity

## Widget Naming

- Widget IDs use `snake_case`: `text-input`, `control-panel`
- Theme variables use `snake_case`: `bg_normal`, `fg_focus`
- Signal names use `::` separator: `property::volume`, `button::press`

## File Naming

- One class/module per file
- File name matches module name: `battery.lua` exports battery module
- Directories group related modules: `service/`, `modules/`