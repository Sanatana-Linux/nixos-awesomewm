# AwesomeWM Config Architecture

<!-- Generated: 2026-07-01 | Updated: 2026-07-01 -->

## Module Boundaries

| Layer | Path | Responsibility |
|-------|------|----------------|
| **Core** | `configuration/` | WM lifecycle: autostart, theme loading, tag management, client rules, keybinds, screen setup |
| **UI** | `ui/` | Visual shells: bar, popups (11 types), lockscreen (PAM), notifications, titlebar, tabbar, wallpaper |
| **Reusable Widgets** | `modules/` | Shared: animations, calendar, dropdown, shapes, text_input, snap_edge, page_container, icon-lookup, hover_button |
| **Services** | `service/` | System backends — each is a singleton gobject with signal emission (audio, battery, bluetooth, brightness, network, screenshot, caps, system_info, garbage_collection) |
| **Lib** | `lib/` | Utilities: `dbus_proxy` (D-Bus wrapper), `json`, `inspect`, `create_markup()`, `liblua_pam.so` native module |
| **Upstream** | `upstream/` | Modified AwesomeWM builtins — awful/, beautiful/, gears/, wibox/, naughty/, ruled/, menubar/ (171 files) |
| **Theme** | `themes/kailash/` | Monokai Pro Spectrum palette, icon sets |

## Entry Point Chain

```
rc.lua (28 lines)
 ├─ pcall(require, "luarocks.loader")          # Optional luarocks
 ├─ package.path prepend: upstream/?.lua       # Override AwesomeWM builtins
 ├─ package.cpath prepend: lib/?.so            # Native modules (PAM)
 ├─ require("configuration")                   # Load order: autostart → theme → tag → client → keybind → screen
 └─ require("ui")
    ├─ Instantiate all popup singletons         # launcher, powermenu, control_panel, etc.
    ├─ awful.screen.connect_for_each_screen(setup_screen_bar)  # Per-screen bar creation
    ├─ Wire mutual-exclusion signals            # property::shown → hide others
    ├─ Click-away handler (button 1 → hide all)
    └─ require("ui.titlebar") + require("ui.tabbar")
```

## Data Flow — Service → UI

**Two communication backends:**

1. **Shell-based** (audio, battery, brightness): `awful.spawn.easy_async_with_shell()` → parse stdout → store state → `emit_signal("entity::event", value)`
   - Audio: `pactl get-sink-volume` → emits `default-sink::volume`, `default-sink::mute`
   - Battery: `cat /sys/class/power_supply/BAT0/capacity` → emits `property::level`, guarded to fire only on change

2. **D-Bus-based** (network, bluetooth): `lib/dbus_proxy` wraps lgi `GDBusProxy` → connect to `PropertiesChanged` → forward as `property::*` signals
   - Network: NM `StateChanged` → `property::state`
   - Bluetooth: `PropertiesChanged` → `property::connected`, `property::paired`

**UI consumers** (in `ui/popups/control_panel/`):
- `audio_sliders` ← listens to `default-sink::volume` from `service.audio.get_default()`
- `networking_applet` ← `service.network.get_default()` → device/access-point objects with D-Bus proxies
- `bluetooth_applet` ← `service.bluetooth.get_default()` → adapter/device objects
- `brightness_slider` ← `service.brightness.get_default()`

## Key Architectural Patterns

| Pattern | Implementation | Example |
|---------|---------------|---------|
| **Singleton** | `gobject({})` + `gtable.crush(ret, module, true)` + `get_default()` with closure | `service/audio/init.lua` |
| **gobject signals** | `gears.object` constructor → `emit_signal` / `connect_signal` | Every service and popup |
| **capi table** | `local capi = { screen = screen, client = client }` at file top | `ui/init.lua:7` |
| **Private state** | `self._private` table + `local wp = self._private` accessor | `service/network/init.lua:78` |
| **Guard on shown** | Check `wp.shown` before show/hide to prevent double-trigger | ui popups |
| **Upstream override** | Prepend `upstream/` to `package.path` in rc.lua | Requires modded awful/gears/wibox instead of system install |
| **D-Bus proxy** | Custom lib wrapping `lgi.GDBusProxy` | `lib/dbus_proxy/` used by network + bluetooth |
| **Fallback on failure** | `pcall(new)` → fallback empty object if D-Bus unavailable | `service/network/init.lua` |

## Signal Wiring

- **Service signals**: `entity::event` convention (e.g., `default-sink::volume`, `default-sink::mute`)
- **Property signals**: `property::name` convention (e.g., `property::level`, `property::shown`)
- **Mutual exclusion**: Each popup's `property::shown` signal hides all others → only ONE popup visible at a time (wired in `ui/init.lua`)
- **Click-away**: button 1 / client `button::press` → hides ALL popups + emits `lockscreen::visible`

<!-- MANUAL: Add manual architecture notes below this line -->
