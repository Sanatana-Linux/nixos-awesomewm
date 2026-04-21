<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# lib/dbus_proxy

## Purpose
D-Bus proxy module — wraps lgi D-Bus calls for system service access (BlueZ, NetworkManager, UPower). Provides typed proxy objects with signal monitoring.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | D-Bus proxy factory and bus connection management |
| `bus.lua` | System/session bus wrappers |
| `monitored.lua` | Monitored proxy with property change signal forwarding |
| `variant.lua` | D-Bus variant type handling |
| `proxy.lua` | Core proxy object for calling D-Bus methods and reading properties |

## For AI Agents

### Working In This Directory
- All lgi/Gio calls must be wrapped in `pcall`
- Proxies auto-monitor properties via `monitored.lua`
- Services consume these proxies via `require("lib.dbus_proxy")`