<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# lib

## Purpose
Utility libraries providing shared functionality across the configuration: D-Bus proxy for system service access, JSON parsing, table inspection, and PAM authentication. Loaded via `lib/init.lua` which provides a unified interface table.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Library aggregator — attaches inspect, json, dbus_proxy; provides `create_markup()` helper |
| `inspect.lua` | Deep table inspection/formatting (penlight-style) |
| `json.lua` | JSON encode/decode library |
| `liblua_pam.so` | Native PAM authentication module for lockscreen |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `dbus_proxy/` | D-Bus proxy for BlueZ, NetworkManager, UPower interfaces (see `dbus_proxy/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- `lib.init.lua` provides `lib.create_markup(text, args)` for pango markup generation
- `lib.has_common(table_a, table_b)` checks for shared keys between tables
- `lib.dbus_proxy` wraps lgi D-Bus calls with error handling
- The native `.so` module is loaded via `package.cpath` — do not rename or move