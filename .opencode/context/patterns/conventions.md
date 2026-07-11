# AwesomeWM Config — Coding Conventions

<!-- Generated: 2026-07-01 | Updated: 2026-07-01 -->

## Naming

- **Variables/functions**: `snake_case` throughout
- **Module tables**: `local module = {}` or `local M = {}`
- **Constants**: `SCREAMING_SNAKE_CASE` (`local MAX_ROWS = 6`)
- **Method calls**: Colon syntax (`object:method()`)
- **Private state**: `self._private` with `local wp = self._private` accessor

## File Organization

- Each module = directory with `init.lua` entry point
- Top-level directories organized by type: configuration/, ui/, service/, modules/, lib/, upstream/, themes/, bin/
- Barrel/aggregator modules: `configuration/init.lua`, `ui/init.lua`, `lib/init.lua`, `modules/init.lua`

## Imports

```lua
-- Group 1: System/lgi
local lgi = require("lgi")

-- Group 2: AwesomeWM core
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Group 3: Gears utilities
local gobject = require("gears.object")
local gtable = require("gears.table")
local gtimer = require("gears.timer")

-- Group 4: Project modules
local lib = require("lib")
local audio = require("service.audio")
```

- Always use `local` — no global pollution
- Capture native AwesomeWM globals via capi table:
  ```lua
  local capi = { screen = screen, client = client, awesome = awesome, tag = tag, mouse = mouse }
  ```

## Module Patterns

### Singleton (services and popups)
```lua
local gobject = require("gears.object")
local gtable = require("gears.table")

local instance = nil

local function new()
    local ret = gobject({})
    gtable.crush(ret, module, true)
    -- init signals, state
    return ret
end

local function get_default()
    if not instance then instance = new() end
    return instance
end

return { get_default = get_default }
```

### Instantiable Widget
```lua
local function new(args)
    local ret = wibox.widget({ ... })
    gtable.crush(ret, module, true)
    return ret
end

return setmetatable({ new = new }, { __call = function(_, ...) return new(...) end })
```

### Utility Library
```lua
local M = {}
function M.foo() end
return M
```

## Error Handling

- **Safe calls**: `pcall(function() ... end)` for potentially failing operations
- **Critical assertions**: `assert(lib.inspect(...))` for must-succeed operations
- **Guard clauses**: `if not c then return end` early returns
- **Shell spawning**: `awful.spawn.with_shell()` for fire-and-forget, `awful.spawn.easy_async_with_shell()` for callbacks
- **Never use**: `os.execute()`, `io.popen()` — always `awful.spawn` variants

## Signal Naming

- `entity::event` for service changes (e.g., `default-sink::volume`, `lockscreen::visible`)
- `property::name` for object property changes (e.g., `property::level`, `property::shown`, `property::connected`)
- Emit via `self:emit_signal("name", value)`
- Connect via `object:connect_signal("name", function(_, value) end)`

## Theme & Styling

- Access theme via `beautiful.*` variables
- All pixel measurements via `dpi()`: `dpi = beautiful.xresources.apply_dpi`
- Widget construction: declarative tables with `widget` key
- Shapes via `modules.shapes` factory functions: `shapes.rrect(10)`, `shapes.circle()`, `shapes.squircle()`

## Testing

- **No unit tests** — no busted or LuaUnit
- **Integration testing**: Xephyr nested AwesomeWM session via `./bin/awmtt-ng.sh`
- **Validation**: `awesome -c rc.lua --check` for syntax checking
- **Workflow**: `restart → check stderr for errors` loop

<!-- MANUAL: Add manual convention notes below this line -->
