# Upstream Catalog: Every File in `/etc/nixos/external/awesome/upstream/`

**Stock baseline:** `/nix/store/i471f23q1hfyzk47j7wylacvgi2m4jx2-awesome-git-2024-12-08/share/awesome/lib/`  
**AwesomeWM version:** 4.3  

## Legend

| Tag | Meaning |
|-----|---------|
| **IDENTICAL** | File is byte-for-byte identical to stock |
| **COSMETIC ONLY** | File differs only in stylua formatting + doc comment replacement (`--@DOC_` placeholders). **Zero behavioral impact.** |
| **BEHAVIORAL** | File contains actual code changes that affect runtime behavior. Details below. |

---

## Files With Behavioral Changes

### 1. `awful/util.lua` — **BEHAVIORAL**

**4 new functions added** (not present in stock at all):

1. **`function util.dpi(x)`** (line 540) — Re-exports `beautiful.xresources.apply_dpi(x)`. Provides DPI-aware pixel scaling without requiring `beautiful` import in calling code. Body: `return require("beautiful").xresources.apply_dpi(x)`

2. **`function util.color_alpha(color, alpha)`** (line 551) — Appends a 2-hex-digit alpha value to a 6-hex-digit color string. Shortcut for the `beautiful.fg .. "88"` pattern. Strips leading `#` from input and produces `#RRGGBBAA` output.

3. **`function util.config_path(...)`** (line 560) — Resolves a path under `~/.config/awesome/` from relative path components. Avoids hardcoded `/home/user/` paths in UI code. Uses `os.getenv("HOME")`.

4. **`function util.timed(threshold_ms, fn)`** (line 572) — Profiling wrapper. Returns a callable metatable that times `fn`, logging via `print()` if execution exceeds `threshold_ms` (default 16ms / ~1 frame at 60fps). Uses `debug.getinfo` for source location. Supports `gdebug.elapsed_ms` if available, falls back to `os.clock()`.

---

### 2. `awful/widget/layoutbox.lua` — **BEHAVIORAL**

**Structural and behavioral changes:**

1. **Tooltip dependency removed** — `require("awful.tooltip")` replaced with `local dpi = beautiful.xresources.apply_dpi`. The tooltip (`w._layoutbox_tooltip`) and its associated `:set_text()` call are deleted.

2. **Widget construction changed** — From declarative table with `id = "imagebox"` / `id = "textbox"` pattern to explicit constructors with stored references and a margin wrapper.

3. **`dpi(4)` margin added** — The imagebox is now wrapped in a `wibox.container.margin` with `dpi(4)` on all sides.

4. **Nil-safe screen access** — `local w = boxes[screen]` changed to `local w = boxes and boxes[screen]`.

5. **`set_text` method removed** — No longer calling `w._layoutbox_tooltip:set_text(name or "[no name]")` in the update function.

---

### 3. `awful/keyboard.lua` — **BEHAVIORAL**

**Refactored function structure:**

1. **New `append_keybindings(keys, cb)` helper function** — Extracts the common pattern of iterating keys and applying a callback.

2. **`module.append_global_keybindings(keys)` refactored** — Now calls `append_keybindings` instead of directly calling `capi.root._append_keys(keys)`.

3. **`module.append_client_keybindings(keys)` refactored** — Same pattern with the client keybinding loop.

Behavioral impact: ZERO — pure refactoring.

---

### 4. `wibox/widget/imagebox.lua` — **BEHAVIORAL**

**Significant feature removal and simplification:**

1. **`gears.filesystem` require removed** — No longer needed.
2. **`policies_to_extents` table removed** — Cairo pattern extent mapping deleted.
3. **`stylesheet_cache` removed** — SVG stylesheet caching system eliminated.
4. **`imagebox._load_rsvg_handle(file, style)` → `local function load_rsvg_handle(file)`** — Changed from public method to module-local; `style` parameter removed; per-style-ref caching replaced with simple per-file caching.
5. **`imagebox._get_stylesheet(self, content_or_path)` ENTIRE FUNCTION REMOVED** (~25 lines).
6. **`imagebox:set_stylesheet(value)` ENTIRE METHOD REMOVED** (~20 lines).
7. **`image_loader(file, ib._private.stylesheet_og)` → `image_loader(file)`** — Stylesheet argument removed.
8. **`get_source_width` / `get_source_height` accessors REMOVED** — The loop `for _, dim in ipairs { "width", "height" } do imagebox["get_source_"..dim] = ... end` was deleted.
9. **Pattern extent handling REMOVED from drawing code** — `policies_to_extents` block replaced with simple `cr:set_source_surface(self._private.image, 0, 0)`.
10. **`"cover"` fit policy ADDED** — New branch for `math.max(width / w, height / h)` in drawing logic.
11. **`"stylesheet"` added to property signal loop** — Now emits `property::stylesheet`.
12. **`set_stylesheet` / `_get_stylesheet` related private fields removed** — `_private.stylesheet`, `_private.stylesheet_og`, `_private.original_image` handling is gone.

---

### 5. `awful/completion.lua` — **BUILD-SYSTEM CHANGE**

**`bashcomp_src` path restored to build placeholder:**
- Stock: `local bashcomp_src = "/nix/store/.../etc/bash_completion"` (Nix store path)
- Upstream: `local bashcomp_src = "@SYSCONFDIR@/bash_completion"` (build placeholder)

Also: `if src then bashcomp_src = src end` changed to `bashcomp_src = src` (unconditional assignment), which could affect default handling.

---

## Files That Are COSMETIC ONLY

All remaining files differ from stock ONLY in:
- **StyLua formatting** (spacing, indentation, line wrapping, comma placement)
- **Doc comment replacements** (inline examples replaced with `--@DOC_..._EXAMPLE@` placeholders)
- **Trailing commas** in table constructors (zero behavioral impact in Lua)
- **Single quotes → double quotes** on `'k'` → `"k"` in `__mode` entries
- **Semicolons → commas** in table separators in init.lua re-export files
- **`true` → `glib.SOURCE_CONTINUE`** in gears/timer.lua (identical value, no behavioral change)

### Semantically IDENTICAL files (0 behavioral change, confirmed via semantic normalization):

| File | File | File |
|------|------|------|
| `awful/dbus.lua` | `awful/ewmh.lua` | `awful/hotkeys_popup/init.lua` |
| `awful/hotkeys_popup/keys/init.lua` | `awful/layout/suit/fair.lua` | `awful/remote.lua` |
| `awful/rules.lua` | `awful/wibox.lua` | `awful/widget/button.lua` |
| `awful/widget/graph.lua` | `awful/widget/launcher.lua` | `awful/widget/progressbar.lua` |
| `awful/widget/textclock.lua` | `beautiful.lua` | `gears/math.lua` |
| `gears/protected_call.lua` | `menubar/icon_theme.lua` | `menubar/index_theme.lua` |
| `naughty/init.lua` | `naughty.lua` | `naughty/widget/_default.lua` |
| `ruled/init.lua` | `wibox/layout/constraint.lua` | `wibox/layout/margin.lua` |
| `wibox/layout/mirror.lua` | `wibox/layout/rotate.lua` | `wibox/layout/scroll.lua` |
| `wibox/widget/background.lua` | `wibox/widget/textclock.lua` | |

### COSMETIC ONLY (stylua + doc replacements):

`awful/autofocus.lua`, `awful/button.lua`, `awful/client/focus.lua`, `awful/client.lua`, `awful/client/shape.lua`, `awful/client/urgent.lua`, `awful/_compat.lua`, `awful/hotkeys_popup/keys/firefox.lua`, `awful/hotkeys_popup/keys/qutebrowser.lua`, `awful/hotkeys_popup/keys/termite.lua`, `awful/hotkeys_popup/keys/tmux.lua`, `awful/hotkeys_popup/keys/vim.lua`, `awful/hotkeys_popup/widget.lua`, `awful/init.lua`, `awful/keygrabber.lua`, `awful/key.lua`, `awful/layout/init.lua`, `awful/layout/suit/corner.lua`, `awful/layout/suit/floating.lua`, `awful/layout/suit/init.lua`, `awful/layout/suit/magnifier.lua`, `awful/layout/suit/max.lua`, `awful/layout/suit/spiral.lua`, `awful/layout/suit/tile.lua`, `awful/menu.lua`, `awful/mouse/client.lua`, `awful/mouse/drag_to_tag.lua`, `awful/mouse/init.lua`, `awful/mouse/resize.lua`, `awful/mouse/snap.lua`, `awful/permissions/_common.lua`, `awful/permissions/init.lua`, `awful/placement.lua`, `awful/popup.lua`, `awful/prompt.lua`, `awful/root.lua`, `awful/screen.lua`, `awful/screen/dpi.lua`, `awful/screenshot.lua`, `awful/spawn.lua`, `awful/startup_notification.lua`, `awful/tag.lua`, `awful/titlebar.lua`, `awful/tooltip.lua`, `awful/wallpaper.lua`, `awful/wibar.lua`, `awful/widget/calendar_popup.lua`, `awful/widget/clienticon.lua`, `awful/widget/common.lua`, `awful/widget/init.lua`, `awful/widget/keyboardlayout.lua`, `awful/widget/layoutlist.lua`, `awful/widget/only_on_screen.lua`, `awful/widget/prompt.lua`, `awful/widget/taglist.lua`, `awful/widget/tasklist.lua`, `awful/widget/watch.lua`, `beautiful/gtk.lua`, `beautiful/init.lua`, `beautiful/theme_assets.lua`, `beautiful/xresources.lua`, `gears/cache.lua`, `gears/color.lua`, `gears/debug.lua`, `gears/filesystem.lua`, `gears/geometry.lua`, `gears/init.lua`, `gears/matcher.lua`, `gears/matrix.lua`, `gears/object.lua`, `gears/object/properties.lua`, `gears/shape.lua`, `gears/sort/init.lua`, `gears/sort/topological.lua`, `gears/string.lua`, `gears/surface.lua`, `gears/table.lua`, `gears/timer.lua`, `gears/wallpaper.lua`, `menubar/init.lua`, `menubar/menu_gen.lua`, `menubar/utils.lua`, `naughty/action.lua`, `naughty/constants.lua`, `naughty/container/background.lua`, `naughty/container/init.lua`, `naughty/core.lua`, `naughty/dbus.lua`, `naughty/layout/box.lua`, `naughty/layout/init.lua`, `naughty/layout/legacy.lua`, `naughty/list/actions.lua`, `naughty/list/init.lua`, `naughty/list/notifications.lua`, `naughty/notification.lua`, `naughty/widget/icon.lua`, `naughty/widget/init.lua`, `naughty/widget/_markup.lua`, `naughty/widget/message.lua`, `naughty/widget/title.lua`, `ruled/client.lua`, `ruled/notification.lua`, `wibox/container/arcchart.lua`, `wibox/container/background.lua`, `wibox/container/border.lua`, `wibox/container/constraint.lua`, `wibox/container/init.lua`, `wibox/container/margin.lua`, `wibox/container/mirror.lua`, `wibox/container/place.lua`, `wibox/container/radialprogressbar.lua`, `wibox/container/rotate.lua`, `wibox/container/scroll.lua`, `wibox/container/tile.lua`, `wibox/drawable.lua`, `wibox/hierarchy.lua`, `wibox/init.lua`, `wibox/layout/align.lua`, `wibox/layout/fixed.lua`, `wibox/layout/flex.lua`, `wibox/layout/grid.lua`, `wibox/layout/init.lua`, `wibox/layout/manual.lua`, `wibox/layout/ratio.lua`, `wibox/layout/stack.lua`, `wibox/widget/base.lua`, `wibox/widget/calendar.lua`, `wibox/widget/checkbox.lua`, `wibox/widget/graph.lua`, `wibox/widget/init.lua`, `wibox/widget/piechart.lua`, `wibox/widget/progressbar.lua`, `wibox/widget/separator.lua`, `wibox/widget/slider.lua`, `wibox/widget/systray.lua`, `wibox/widget/textbox.lua`

---

## Summary Statistics

| Category | Count |
|----------|-------|
| **Total files in upstream/** | **163** |
| **IDENTICAL** (byte-for-byte) | 13 |
| **COSMETIC ONLY** (stylua + doc refs) | 145 |
| **BEHAVIORAL** (actual code changes) | 5 |

### The 5 files with real code changes:

| File | Change Type | Risk |
|------|-------------|------|
| `awful/util.lua` | **ADDITIONS** — 4 new utility functions | Low — pure additions, no existing code modified |
| `awful/widget/layoutbox.lua` | **MODIFICATIONS** — Tooltip removed, dpi margins, widget refs | Medium — tooltip removed, widget structure changed |
| `awful/keyboard.lua` | **REFACTOR** — `append_keybindings` shared helper | Low — behavior-preserving |
| `wibox/widget/imagebox.lua` | **REMOVALS + ADDITIONS** — Stylesheet system gutted, SVG simplified, "cover" added | **High** — `set_stylesheet`, `_get_stylesheet`, `get_source_width/height` removed |
| `awful/completion.lua` | **BUILD PATH** — `@SYSCONFDIR@` restored | Low — affects bash completion sourcing path |

---

## Key Decision Points

1. **Imagebox stylesheet removal is the biggest risk.** If anything in this config or any loaded module calls `imagebox:set_stylesheet(...)` or `imagebox._get_stylesheet(...)`, it will error. `get_source_width()` and `get_source_height()` are also gone.

2. **Layoutbox tooltip removal** — If any code reads `w._layoutbox_tooltip` from a layoutbox widget, it gets `nil`.

3. **`util.dpi()`, `util.color_alpha()`, `util.config_path()`, `util.timed()`** are pure additions — safe.

4. **All other files** are formatted by stylua with doc-comment replacements. Zero behavioral impact.
