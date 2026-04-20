# AwesomeWM Lua Patterns

## Module Pattern

Every module follows the standard AwesomeWM module pattern:

```lua
local gobject = require("gears.object")
local gtable = require("gears.table")

local module = {}

function module:public_method()
    -- implementation
end

local function new(args)
    local ret = gobject({})
    gtable.crush(ret, module, true)
    -- initialization from args
    return ret
end

return {
    get_default = function()
        if not instance then
            instance = new()
        end
        return instance
    end,
}
```

## Singleton Pattern

Services and UI components use singleton with `get_default()`:

```lua
local instance = nil

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

## Signal Pattern

Use `gears.object` for signal-based communication:

```lua
-- Define signals on object
local obj = gobject({})
gtable.crush(obj, module)

-- Emit signals on state changes
self:emit_signal("property::volume", value)

-- Connect to signals elsewhere
service.connect_signal("property::volume", function(value)
    -- react to change
end)
```

## Private State Pattern

Use `_private` table for instance-private data:

```lua
function launcher:show()
    local wp = self._private
    if wp.shown then return end
    wp.shown = true
    -- ...
end
```

## Widget Construction Pattern

Declarative widget tables with `widget` key:

```lua
wibox.widget({
    widget = wibox.container.background,
    bg = beautiful.bg,
    shape = shapes.rrect(10),
    {
        widget = wibox.widget.textbox,
        markup = "Content",
    },
})
```

## Error Handling Pattern

Use `pcall` for unsafe operations, `assert` for critical ones:

```lua
local success, result = pcall(function()
    return Gio.AppInfo.get_all()
end)
if success then
    -- use result
else
    -- handle error
end
```

## Require Pattern

Group and order requires at file top:

```lua
-- Standard libraries
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

-- External libraries
local Gio = require("lgi").Gio

-- Local modules
local shapes = require("modules.shapes")
local dpi = beautiful.xresources.apply_dpi
```

## DPI Scaling Pattern

Always use `dpi()` for pixel measurements:

```lua
local dpi = beautiful.xresources.apply_dpi
-- Use for all dimensions
size = dpi(10),
margins = dpi(4),
```