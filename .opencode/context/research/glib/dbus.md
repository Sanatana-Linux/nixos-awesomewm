# GLib/GIO D-Bus Reference

**Source**: Context7 MCP — /gnome/glib
**Fetched**: 2026-07-01
**TTL**: 7 days

## Overview

GLib is the low-level core library for GNOME and GTK. GIO provides comprehensive D-Bus support. Used in this project via lgi (Lua GObject introspection) for NetworkManager and BlueZ D-Bus integration.

## Key Classes (via lgi)

- **Gio.DBusConnection** — Connect to D-Bus bus daemon
- **Gio.DBusProxy** — Proxy object for remote D-Bus interfaces
- **Gio.DBusObjectManagerClient** — Manages multiple D-Bus objects
- **Gio.DBusMethodInvocation** — Handle method calls
- **Gio.DBusServer** — D-Bus server implementation

## GDBusProxy Usage

### Creating a Proxy
```c
GDBusProxy *proxy;
proxy = g_dbus_proxy_new_for_bus_sync(
    G_BUS_TYPE_SYSTEM,              // bus type
    G_DBUS_PROXY_FLAGS_NONE,        // flags
    NULL,                           // interface info
    "org.freedesktop.NetworkManager", // bus name
    "/org/freedesktop/NetworkManager", // object path
    "org.freedesktop.NetworkManager",  // interface
    NULL,                           // cancellable
    &error);
```

### Calling Methods
```c
g_dbus_proxy_call(proxy,
    "MethodName",
    g_variant_new("(s)", "arg"),
    G_DBUS_CALL_FLAGS_NONE,
    -1,           // timeout (default)
    NULL,         // cancellable
    &error);
```

### Accessing Properties
```c
// Get property
value = g_dbus_proxy_get_property(proxy, "PropertyName", &error);

// Set property (async)
g_dbus_proxy_set_property(proxy, "PropertyName", variant, &error);
```

### Handling Signals
Connect to `g-signal` on the proxy:
- `PropertiesChanged` — emitted when remote properties change
- Signals carry: changed properties dict, invalidated properties array

## ObjectManager Pattern

For services with multiple objects (e.g., NetworkManager devices):

1. Create `GDBusObjectManagerClient` for the service
2. Connect to `object-added`, `object-removed` signals
3. Connect to `interface-proxy-properties-changed` on each object proxy
4. Iterate objects via `g_dbus_object_manager_get_objects()`

## In Lua via lgi

```lua
local lgi = require("lgi")
local Gio = lgi.Gio
local GLib = lgi.GLib

-- Connect to D-Bus
local bus = Gio.bus_get_sync(Gio.BusType.SYSTEM)

-- Create proxy
local proxy = Gio.DBusProxy.new_for_bus_sync(
    Gio.BusType.SYSTEM,
    Gio.DBusProxyFlags.NONE,
    nil,  -- interface info
    "org.freedesktop.NetworkManager",
    "/org/freedesktop/NetworkManager",
    "org.freedesktop.NetworkManager"
)

-- Property changes signal
proxy:connect("g-properties-changed", function(self, changed, invalid)
    for k, v in pairs(changed) do
        print(k, v)
    end
end)
```
