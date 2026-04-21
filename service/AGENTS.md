<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# service

## Purpose
System service singletons that interface with hardware and OS subsystems. Each service uses the `gobject` + `gtable.crush` + `get_default()` singleton pattern and emits signals on state changes for UI widgets to consume.

## Key Files

| File | Description |
|------|-------------|
| `audio.lua` | PulseAudio/PipeWire volume control, default sink/source monitoring |
| `battery.lua` | Battery level and charging state polling (15s interval) |
| `bluetooth.lua` | Bluetooth adapter state via BlueZ D-Bus (rfkill aware) |
| `brightness.lua` | Backlight brightness control via sysfs with delayed init |
| `caps.lua` | Caps lock state detection |
| `garbage_collection.lua` | Periodic Lua garbage collection to prevent memory leaks |
| `network.lua` | NetworkManager D-Bus integration (WiFi, wired connections) |
| `screenshot.lua` | Screenshot capture utility (scrot/maim) |
| `system_info.lua` | System information reads (kernel, uptime, CPU, memory) |

## For AI Agents

### Working In This Directory
- Follow `audio.lua` as the archetype for new services: `gobject({})` → `gtable.crush` → state init → `get_default()` singleton export
- Use `gears.timer` for periodic data refresh, `pcall` for all lgi/Gio/D-Bus calls
- Signal naming: `entity::event` for service events (`"default-sink::volume"`), `property::name` for object properties
- Emit signals conditionally (only on change) to avoid unnecessary UI updates

### Common Patterns
- **Constructor**: `local ret = gobject({})` → `gtable.crush(ret, module, true)` → init state → return ret
- **Singleton**: `local instance = nil; local function get_default() ... end; return { get_default = get_default }`
- **State**: Direct properties (`ret.volume = 0`) or `_private` table for hidden state
- **Timer**: `gears.timer({ timeout=N, autostart=true, callback=fn })`