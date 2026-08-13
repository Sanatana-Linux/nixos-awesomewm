# AwesomeWM Config Architecture

<!-- Generated: 2026-08-11 | Updated: 2026-08-11 (refresh of 2026-07-01 doc) -->

## Module Boundaries

| Layer | Path | Responsibility |
|-------|------|----------------|
| **Core** | `core/` | WM lifecycle: autostart (+GC), theme, tags, client rules, screen setup. Load order: autostart → theme → tag → client → screen (`core/init.lua:10-14`) |
| **Bindings** | `bindings/` | Global+client keybindings (extracted from old `core/keybind/`). Aggregator `bindings/init.lua` loads system, launcher, hardware, window, scratchpad, focus, layout, mouse, tags via `awful.keyboard.append_global_keybindings` |
| **UI** | `ui/` | Visual shells: bar (primary+secondary), popups (launcher, powermenu, control_panel, screenshot_popup, day_info_panel, battery, menu, window_switcher, hotkeys_popup), lockscreen (PAM), notification (+screenshot actions), titlebar, tabbar, wallpaper |
| **Services** | `service/` | System backends — singleton gobjects with signal emission: audio, battery, bluetooth, brightness, caps, network, screenshot, system_info. GC moved OUT to `core/gc/` |
| **Modules** | `modules/` | Reusable widgets, restructured into 4 subdirs: `infra/` (animations, applet_pages, click_to_hide, page_container, snap_edge), `layouts/` (10 custom tiling layouts + `widgets/` navigator/common/utils), `style/` (shapes, ui_constants, container_styles, crop_surface), `widgets/` (menu, text_input, calendar, dropdown, arc_chart, applet_button, hover_button, styled_button, imagebox, button_patterns, button_styles). Plus `icon_lookup/` (memoized icon resolution) |
| **Lib** | `lib/` | Vendored + hand-rolled utilities. `init.lua` aggregator exposes inspect/json/dbus_proxy; `util/` holds hand-rolled helpers (create_markup, dpi, color_alpha, config_path, has_common…); `dbus_proxy/` (D-Bus wrapper); `remote_watch/` (cache-to-file poller); `wibox/layout/overflow.lua` (vendored scrollable layout); `liblua_pam.so` native module |
| **Theme** | `themes/kailash/` | Monokai Pro Spectrum palette |
| **Docs/Tests** | `.documentation/`, `tests/`, `bin/` | Doc index (keybindings, rc.lua, credits); pure-Lua test suite (`lua tests/run.lua`, 20+ spec files); `awmtt-ng.sh` (Xephyr test env) + `showcase.sh` (GIF recording via giph/ffmpeg) |

**Removed:** `upstream/` override dir — `rc.lua:13-17` now prepends only `lib/` to `package.path`, so system-installed AwesomeWM 4.3 libs are used. Vendored code survives as single-file drops under `lib/` (e.g. `lib/wibox/layout/overflow.lua`).

## Entry Point Chain

```
rc.lua (29 lines)
 ├─ pcall(require, "luarocks.loader")          # optional, fails silently
 ├─ package.path prepend: lib/?.lua, lib/?/init.lua   # NOT upstream/
 ├─ package.cpath prepend: lib/?.so            # native modules (PAM)
 ├─ require("core")                            # autostart → theme → tag → client → screen
 │   └─ core/autostart starts core.gc + xautolock (respawns on restart, idempotent via pkill)
 ├─ require("bindings")                        # 9 keybinding modules
 └─ require("ui")
     ├─ Instantiate all popup singletons (get_default())
     ├─ awful.screen.connect_for_each_screen(setup_screen_bar) + "added" hot-plug
     ├─ pcall-guarded bar creation (failure → naughty critical notification)
     ├─ Wire mutual exclusion: property::shown pairs + lockscreen::visible drain
     ├─ Click-away: button 1 / client button::press → hide all + emit lockscreen::visible=false
     └─ require("ui.titlebar") + require("ui.tabbar")
```

## Data Flow — Service → UI

**1. Shell-based** (audio, battery, brightness, caps, system_info): `awful.spawn.easy_async_with_shell()` → parse `key=value` stdout → cache state → conditional `emit_signal` (only on change).
- Audio: single pactl poll reads volume+mute together (`service/audio/init.lua:80-103`) → `default-sink::{volume,mute}`, `default-source::*`
- Battery: one shell loop reads 7 sysfs fields (`service/battery/init.lua:25-34`) → `property::level|is_charging|health|…` on 15s timer
- Brightness: `brightnessctl g`/`m` in one spawn → `brightness::updated|error`
- Caps: `setleds` → `signal::peripheral::caps::state` on the global awesome bus
- system_info: 2s polling timer → `property::*` (cpu/ram/disk/gpu)

**2. D-Bus-based** (network, bluetooth, lockscreen suspend hook): `lib/dbus_proxy` wraps `lgi.GDBusProxy` → `PropertiesChanged`/`StateChanged` forwarded as `property::*`/`entity::*` signals.
- Network: NM client/settings/device/wireless proxies; graceful `create_fallback()` when lgi binding missing (`service/network/init.lua:401-416`)
- Bluetooth: BlueZ Device1+Battery1+Properties proxies per device (`service/bluetooth/init.lua:24-78`)
- **New:** login1 `PrepareForSleep` proxy in `ui/lockscreen/grab_password.lua:120-134` — re-arms the password grab after resume

**3. New hybrid:** `lib/remote_watch/` — polls a shell command, `tee`s output to a cache file, checks mtime to skip re-running (`lib/remote_watch/init.lua:18-71`).

## Key Architectural Patterns

| Pattern | Implementation | Example |
|---------|---------------|---------|
| **Singleton** | `gobject({})` + `gtable.crush(ret, module, true)` + `get_default()` closure | `service/audio/init.lua:167-196` |
| **gobject signals** | `gears.object` → `emit_signal` / `connect_signal` | every service + popup |
| **capi table** | `local capi = { screen = screen, client = client }` | `ui/init.lua:13` |
| **Private state** | `self._private` + `local wp = self._private` | `service/network/init.lua:54`, `ui/popups/powermenu/init.lua:36` |
| **Mutual exclusion** | Two tiers: `modules/infra/click_to_hide` coordinator (exclusive popups + escape keygrabber) AND `ui/init.lua` `property::shown` pairs | `ui/init.lua:115-147` |
| **Fallback on failure** | `pcall(new)` → empty stub object with same surface | `service/network/init.lua:423-433` |
| **Conditional signal emission** | Guard `if self.x ~= new then emit` to avoid no-op UI churn | `service/battery/init.lua:61-65` |
| **D-Bus proxy** | `lib/dbus_proxy` wrapping `lgi.GDBusProxy`, all lgi calls pcall-wrapped | network + bluetooth + login1 |
| **Keygrabber discipline** | Grabber started on show, stopped on hide; drains tracked via click_to_hide | `ui/popups/powermenu/init.lua:35-59` |

## Signal Wiring Conventions

- **Service events**: `entity::event` — `default-sink::volume`, `device::state`, `connection-added`, `saved`/`canceled` (screenshot)
- **Object properties**: `property::name` — `property::level`, `property::shown`, `property::access-points`
- **Global awesome bus**: `lockscreen::visible` (lock/unlock state — emitted by xautolock via awesome-client, ui/init.lua, grab_password; consumed by ui/init.lua + lockscreen), `signal::peripheral::caps::{update,state}`
- **Cross-popup decoupling**: `launcher::power-clicked` → powermenu:show (`ui/init.lua:22-24`)
- **Mutual exclusion** in ui/init.lua: when powermenu/launcher/control_panel/screenshot_popup shows, hide the others; lockscreen visible → hide ALL popups (prevents keygrabber stack leak)

## NEW Patterns Since 2026-07-01

1. **Keygrabber-leak draining** (`ui/lockscreen/grab_password.lua:31-42, 99-109`): `drain_popup_grabbers()` hides all click_to_hide popups + closes the Mod4+F2 navigator so `awful.keygrabber`'s stack empties and the native X grab is released on unlock. Root cause documented in-code (`ui/init.lua:149-161`).
2. **Suspend/resume re-arm** (`grab_password.lua:120-134`): `PrepareForSleep=false` while locked → drain stale grabbers, re-run `grab_password()` (suspend drops the native X grab but not the Lua stack).
3. **Scratchpad** (`core/client/scratchpad.lua` + `bindings/scratchpad.lua`): single-slot client buffer — `add` parks focused client (`hidden=true`, `tags({})`), `toggle` re-attaches to current tag; `unmanage` clears the buffer.
4. **GC service** (`core/gc/init.lua`): dual-pass `collectgarbage` gated by memory-growth (1.05×) or 300s idle; `start()/stop()/get_stats()/force_collect()/configure()`.
5. **click_to_hide coordinator** (`modules/infra/click_to_hide/init.lua`): registry of popups/menus with `exclusive` + `enable_escape` opts; centralized hide-all/active tracking replacing pure per-popup wiring.
6. **Layout navigator** (`modules/layouts/widgets/navigator.lua`): Mod4+F2 overlay with per-layout `key_handler`/`startup`/`cleanup` hooks; layouts register via `widgets/common.lua:register_custom_layouts`.
7. **Icon lookup** (`modules/icon_lookup/`): prioritized resolution (theme map → DesktopAppInfo → client icon → Colloid-Dark fallback), memoized in `icon_cache`.
8. **remote_watch** (`lib/remote_watch/`): mtime-cached shell polling.
9. **Notification action buttons** (`ui/notification/screenshots/init.lua`): `naughty.action` (view/open/copy/annotate) wired to screenshot service signals.
10. **Bar-creation hardening** (`ui/init.lua:58-96`): pcall + `io.stderr` debug logging + critical naughty notification on failure.
11. **showcase.sh** (`bin/showcase.sh`): giph→ffmpeg→gifsicle pipeline for `.github/assets/showcase/` GIFs.
12. **lib/ split**: vendored aggregator (`lib/init.lua`) vs hand-rolled `lib/util/` — clears the old ambiguity of mixed responsibilities.
13. **system_info service**: 2s polling, CPU delta tracking (replaces one-shot reads).
14. **Tests expansion**: spec files now cover infra (click_to_hide, snap_edge, hover_button, timed, util_overlay, audio/battery poll) — pure-Lua, no X server, run via `lua tests/run.lua` in CI.

## Trade-offs / Notes

- Removing `upstream/` gains NixOS-maintained awesome libs + smaller repo, but loses the ability to hot-patch builtins — vendored workarounds must now be single-file drops under `lib/`.
- Two parallel mutual-exclusion mechanisms (click_to_hide + ui/init.lua pairs) risk drift — a popup must register with click_to_hide AND appear in the ui/init.lua hide lists; the lockscreen drain is the safety net.
- `os.clock()` in `lib/util.timed` measures CPU time — fine for perf profiling, but must never be used for throttling (see `.opencode/rules/awesome-audio.md`).

## References
- `rc.lua:13-29` — lib-only package.path, 3-require entry chain
- `core/init.lua:10-14` — core load order
- `bindings/init.lua:23-33` — keybinding module list
- `ui/init.lua:115-172` — mutual exclusion + lockscreen drain
- `ui/lockscreen/grab_password.lua:120-134` — login1 suspend hook
- `core/client/scratchpad.lua:28-73` — park/toggle logic
- `service/network/init.lua:51-61, 401-433` — D-Bus wiring + fallback
- `lib/remote_watch/init.lua:18-71` — mtime-cache polling
- `modules/infra/click_to_hide/init.lua:104-145` — popup coordinator
- `core/gc/init.lua:37-73` — dual-pass GC threshold logic

<!-- MANUAL: Add manual architecture notes below this line -->
