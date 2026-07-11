# AwesomeWM D-Bus Integration Conventions

## Library
Use `lib/dbus_proxy` for all D-Bus integration. This wraps `lgi.GDBusProxy` and provides:
- `Proxy:new({bus, name, interface, path})` — create a D-Bus proxy
- Automatic `PropertiesChanged` signal forwarding
- Connection monitoring and reconnection

## Patterns

### Connecting to a Service
```lua
local proxy = dbus_proxy.Proxy:new({
    bus = "system",  -- or "session"
    name = "org.freedesktop.NetworkManager",
    interface = "org.freedesktop.NetworkManager",
    path = "/org/freedesktop/NetworkManager",
})
```

### Handling Property Changes
```lua
proxy:connect("g-properties-changed", function(self, changed, invalidated)
    -- changed: table of { property_name = variant_value }
    -- invalidated: array of property names that became invalid
    for key, value in pairs(changed) do
        if key == "State" then
            self:emit_signal("property::state", value)
        end
    end
end)
```

### Singleton Pattern for Services
```lua
local instance = nil
local function get_default()
    if not instance then
        local ok, err = pcall(function()
            instance = new()  -- contains D-Bus proxy setup
        end)
        if not ok then
            -- Graceful fallback — service unavailable
            instance = gobject({})
            gtable.crush(instance, module, true)
        end
    end
    return instance
end
```

## NixOS Note
`lgi` is provided by the NixOS package `lua51Packages.lgi`. D-Bus services (NetworkManager, BlueZ) are always available on the system bus.

## Signal Forwarding
Service modules should convert raw D-Bus signals into project-standard `entity::event` signals:
```lua
-- Raw D-Bus → project signal
proxy:connect("g-properties-changed", function(_, changed)
    if changed.State then
        self:emit_signal("device::state", self, changed.State)
    end
end)
```
