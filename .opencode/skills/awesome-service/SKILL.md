---
name: awesome-service
description:
  Create or modify AwesomeWM system service modules (audio, battery, network,
  bluetooth, etc.) following codebase conventions. Use when building a new
  service, refactoring an existing one, or debugging service patterns.
---

# AwesomeWM Service Module Guide

Defines the exact patterns used in this codebase for creating and modifying
system service modules under `service/`. Services handle OS-level integration
(audio, battery, network, bluetooth, brightness, screenshot, caps,
system_info, garbage_collection) and communicate with UI components via
signals.

## When to Use

- Creating a new system service module (e.g., a new `service/{name}/`)
- Refactoring or fixing an existing service
- Debugging service lifecycle, signal wiring, or communication backends
- Adding new signals or properties to a service
- Replacing a shell-based backend with D-Bus or vice versa

## File Location

```
service/{name}/
└── init.lua
```

No central registration is needed — consumers `require("service.{name}")`
directly. The module should export `{ get_default = get_default }` following
the singleton pattern.

## Service Singleton Pattern

Every service uses the same singleton + `gobject` base pattern:

```lua
local gobject = require("gears.object")
local gtable = require("gears.table")

local instance = nil

local function new()
    local ret = gobject({})
    gtable.crush(ret, module, true)
    -- initialization: set up timers, proxies, subscriptions here
    return ret
end

local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return { get_default = get_default }
```

`gtable.crush(ret, module, true)` copies all functions from the module table
onto the `gobject` instance, making them callable as methods. The deep `true`
flag enables recursive merging.

## Communication Backends

### 1. Shell-Based (audio, battery, brightness)

Use `awful.spawn.easy_async_with_shell()` for async reads and
`awful.spawn.with_shell()` for fire-and-forget commands.

```lua
local awful = require("awful")

-- Async read: capture command output
function module:get_volume()
    awful.spawn.easy_async_with_shell("pactl get-sink-volume @DEFAULT_SINK@", function(stdout)
        local volume = parse_volume(stdout)
        self:emit_signal("default-sink::volume", volume)
    end)
end

-- Fire-and-forget: set command, no callback needed
function module:set_volume(percent)
    awful.spawn.with_shell(string.format("pactl set-sink-volume @DEFAULT_SINK@ %d%%", percent))
end
```

**Never use** `os.execute()` or `io.popen()` — always go through
`awful.spawn` for non-blocking operation.

### 2. D-Bus-Based (network, bluetooth)

Use the `lib/dbus_proxy` library, which wraps `lgi.GDBusProxy`:

```lua
local dbus_proxy = require("lib.dbus_proxy")

function module:init_dbus()
    self._proxy = dbus_proxy({
        name = "org.freedesktop.NetworkManager",
        path = "/org/freedesktop/NetworkManager",
        interface = "org.freedesktop.NetworkManager",
    })

    self._proxy:connect("g-properties-changed", function(proxy, properties, invalidated)
        -- properties is a table of changed D-Bus properties
        self:emit_signal("device::state", properties.State)
    end)
end
```

Client code connects to signals via the proxy object:

```lua
proxy:connect("g-properties-changed", callback)
```

## Signal Naming Convention

| Scope     | Pattern           | Examples                                      |
| --------- | ----------------- | --------------------------------------------- |
| Service   | `entity::event`   | `default-sink::volume`, `device::state`       |
| Property  | `property::name`  | `property::level`, `property::connected`      |

Emit signals with the value as the second argument:

```lua
self:emit_signal("default-sink::volume", volume_value)
self:emit_signal("property::connected", is_connected)
```

UI components connect to these signals to react to state changes:

```lua
service:connect_signal("default-sink::volume", function(self, volume)
    -- update UI
end)
```

## Keep-Alive Pattern

Use a `gears.timer` to prevent idle hardware sinks (PipeWire, PulseAudio)
from suspending:

```lua
local gears = require("gears")

local function setup_keep_alive()
    self._private.keep_alive = gears.timer {
        timeout = 5,
        autostart = true,
        call_now = false,
        callback = function()
            awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ 100%")
        end,
    }
end
```

- `call_now = false` — avoids an immediate side-effect on startup
- `awful.spawn.with_shell()` — fire-and-forget, no callback needed
- Stop with `self._private.keep_alive:stop()` during teardown

## Private State

All instance-private data lives in `self._private`. Access via a local alias:

```lua
function module:some_method()
    local wp = self._private
    if wp.shown then return end
    wp.shown = true
    -- ...
end
```

## capi Table

Capture native AwesomeWM globals at the top of each file to avoid global
lookups and improve testability:

```lua
local capi = {
    screen = screen,
    client = client,
    awesome = awesome,
    tag = tag,
    mouse = mouse,
}
```

## Error Handling

- Use `pcall()` for potentially failing operations (e.g., D-Bus calls):

```lua
local ok, result = pcall(function()
    return self._proxy:call_sync("Get", ...)
end)
if not ok then
    self:emit_signal("property::error", "D-Bus call failed")
    return
end
```

- Use `assert()` for critical operations that must succeed:

```lua
local proxy = assert(
    dbus_proxy({ name = "...", path = "...", interface = "..." }),
    "Failed to create D-Bus proxy"
)
```

## Module Structure Template

```lua
---@diagnostic disable: undefined-global
local capi = {
    screen = screen,
    client = client,
    awesome = awesome,
}

local awful = require("awful")
local gears = require("gears")
local gobject = require("gears.object")
local gtable = require("gears.table")

local instance = nil

-- Module table (functions become methods via gtable.crush)
local module = {}

--- Initialise the service.
function module:init()
    local wp = self._private
    -- set up timers, proxies, subscriptions
end

--- Get current state.
function module:get_state()
    local wp = self._private
    return wp.some_value
end

-- Constructor
local function new()
    local ret = gobject({})
    gtable.crush(ret, module, true)
    ret:init()
    return ret
end

local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return { get_default = get_default }
```

## Testing

1. **Syntax check**: `awesome -c rc.lua --check`
2. **Restart test session**: `./bin/awmtt-ng.sh restart`
3. **Check logs** in the test Xephyr window for errors
4. Test signal emission by connecting a quick debug listener:
   ```lua
   local svc = require("service.name")
   svc:connect_signal("entity::event", function(_, val)
       print("Signal received:", val)
   end)
   ```

No unit test framework is used (no busted) — testing is done via manual
reload in the nested Awesome session.

## Red Flags

- Using `os.execute()` or `io.popen()` instead of `awful.spawn.*`
- Storing instance data anywhere other than `self._private`
- Using global variables instead of the `capi` capture table
- Missing `gtable.crush(ret, module, true)` — methods won't work as intended
- Forgetting `call_now = false` on keep-alive timers
- Central registration in `ui/init.lua` — services are required directly by
  consumers
- Direct `lgi.GDBusProxy` usage instead of the `lib/dbus_proxy` wrapper
