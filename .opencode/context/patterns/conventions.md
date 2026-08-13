# AwesomeWM Config — Coding Conventions

*Last analyzed: 2026-08-11. Refresh of the 2026-07-01 analysis. Verified against actual source, not just docs.*

## Project Snapshot

Lua-only AwesomeWM 4.3+ config on NixOS. Entry point `rc.lua` → `require("core")` + `require("bindings")` + `require("ui")`. No build step; no `upstream/` override dir — system-installed AwesomeWM libs are used, with `lib/` prepended to `package.path` for project utilities and vendored modules.

```lua
-- rc.lua (verified)
pcall(require, "luarocks.loader")          -- optional, fails silently
package.path = config_dir .. "/lib/?.lua;.." .. "/lib/?/init.lua;" .. package.path
package.cpath = config_dir .. "/lib/?.so;..." .. package.path
require("core")
require("bindings")
require("ui")
```

---

## 1. Naming Conventions

### Variables & Functions — `snake_case`
Every variable and function is `snake_case`, including locals. Verified across `service/audio/init.lua`, `lib/util/init.lua`, `bindings/*.lua`, `core/*`, `modules/*`.

```lua
local default_sink_volume = 0        -- NOT dsv
local function parse_kv(stdout)      -- local helpers are snake_case
local function get_default()         -- singleton accessor
```

Descriptive names are required — `default_sink_volume`, not `dsv` (per root `AGENTS.md`).

### Module Tables — lowercase noun, methods with colon
Module tables are lowercase singular nouns (`audio`, `util`, `button`, `text_input`, `M`). Public methods are defined with `function module:method()` (colon syntax) and attached to the instance via `gtable.crush`:

```lua
local audio = {}
function audio:get_default_sink_data(callback) ... end
function audio:set_default_sink_volume(value, callback) ... end

-- in new(): gtable.crush(ret, audio, true)
```

Method verb conventions: `get_*` (getters incl. `get_default`), `set_*` (setters, e.g. `set_label`, `set_bg_normal`), `toggle_*` (`toggle_default_sink_mute`), `show`/`hide`/`toggle` on popups. Instantiable widgets expose `new(args)`.

### Constants — `SCREAMING_SNAKE_CASE` for token tables
`modules/style/ui_constants/init.lua` is the canonical example — nested uppercase tables:

```lua
local ui_constants = {
    SPACING = { TINY = dpi(2), SMALL = dpi(6), MEDIUM = dpi(8), ... },
    RADIUS  = { SMALL = 8, MEDIUM = 10, LARGE = 18, XLARGE = 20 },
    ANIMATION = { DURATION_SHORT = 0.3, EASING_DEFAULT = "quadratic", SLIDE_OFFSET = dpi(20) },
    BUTTON  = { BAR_SIZE = dpi(32), ICON_SIZE = dpi(20), ... },
    BORDER  = { THIN = dpi(1), MEDIUM = dpi(1.5) },
    COLORS  = { WHITE = "#FFFFFF", TRANSPARENT_BLACK = "#00000044", ... },
}
```

Exceptions: `local modkey = "Mod4"` (lowercase in `bindings/`) and `local theme_name = "kailash"` (`core/theme/init.lua`). UPPER_SNAKE is reserved for shared token tables, not file-scoped settings.

### Private State — `_private` table
Instance-private data lives in `self._private`, always aliased to `local wp`:

```lua
local function new()
    local ret = wibox.widget({...})
    gtable.crush(ret, button, true)
    local wp = ret._private
    wp.bg_hover = args.bg_hover or beautiful.bg_gradient_recessed
    ...
end

function button:set_bg_normal(color)
    local wp = self._private
    wp.bg_normal = color
    self:set_bg(wp.bg_normal)
end
```

Services that don't need hidden state use direct properties (`ret.default_sink_volume = 0`); complex objects (popups, bluetooth devices, screenshot) always use `_private`.

### AwesomeWM Globals — `capi` table
Native globals are captured into a local `capi` table at the top of the file; files that use globals directly instead add `---@diagnostic disable: undefined-global` as the first line (both patterns seen — `capi` is preferred per `AGENTS.md`):

```lua
-- Preferred (bindings/system.lua, ui/init.lua):
local capi = { awesome = awesome, client = client, screen = screen }

-- Alternative: file-top pragma
---@diagnostic disable: undefined-global
```

### Testing Names — `spec_<module>.lua`
Spec files are `spec_<module>.lua` in `tests/` (e.g. `spec_battery_poll.lua`, `spec_launcher_filter.lua`), named after the production module they cover.

---

## 2. File Organization

### Top-level layout (verified)

```
rc.lua               Entry point — package.path setup, requires core + bindings + ui
core/                Core WM: autostart/, client/, gc/, screen/, tag/, theme/ + init.lua
bindings/            FLAT keybinding files + init.lua aggregator (focus, hardware, launcher,
                     layout, layout_custom, mouse, scratchpad, system, tags, window)
ui/                  Visual components: bar/, lockscreen/, notification/, popups/, tabbar/,
                     titlebar/, wallpaper/ + init.lua orchestrator
modules/             Reusable modules, restructured into 4 families + icon_lookup/ + init.lua
service/             Singleton system services (audio, battery, bluetooth, brightness, caps,
                     network, screenshot, system_info)
lib/                 Utilities + vendored code: dbus_proxy/, util/, inspect.lua, json.lua,
                     wibox/, liblua_pam.so (native) + init.lua aggregator
themes/kailash/      Active theme: theme.lua, icons/, wallpaper/
bin/                 Shell scripts: awmtt-ng.sh (Xephyr tester), showcase.sh
tests/               Pure-Lua unit tests: run.lua, assert.lua, 20× spec_*.lua
```

### Module = directory with `init.lua`
Every module is a directory whose `init.lua` is the entry point and public interface. This applies uniformly to `core/*`, `service/*`, `ui/*`, `modules/widgets/*`, `modules/infra/*`, `modules/style/*`, `lib/*`.

**Exception — flat-file modules:** `bindings/` and `modules/layouts/` use flat `.lua` files with an `init.lua` aggregator (each layout is a single file: `cascade.lua`, `grid.lua`, `mstab.lua`, `thrizen.lua`, etc.).

### Renames since last analysis (verified)
- `configuration/` → **`core/`** (subdirs: autostart, client, gc, screen, tag, theme)
- Keybinds extracted from `core/` to top-level **`bindings/`**
- `upstream/` **removed** — `lib/` is the only path override; system AwesomeWM libs are required
- `modules/` restructured: **infra/** (animations, applet_pages, click_to_hide, page_container, snap_edge), **layouts/** (flat files + widgets/), **style/** (container_styles, crop_surface, shapes, ui_constants), **widgets/** (applet_button, arc_chart, button_patterns, button_styles, calendar, dropdown, hover_button, menu, styled_button, text_input, imagebox.lua), plus **icon_lookup/**
- `tests/` **added** — 20 spec files, custom runner (see §8)

### Aggregators
`core/init.lua`, `bindings/init.lua`, `ui/init.lua`, `modules/init.lua`, `lib/init.lua` all aggregate their children. `modules/init.lua` exports only a curated subset (`hover_button`, `calendar`, `text_input`, `menu`) — direct callers use `require("modules.<path>")` to avoid coupling.

### Known doc drift (do not trust these)
- `CONTRIBUTING.md` still describes `configuration/`, `upstream/`, and `configuration/keybind/` — outdated
- `ui/init.lua` comment says "loaded once at startup by `configuration/init.lua`" — actually `core/init.lua`
- `core/theme/init.lua` comment says "Loaded first in `configuration/init.lua`" — actually `core/init.lua`

---

## 3. Import / Require Grouping

### Order: stdlib → external → project modules
All `require`s are at the top of the file, grouped in three tiers (per `CONTRIBUTING.md`, verified in `service/audio/init.lua`, `ui/init.lua`, `bindings/system.lua`):

```lua
-- 1. stdlib / system bindings
local lgi = require("lgi")
local Gio = lgi.Gio                      -- lgi sub-libs captured right after

-- 2. external AwesomeWM modules
local awful = require("awful")
local wibox = require("wibox")
local gobject = require("gears.object")
local gtable = require("gears.table")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- 3. project-local modules (absolute paths from project root)
local capi = { awesome = awesome, client = client }
local hotkeys_popup = require("ui.popups.hotkeys_popup")
local util = require("lib.util")
```

### Submodule access
Submodules use dot notation in the require string — `require("gears.timer")`, `require("gears.filesystem")`, `require("lib.util")`. Two access styles coexist:
- **Full submodule require**: `local gtimer = require("gears.timer")` then `gtimer.delayed_call(...)`
- **Root require + field**: `local gears = require("gears")` then `gears.timer({...})`

Both are used; full submodule requires are more common in services/UI.

### `local` everything
No bare globals. Every require is assigned to a `local`. This is enforced and consistent across the codebase.

---

## 4. Module Patterns

Three archetypes (verified in source + `CONTRIBUTING.md`):

### A. Singleton (services & popups) — `gobject` + `gtable.crush` + `get_default`
Archetype: `service/audio/init.lua` (also `service/battery`, `ui/popups/*`, `service/network`).

```lua
local instance
local function new()
    local ret = gobject({})                 -- gears.object
    gtable.crush(ret, audio, true)          -- methods from module table
    ret.default_sink_volume = 0             -- init state
    pcall(function() ret:get_default_sink_data() end)  -- non-fatal kick-off
    return ret
end
local function get_default()
    if not instance then instance = new() end
    return instance
end
return { get_default = get_default }        -- ONLY export
```

Callers: `require("service.audio").get_default()`. Services use `gears.timer` for periodic refresh (`battery` polls on a 15s timer). Popups additionally implement `show()`/`hide()`/`toggle()` and a `_private.shown` flag.

### B. Instantiable widget — `setmetatable({ new = new }, { __call = ... })`
Archetype: `modules/widgets/hover_button/init.lua` (also `text_input`, `calendar`, `menu`).

```lua
local function new(args)
    args = args or {}
    local ret = wibox.widget({ ... })       -- declarative widget tree
    gtable.crush(ret, button, true)
    local wp = ret._private                 -- per-instance state
    ...
    return ret
end

return setmetatable({
    new = new,
}, {
    __call = function(_, ...) return new(...) end,
})
```

Usage: `local btn = hover_button { label = "Click Me", ... }` (call syntax) or `hover_button.new(args)`.

### C. Utility library / infrastructure — plain table, `return M`
Archetype: `lib/util/init.lua` (`return util`), `modules/infra/animations/init.lua` (`local M = {}` … `return M`). Pure functions, no state, no `new()`:

```lua
local util = {}
function util.create_markup(text, args) ... end
function util.dpi(x) return require("beautiful").xresources.apply_dpi(x) end
return util
```

`modules/layouts/*.lua` are a sub-variant: return a table with `name` + `arrange(p)`, registered via `modules/layouts/init.lua` and `common.register_custom_layouts()`.

### Widget construction — declarative tables
Widgets are built with nested declarative tables using the `widget =` key, `id` for later lookup via `:get_children_by_id("id")[1]`, `dpi()` for all dimensions (see §7).

---

## 5. Error Handling

Dominant style: **guarded exceptions** — `pcall` for non-fatal, `assert` for fail-fast. No Result types, no error classes.

| Pattern       | Use                                                      | Example                                                                                                            |
| ------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `pcall`         | Non-fatal operations that must not break awesome startup | initial audio polls, bar creation per-screen, `pcall(require, "luarocks.loader")`, `gobject` fallback in dbus services |
| `assert`        | Critical operations that should fail loudly              | `assert(inspect(tbl, { indent = "\t" }))`, `assert(io.open(file, "w"))` in `lib/util.table_to_file`                      |
| Guard clauses | Early return on nil/invalid                              | `if not c then return end`, `if not raw then return nil end`                                                           |
| nil-safety    | `tonumber()` guards, `and`/`or` defaults                       | `tonumber(raw:match("/%s+(%d+)%%"))` returns nil → state change skipped                                              |

```lua
-- service/audio/init.lua — non-fatal init wrapped in pcall
pcall(function()
    ret:get_default_sink_data()
end)

-- lib/util/init.lua — fail-fast serialization
local inspected = assert(inspect(tbl, { indent = "\t" }))
local wfile = assert(io.open(file, "w"))
```

### Error signals
Async errors propagate via dedicated signals rather than exceptions: `brightness::error` (emitted with `stderr or reason`).

### Explicit error reporting
`ui/init.lua` wraps per-screen bar creation in `pcall` and surfaces failure as a `naughty.notification({ urgency = "critical", ... })`.

### Spawn discipline (NixOS)
Never `os.execute()` / `io.popen()` in production code. Use `awful.spawn.with_shell(...)` (PATH-resolved — required on NixOS) or `awful.spawn.easy_async_with_shell(...)` for async reads. `io.popen` appears only in the test runner's spec discovery (`tests/run.lua`), which is pure Lua.

---

## 6. Signal Naming Conventions

Three signal namespaces (verified via full grep of `emit_signal` calls):

### `entity::event` — service/domain events
`entity::event`, where the entity is the service or subsystem and the event is a verb or short noun. Multi-word events use `-` (not `::`):

```
default-sink::volume          default-sink::mute          (service/audio)
default-source::volume        default-source::mute
device::state                                              (service/network)
window_switcher::turn_on      window_switcher::turn_off   (bindings/system)
launcher::power-clicked                                    (ui/popups/launcher)
lockscreen::visible                                        (ui + bindings + lockscreen)
layout::changed:next          layout::changed:prev        (bindings/layout)
brightness::updated           brightness::error           (service/brightness)
```

### `property::name` — object property changes
Emitted on `gears.object` instances when a state property changes, always with the new value. `property::shown` is the universal popup visibility signal (drives mutual exclusion):

```
property::shown               property::level      property::is_charging
property::powered             property::blocked    property::paired
property::cpu_usage           property::gpu_usage  property::state
property::connections         property::access-points
property::image               property::clip_shape (wibox widgets)
```

### `widget::*` — wibox redraw/layout hints
`widget::redraw_needed`, `widget::layout_changed` (from `modules/widgets/imagebox.lua`, titlebar buttons, layouts navigator).

### Verbs and dashes
- State transitions: `saved`, `canceled`, `annotated`, `deleted` (service/screenshot) — past-tense, emitted *after* the fact
- Add/remove: `connection-added`, `connection-removed`, `device-added`, `device-removed`, `access-point-added` (D-Bus mirrors)

### Rules
1. Emit **only on change** — cache last value, compare before emitting (`if self.default_sink_volume ~= volume then self:emit_signal(...) end`)
2. Connect via `connect_signal`; cross-module wiring happens in `ui/init.lua` (e.g. launcher's `launcher::power-clicked` → `powermenu:show()`)
3. Popup mutual exclusion: each popup emits `property::shown`; `ui/init.lua` listens and hides all others when one shows
4. Legacy/irregular: `signal::peripheral::caps::state` (service/caps) is the one multi-`::` name — do not copy this pattern

---

## 7. Theme & Styling Conventions

### Theme access — `beautiful` only
All colors/fonts/icons come from `beautiful.*`, defined in `themes/kailash/theme.lua`. Active theme is selected in `core/theme/init.lua` via `local theme_name = "kailash"` → `beautiful.init(...)`.

### DPI scaling — always `dpi()`
Every pixel measurement goes through `dpi()` (bound once at file top):

```lua
local dpi = beautiful.xresources.apply_dpi
-- usage: dpi(12), dpi(450), theme.useless_gap = dpi(5)
```

`lib.util.dpi` is the lazy-require variant for modules loaded before `beautiful` is ready.

### Colors — 8-char hex alpha
- Base palette: `theme.bg = "#1c1c1c"`, `theme.fg = "#f7f1ff"`, Monokai Pro Spectrum accents (`red "#fc618d"`, `green "#7bd88f"`, …)
- Alpha via hex suffix concatenation: `beautiful.bg .. "99"` ≈ 60%, `bg .. "cc"` ≈ 80%, `"#00000044"` semi-transparent
- Popup backdrops are fully transparent (`"#00000000"` — picom provides blur/tint)
- Gradients: `"radial:"` / `"linear:"` prefixed strings with embedded hex

### Icons — `theme.text_icons` Nerd Font glyphs + SVG recolor
- `theme.text_icons` table maps snake_case names (`arrow_down`, `bell_off`, `vol_on`, `search`, …) to Nerd Font glyphs
- SVG icons in `themes/kailash/icons/`, recolored at load via `gears.color.recolor_image(icon_path, theme.fg)`

### Shared style tokens — `modules/style/ui_constants`
Spacing/radius/animation/border tokens centralized in `modules/style/ui_constants/init.lua` (SPACING, RADIUS, ANIMATION, BUTTON, BORDER, COLORS). Other style helpers: `modules/style/shapes` (rounded-rect shapes), `modules/style/container_styles`, `modules/style/button_styles`.

### Widget styling
- Declarative nested widget tables with `widget =` key; `wibox.widget({ widget = wibox.container.background, bg = ..., { ... } })`
- `shape = shapes.rrect(10)` style closures
- Widget-specific theme vars: `beautiful.text_input_*`, `beautiful.bg_gradient_button`, `beautiful.bg_gradient_recessed`
- Popup content bg uses alpha colors; popup shell itself `bg = "#00000000"`

---

## 8. Testing Conventions ⚠️ UPDATED — pure-Lua unit suite now exists

**The previous conventions doc said "No unit tests" — that is WRONG as of 2026-07-13.** There is now a complete pure-Lua test suite: **20 spec files, 218 tests, all passing** (verified by running `lua tests/run.lua` — 218 passed, 0 failed, exit 0). It runs with zero X-server/awesome dependencies.

### Runner — custom, no busted/luaspec
`tests/run.lua` is a ~110-line hand-rolled runner: discovers `tests/spec_*.lua`, loads each with `loadfile`, calls it with `pcall(fn, runner)`, and aggregates results.

```lua
-- spec files receive the runner as a vararg (NOT a require):
local assert = require("tests.assert")
local runner = ...

runner.describe("caps:parse_caps_state", function()
    runner.it("returns true when 'Caps Lock on' is present", function()
        assert.eq(parse_caps_state("Current default flags:  NumLock off\nCaps Lock on"), true)
    end)
end)
```

Exit code: `os.exit(results.failed > 0 and 1 or 0)` — CI-safe. `package.path` is set up so `require("tests.assert")` and `require("<project module>")` both resolve from the repo root.

### Assertions — `tests/assert.lua`
Six assertion helpers, all taking an optional message:

| Helper                                           | Meaning                                           |
| ------------------------------------------------ | ------------------------------------------------- |
| `assert.eq(actual, expected[, msg])`               | equality (dominant — used for ~90% of assertions) |
| `assert.truthy(v[, msg])` / `assert.falsy(v[, msg])` | truthiness                                        |
| `assert.errors(fn[, pattern][, msg])`              | fn must raise, optionally matching a Lua pattern  |
| `assert.type(v, "table"[, msg])`                   | Lua type check                                    |
| `assert.has(t, key[, msg])`                        | table has key                                     |

### Mocking — `package.loaded` stubbing (no framework)
Modules with runtime deps are stubbed *before* requiring production code by pre-populating `package.loaded`:

```lua
-- spec_battery_poll.lua (verified)
package.loaded["awful"] = { spawn = { easy_async_with_shell = function() end } }
package.loaded["gears.object"] = setmetatable({}, {
    __call = function(_, t)      -- fake gobject with no-op signal methods
        local obj = t or {}
        function obj:connect_signal() end
        function obj:emit_signal() end
        return obj
    end,
})
package.loaded["gears.table"] = { crush = function(t, m) ... return t end }
```

`os.getenv` monkey-patching is used for `$HOME`-dependent code (`spec_util_overlay.lua`).

### Three extraction techniques for testing local functions
Production helpers are often `local function`s — specs use one of:

1. **Mirror** (simplest): copy the pure algorithm into the spec (spec_caps_state, spec_lib). Fast, but duplicates logic.
2. **Source-rewrite** (used when mirroring is too big): read the production file, `gsub` `local function parse_kv(line)` → `M.parse_kv = function(line)`, inject `local M = {}`, insert an early `return M` after the target function to short-circuit shell-spawn/timer code — then `load()` + `pcall()` the chunk (spec_battery_poll, spec_launcher_filter, spec_text_input, spec_audio_poll).
3. **Direct require**: when the module has no runtime deps, require it straight from the repo (`spec_util_overlay.lua` requires `lib.util`).

### Spec file conventions
- Location: `tests/spec_<module>.lua` — one spec per production module (battery, caps, launcher filter, text_input, hover_button, snap_edge, shapes, json, inspect, animations, click_to_hide, menu, ui_constants, layouts_utils, screenshot, icon_lookup, timed, lib, util_overlay, audio_poll)
- Suite naming: `runner.describe("<module>:<function>", ...)` — e.g. `"caps:parse_caps_state"`, `"lib.util.color_alpha"`
- Test naming: full behavior sentences — `"returns true when 'Caps Lock on' is present"`, `"appends alpha to 6-digit hex"` — not "should" / "works correctly"
- Each spec documents *why* the technique was chosen in its header comment

### Running
```bash
lua tests/run.lua          # full suite (218 tests) — pure Lua, no X server
stylua --check .           # formatting gate
awesome -c rc.lua --check  # syntax gate (requires awesome installed)
```

### CI — `.github/workflows/check.yml`
Three parallel jobs on push to `main` / every PR:
1. **syntax-check**: `sudo apt-get install awesome awesome-extra` → `awesome -c rc.lua --check`
2. **stylua-lint**: download StyLua binary → `stylua --check .`
3. **unit-tests**: `apt-get install lua5.2` → `lua tests/run.lua`

Coverage tooling: none. Manual Xephyr testing (`./bin/awmtt-ng.sh start/restart/stop`) remains the integration-test layer.

---

## 9. Formatting (source of truth: `.stylua.toml`, verified)

| Setting      | Value                                                                                                                         |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| Indentation  | 4 spaces                                                                                                                      |
| Column width | 80 (one exception: a 160+ char concatenation in `text_input/init.lua` line 108 — not to be copied)                              |
| Line endings | Unix (LF)                                                                                                                     |
| Quotes       | double preferred (`AutoPreferDouble`)                                                                                           |
| Syntax       | Lua52                                                                                                                         |
| Formatter    | `stylua .` — run before committing                                                                                              |
| Linter       | `lua-language-server` with `.luarc.json` (library: `/usr/share/awesome/lib/`, `lua5.1`/`lua5.2` dirs; `diagnostics.globals: ["awesome"]`) |

Brace style: `function foo()` … `end` on own line; tables wrapped with trailing commas (StyLua-enforced). Section separators `-- ====...` used in larger modules (`animations/init.lua`).

---

## 10. Documentation Style

- **LDOC annotations** on all public functions: `---` one-liner, then `-- @tparam`, `-- @treturn`, `-- @module`, `-- @field`, `-- @see`, `-- @table`. Renders to docs via LDOC (per CONTRIBUTING.md). Recent commits show an ongoing "docs(...): LDOC for all public APIs" effort.
- **Header block** per module: `--- Module name.` + descriptive paragraphs + `-- @module <path>`
- **Usage block comments**: `--[[ ... --]]` for rich usage examples (hover_button, animations quick-start)
- **Comment density**: moderate — logic-commenting, not line-by-line. Complex regexes/parsers always get a "why" comment. Warnings about surprising behavior are explicit (`color_alpha` additive alpha in spec_util_overlay).
- **Per-directory `AGENTS.md`**: every top-level dir and most subdirs carry one (purpose, key files, patterns, agent guidance). Some are stale (see drift notes in §2).
- README is a symlink to `.github/README.md`; CONTRIBUTING.md exists but has drift.

---

## 11. Git & CI Conventions

- **Branch**: single `main` (origin/main)
- **Commit style**: mostly Conventional Commits with scope — `docs(modules/hover_button): LDOC`, `docs+test(ui/popups/launcher): LDOC for all public methods and filter_apps tests` — plus some timestamped auto-commits (`2026-08-05 02:52:27`, `om sync: auto-update`)
- **CI**: 3 gates on push/PR (syntax, stylua, unit tests) — see §8
- **Mirror**: `.github/workflows/codeberg_mirror.yml` pushes to Codeberg
- **.gitignore**: minimal — `*.log`, `.luarc.json`, `.opencode/state/`, `.opencode/cache/`, `evals/**/state/`
- **No git hooks**, no PR template detected

---

## Quick Reference — New Code Must Follow

1. `snake_case` everything; SCREAMING_SNAKE token tables; `_private`/`wp` for instance state; `capi` for globals
2. Module = `dir/init.lua`; requires grouped stdlib → external → project at top, all `local`
3. Singleton services: `gobject({})` + `gtable.crush(ret, module, true)` + `get_default()`; instantiable widgets: `setmetatable({ new = new }, { __call = ... })`
4. `pcall` non-fatal, `assert` critical, guard clauses, emit error signals for async failures
5. Signals: `entity::event` (dash-separated words) or `property::name`; emit only on change
6. `dpi()` every pixel; `beautiful.*` for all theme values; alpha via 8-char hex; tokens from `modules.style.ui_constants`
7. Pure helpers get unit tests in `tests/spec_<module>.lua` using `tests.assert` + `package.loaded` stubbing + one of the three extraction techniques
8. `stylua .` before commit; CI enforces `awesome --check` + `stylua --check` + `lua tests/run.lua`

<!-- MANUAL: Add manual convention notes below this line -->
