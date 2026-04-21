<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# service

## Purpose
System service singletons that interface with hardware and OS subsystems. Each service uses the `gobject` + `gtable.crush` + `get_default()` singleton pattern and emits signals on state changes for UI widgets to consume.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `audio/` | PulseAudio/PipeWire volume control, default sink/source monitoring (see `audio/AGENTS.md`) |
| `battery/` | Battery level and charging state polling (15s interval) (see `battery/AGENTS.md`) |
| `bluetooth/` | Bluetooth adapter state via BlueZ D-Bus (rfkill aware) (see `bluetooth/AGENTS.md`) |
| `brightness/` | Backlight brightness control via sysfs with delayed init (see `brightness/AGENTS.md`) |
| `caps/` | Caps lock state detection (see `caps/AGENTS.md`) |
| `garbage_collection/` | Periodic Lua garbage collection to prevent memory leaks (see `garbage_collection/AGENTS.md`) |
| `network/` | NetworkManager D-Bus integration (WiFi, wired connections) (see `network/AGENTS.md`) |
| `screenshot/` | Screenshot capture utility (scrot/maim) (see `screenshot/AGENTS.md`) |
| `system_info/` | System information reads (kernel, uptime, CPU, memory) (see `system_info/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Each service is a directory with `init.lua` entry point (e.g., `service/audio/init.lua`)
- Follow `audio/` as the archetype for new services: `gobject({})` → `gtable.crush` → state init → `get_default()` singleton export
- Use `gears.timer` for periodic data refresh, `pcall` for all lgi/Gio/D-Bus calls
- Signal naming: `entity::event` for service events (`"default-sink::volume"`), `property::name` for object properties
- Emit signals conditionally (only on change) to avoid unnecessary UI updates

### Common Patterns
- **Constructor**: `local ret = gobject({})` → `gtable.crush(ret, module, true)` → init state → return ret
- **Singleton**: `local instance = nil; local function get_default() ... end; return { get_default = get_default }`
- **State**: Direct properties (`ret.volume = 0`) or `_private` table for hidden state
- **Timer**: `gears.timer({ timeout=N, autostart=true, callback=fn })`