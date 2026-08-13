# AwesomeWM NixOS Integration Conventions

## Store Paths
NixOS installs binaries in the immutable store. Never assume paths like `/usr/bin/pactl`:
```lua
-- WRONG: hardcoded path
awful.spawn("/usr/bin/pactl info")

-- CORRECT: rely on PATH resolution via with_shell
awful.spawn.with_shell("pactl info")

-- CORRECT: use /run/current-system/sw/bin/ for direct calls
awful.spawn("/run/current-system/sw/bin/pactl info")
```

## LuaRocks
`pcall(require, "luarocks.loader")` may fail on NixOS because luarocks is optional. Always guard:
```lua
pcall(require, "luarocks.loader")  -- OK if this fails
```

## Lua Module Paths
The config prepends `lib/` to `package.path` (no `upstream/` override dir):
```lua
-- rc.lua prepends lib/ to package.path
package.path = config_dir .. "/lib/?.lua;" .. config_dir .. "/lib/?/init.lua;" .. package.path
```
This means `require("awful")` loads the system-installed version (NixOS `awesome` package), while project modules under `lib/` are resolved first.

## Native Modules
Lua C modules live in `lib/`:
```lua
package.cpath = config_dir .. "/lib/?.so;" .. package.cpath
```
Example: `lib/liblua_pam.so` for the lockscreen.

## D-Bus
All D-Bus services (NetworkManager, BlueZ, UPower) are provided by NixOS and available on the system bus. `lgi` is provided by `lua51Packages.lgi`.

## Testing
The `awmtt-ng.sh` script manages Xephyr sessions. It uses `nix-shell` or `$PATH` to find `awesome` and `Xephyr`:
```bash
./bin/awmtt-ng.sh start     # Start nested session
./bin/awmtt-ng.sh restart   # Reload config in session
./bin/awmtt-ng.sh stop      # Stop session
```

## No Systemd Unit
This config does NOT use a systemd user service for AwesomeWM. It's started by the display manager or `startx`.
