# awesome-layouts Skill

> Window layouts and tiling patterns for AwesomeWM 4.3 custom layouts

## Layout Plugin API

All custom layouts use the `awful.layout.suit` plugin API:

```lua
local mylayout = {}
mylayout.name = "mylayoutname"  -- String key for internal references

function mylayout.arrange(p)
    -- p.workarea  → {x, y, width, height} of usable screen area
    -- p.clients    → array of client objects to arrange
    -- p.tag        → the tag being arranged
    -- p.screen     → screen index
    -- p.useless_gap → gap size from theme/awful config
    -- p.geometries → table to fill: p.geometries[client] = {x, y, width, height}
end

-- Optional mouse handlers (rarely used, mostly grid.lua):
-- function mylayout.move_handler(c, context, hints) end
-- function mylayout.mouse_resize_handler(c, corner) end

-- Optional keygrabber support:
-- function mylayout.startup() end
-- function mylayout.cleanup() end
-- function mylayout.key_handler(mod, key, event) end
-- mylayout.tip = {...}  -- hotkey descriptions for navigator
-- mylayout:set_keys(keys, layout) end

-- Optional focus/byidx overrides:
-- mylayout.focus = { byidx = function(i) ... end }
-- mylayout.swap = { byidx = function(i) ... end }
```

The `arrange(p)` function MUST set `p.geometries[c]` for EVERY client in `p.clients`. If a client is missing from `p.geometries`, it won't be placed on screen.

### Tag Properties Used by Layouts

Layouts read these tag properties to determine placement:

| Property | Type | Default | Used By |
|----------|------|---------|---------|
| `t.master_width_factor` (mwfact) | float 0.01-0.99 | 0.6 | mstab, cascade.tile, centerwork, stack, termfair |
| `t.master_count` (nmaster) | int | 1 | mstab, cascade, termfair, thrizen |
| `t.column_count` (ncol) | int | 1 | cascade.tile, termfair |

Access via `awful.tag.incmwfact(delta)`, `awful.tag.incnmaster(delta)`, `awful.tag.incncol(delta)`.

## Layout Registry

Custom layouts are registered in `configuration/tag/init.lua` via:

```lua
capi.tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        layouts.mstab,              -- Master-stack with tabbed slaves
        layouts.cascade,            -- Plain cascade
        layouts.cascade.tile,       -- Master + slave cascade
        layouts.centerwork,         -- Center master, slaves left/right
        layouts.centerwork.horizontal, -- Center top/bottom
        layouts.deck,               -- Cascading deck
        layouts.thrizen,            -- 3-column grid
        layouts.equalarea,          -- Recursive BSP equal areas
        layouts.termfair,           -- Fixed columns, left-to-right fill
        layouts.grid,               -- Floating discrete geometry grid
        layouts.map,                -- User-defined geometry groups
        awful.layout.suit.floating, -- Built-in floating (always last)
    })
end)
```

Layouts aggregator in `modules/layouts/init.lua` requires all modules and registers their handlers/tips via `common.register_custom_layouts(layouts)`.

## Layout-by-Layout Reference

### mstab (`modules/layouts/mstab.lua`)
- **Master-stack** with tabbed slave windows
- Master clients stacked vertically on the left, slaves tabbed on the right
- Creates `screen.tabbar` wibox for slave tabs (top/bottom/left/right position via `beautiful.mstab_tabbar_position` or `beautiful.tabbar_position`)
- Tabbar uses `ui.tabbar` module (`require("ui.tabbar")`)
- Tabbar visibility: hidden for ≤1 slave, adjusts on tag/layout/client changes
- Theme vars: `beautiful.mstab_bar_disable`, `beautiful.mstab_bar_ontop`, `beautiful.mstab_tabbar_position`, `beautiful.mstab_border_radius`, `beautiful.mstab_bar_padding`, `beautiful.mstab_bar_height`, `beautiful.mstab_tabbar_style`, `beautiful.mstab_dont_resize_slaves`, `beautiful.tabbar_position`, `beautiful.tabbar_size`, `beautiful.tabbar_style`
- **Handler:** `tile_handler` (supports mwfact, nmaster, ncol)
- **Tip:** `tile` tip
- **Tag props:** mwfact, master_count, column_count
- **Edge case:** 1 client = fullscreen; 0-1 slaves = delegates to `awful.layout.suit.tile.right.arrange(p)`

### cascade (`modules/layouts/cascade.lua`)
- Two variants: `cascade` (plain) and `cascade.tile` (master+slave)
- **cascade (plain):** Windows cascade diagonally from top-left, each offset by `offset_x` (32px) and `offset_y` (8px). Number of visible offsets clamped to `master_count`.
- **cascade.tile:** Master client on left at `mwfact` width. Slave clients cascade on right with `offset_x=5, offset_y=32`. If `column_count=1`, master overlaps into slave area with `extra_padding` reduction.
- **Handler:** `cascade` → `fair_handler`, `cascade.tile` → `tile_handler`
- **Tip:** `cascade` → `base`, `cascade.tile` → `tile`
- **Tag props:** mwfact, master_count, column_count

### centerwork (`modules/layouts/centerwork.lua`)
- Two variants: `centerwork` (vertical master) and `centerwork.horizontal`
- **centerwork:** Master in center column at `mwfact` width. Slaves fill left and right columns alternately (client 2 = left, 3 = right, 4 = left, etc.), each splitting evenly.
- **centerwork.horizontal:** Master in center row at `mwfact` height. Slaves fill top and bottom rows.
- Custom `:focus.byidx` and `:swap.byidx` for consistent cyclic navigation across spatial layout
- **Mouse resize handler:** `mouse_resize_handler(c, corner, x, y, "vertical"/"horizontal")` — uses `mousegrabber.run()` to dynamically adjust `mwfact` via drag
- **Handler:** `tile_handler`
- **Tag props:** mwfact

### deck (`modules/layouts/deck.lua`)
- Cascading deck of cards. Each client is offset by `(10% / n-1)` of width/height from the previous one.
- All clients get the same reduced size — the top/focused client is visible in full, others peek out from behind
- **Handler:** `fair_handler`
- **Tag props:** none

### thrizen (`modules/layouts/thrizen.lua`)
- **3-column grid** with even distribution. Max 3 columns, rows as needed.
- Last client in second-to-last row gets **double height** if there's room.
- Uses Lua 5.2 `::label::` / `goto continue` syntax — requires `.stylua.toml` `syntax = "Lua52"` to format
- **Handler:** `tile_handler`
- **Tag props:** master_count
- **Config:** `config.max_columns = 3`, `config.min_width = 200`

### equalarea (`modules/layouts/equalarea.lua`)
- **Recursive binary space partitioning (BSP)** — divides screen area so each client gets roughly equal area
- Split direction: if width/height ratio > 1.3 (configurable), split vertically; otherwise horizontally
- Division ratio priority: divisible by 5, then 3, then 2
- Reads `master_width_factor` and `master_count` from tag for master/slave distribution
- Filters out invalid/minimized clients before arrangement
- **Handler:** `fair_handler`
- **Tag props:** mwfact (tracked but not used for area calculation currently), master_count

### termfair (`modules/layouts/termfair.lua`)
- Three variants: `termfair`, `termfair.center`, `termfair.stable`
- **termfair (west):** Fixed number of columns (`master_count`). Windows fill from left to right, then new rows **above** (from top). Good for terminals.
- **termfair.stable:** Same columns, but rows fill **below** (stable ordering — top to bottom then left to right).
- **termfair.center:** When fewer clients than columns, they center. Once full, master gets first column, slaves distribute across remaining columns with at most `ncol` per column.
- **Handler:** `termfair`, `termfair.center` → `tile_handler`; `termfair.stable` → `fair_handler`
- **Tag props:** master_count (= num_x columns), column_count (= min rows per column)
- **Minimum:** at least 2 columns

### stack (`modules/layouts/stack.lua`)
- **DEPRECATED** — use mstab instead
- Two variants: `stack` (right) and `stack.left`
- Master on one side at mwfact, all slaves stacked on the other side (overlapping)
- **Handler:** `tile_handler`
- **Tag props:** mwfact
- All slaves get the same full-height geometry — they stack invisibly

### grid (`modules/layouts/grid.lua`)
- **Floating grid** with discrete geometry snapping. Not a tiling layout — it snaps windows to a configurable grid.
- Grid cell size: `beautiful.cellnum` (default `{x=100, y=60}`)
- Uses `screen.workarea` + `useless_gap` for cell calculation
- Client geometry is rounded to nearest cell boundary via `fit_cell()`:
  ```lua
  local function fit_cell(g, cell)
      local ng = {}
      for k, v in pairs(g) do
          ng[k] = math.ceil(round(v, cell[k]))
      end
      return ng
  end
  ```
- Keygrabber (Mod4+arrows for move, Mod4+h/j/k/l for resize, with Shift for reverse, Control for rail-snapping)
- Rail system snaps to other client edges: `get_rail(c)` collects all x/y edges of visible clients
- **Mouse handler:** `move_handler(c, _, hints)` — snaps dragged windows to grid
- **Mouse resize:** `mouse_resize_handler(c, corner)` — uses `mousegrabber.run()` with `fit_cell`
- **Handler:** `grid.key_handler` → own maingrabber + `common.grabbers.base`
- **Tip:** `grid.tip` (own keys + common base)
- **Tag props:** none

### map (`modules/layouts/map.lua`)
- **User-defined geometry groups** — a tree-based layout where you create named groups (vertical/horizontal) and assign clients to them
- Tree structure: root container holds 2+ child groups, each group is a pack of items (clients or nested groups)
- Groups have `is_vertical` orientation, split direction, and `factor` for proportional sizing
- Keygrabber for group management (Mod4+s=swap, v/b=new vertical/horizontal, d=delete, a=set active, .=switch, etc.) and resize (h/j/k/l, Ctrl+ for group-level)
- Highlight timer: shows navigator highlight on active group
- Notification system via `naughty.notify()`
- Persists state in `map.data[tag]` with weak-reference metatable `setmetatable({}, {__mode="k"})`
- Scheme system: `map.scheme[t]` allows tag-specific tree constructors
- **Handler:** `map.key_handler` → own maingrabber + `common.grabbers.swap` + `common.grabbers.base`
- **Tip:** `map.tip` (own keys + swap + base + _fake)
- **Tag props:** none (uses own scheme)

### navigator (`modules/layouts/navigator.lua`)
- **Not a layout** — a visual overlay widget for keyboard client navigation
- Draws semi-transparent numbered markers on all tiled clients
- Uses per-client overlay wiboxes with Cairo drawing:
  - Checkered background (focused = red, normal = gray, hilight = green)
  - Rounded rectangle with client number (from style.num: 1-9,0,F1,F3,F4,F5)
  - Client dimensions text
- Keygrabber delegates to the active layout's `key_handler` (from `layouts.common.handler[l]`)
- Auto-reopens on new client or minimized changes
- Closes on tag switch
- TL; DR: The navigator is a collaboration between `navigator.lua` (overlay markers + keygrabber launch) and `common.lua` (per-layout key handlers + tips). It is activated by `utils.get_navigator():run()`.

## Keyboard Handler System

Layouts use two distinct key handling approaches:

### Nav-mode keygrabbers (via `common.lua`)

When the navigator runs, it grabs the keyboard and delegates to the layout's handler:

```lua
-- Registered in common.register_custom_layouts()
common.handler[layouts.mstab] = tile_handler
common.handler[layouts.cascade] = fair_handler

-- These handlers chain grabbers:
-- tile_handler: grabbers.tile → grabbers.swap → grabbers.base
-- fair_handler: grabbers.swap → grabbers.base
-- magnifier_handler: grabbers.magnifier → grabbers.base
```

Common grabbers:
| Grabber | Keys | Description |
|---------|------|-------------|
| `base` | Escape, Mod4+Escape, Mod4+Super_L, Mod4+F1, Mod4+c (kill) | Exit and help |
| `swap` | Mod4+arrows | Directional client swap |
| `tile` | Mod4+h/l (mwfact), Mod4+Shift+h/l (nmaster), Mod4+Ctrl+h/l (ncol) | Layout parameter tweaks |
| `corner` | Same as tile + Mod4+g (set master) | Corner layout tweaks |
| `magnifier` | Mod4+h/l (mwfact), Mod4+g (set master) | Magnifier tweaks |

The `_fake` grabber provides client number keys (1-9,0) for swap/focus via num key display.

### Layout-own keygrabbers (grid.lua, map.lua)

These layouts override the handler with their own `key_handler`:

```lua
-- grid: own maingrabber + common.base fallback
grid.key_handler = function(mod, key, event)
    if event == "press" then return end
    if grid.maingrabber(mod, key, event) then return end
    if common.grabbers.base(mod, key, event) then return end
end

-- map: own maingrabber + common.swap + common.base fallback
map.key_handler = function(mod, key, event)
    if event == "press" then return end
    if map.maingrabber(mod, key) then return end
    if common.grabbers.swap(mod, key, event) then return end
    if common.grabbers.base(mod, key, event) then return end
end
```

### Hotkey registration (`configuration/keybind/layout_custom.lua`)

Layout-specific keygrabber keys (grid move/resize, map layout/resize) are registered with the hotkeys popup via `build_hotkeys()` → `hotkeys_popup.add_hotkeys()`. This makes them visible in the F1 help even though they're not global keys.

## Mouse Move Handler

`common.mouse.move(c, context, hints)` handles mouse-based client movement in tiled layouts:

```lua
-- 1. Skip if floating or not a mouse.move
-- 2. Move to mouse screen
-- 3. If layout has custom move_handler, use it (e.g., grid)
-- 4. Otherwise, swap with the client under the mouse
```

This allows `grid.move_handler` to grid-snap during mouse drag, while other layouts use simple positional swap.

## Common Patterns

### Layout Module Skeleton

```lua
local screen = screen
local math = math

local mylayout = { name = "mylayout" }

-- Variants: nested tables with .arrange
mylayout.variant = { name = "mylayoutvariant" }
function mylayout.variant.arrange(p)
    return do_arrange(p, "variant")
end

local function do_arrange(p, orientation)
    local t = p.tag or screen[p.screen].selected_tag
    local wa = p.workarea
    local cls = p.clients

    if #cls == 0 then return end

    local mwfact = t.master_width_factor  -- if applicable
    local nmaster = t.master_count         -- if applicable
    local ncol = t.column_count            -- if applicable

    for i, c in ipairs(cls) do
        -- Calculate geometry
        local g = { x = ..., y = ..., width = ..., height = ... }
        p.geometries[c] = g
    end
end

function mylayout.arrange(p)
    return do_arrange(p, "default")
end

return mylayout
```

### Property Access Pattern

```lua
local t = p.tag or screen[p.screen].selected_tag

-- Fallback chain: config default → tag property → hardcoded fallback
local mwfact
if mylayout.mwfact > 0 then
    mwfact = mylayout.mwfact
else
    mwfact = t.master_width_factor
end
```

### Geometry Clamping

```lua
if g.width < 1 then g.width = 1 end
if g.height < 1 then g.height = 1 end
p.geometries[c] = g
```

Always clamp geometries to minimum 1px to avoid AwesomeWM errors.

### Variant Pattern

Layouts expose variants as nested tables with their own `name` and `arrange`:

```lua
cascade.tile = {
    name = "cascadetile",
    nmaster = 0,
    ncol = 0,
    mwfact = 0,
    offset_x = 5,
    offset_y = 32,
    extra_padding = 0,
}
function cascade.tile.arrange(p)
    return do_cascade(p, true)  -- true = tiling mode
end
```

### Floor Division

Use `math.floor()` for pixel-perfect geometry to avoid sub-pixel rendering artifacts:

```lua
local mainwid = floor(wa.width * mwfact)
local slavewid = wa.width - mainwid  -- remaining space, no floor needed
```

## Testing

1. **Syntax check:** `awesome -c rc.lua --check`
2. **Test in nested session:** `./bin/awmtt-ng.sh restart`
3. Switch layouts with Mod4+Space (next) / Mod4+Shift+Space (prev)
4. Test layout-specific properties:
   - Mod4+h/l = change master width factor
   - Mod4+Shift+h/l = change master count
   - Mod4+Ctrl+h/l = change column count
5. Test navigator via the launcher/menu (look for utils.get_navigator():run() binding)
6. Test grid/map-specific keys via their keygrabbers

## Files Reference

| File | Description |
|------|-------------|
| `modules/layouts/init.lua` | Layout aggregator — requires all layouts, calls `common.register_custom_layouts()` |
| `modules/layouts/common.lua` | Shared key handlers, mouse handler, hotkey tips, grabber functions |
| `modules/layouts/mstab.lua` | Master-stack with tabbed slave windows + per-screen tabbar wibox |
| `modules/layouts/cascade.lua` | Cascade + cascade.tile variants |
| `modules/layouts/centerwork.lua` | Centerwork + centerwork.horizontal variants |
| `modules/layouts/deck.lua` | Cascading deck of cards |
| `modules/layouts/thrizen.lua` | 3-column balanced grid (Lua 5.2 syntax) |
| `modules/layouts/equalarea.lua` | Recursive BSP equal-area distribution |
| `modules/layouts/termfair.lua` | Termfair + centerfair + stablefair variants |
| `modules/layouts/stack.lua` | Deprecated master-stack (use mstab) |
| `modules/layouts/grid.lua` | Floating discrete geometry grid (own keygrabber + mouse handlers) |
| `modules/layouts/map.lua` | User-defined geometry groups (own keygrabber + tree-based layout) |
| `modules/layouts/navigator.lua` | Visual keyboard navigation overlay (not a layout) |
| `configuration/tag/init.lua` | Layout registry — `awful.layout.append_default_layouts()` |
| `configuration/keybind/layout.lua` | Global layout keybindings (mwfact, nmaster, ncol, swap, layout switch) |
| `configuration/keybind/layout_custom.lua` | Layout-specific keybinding registration for grid/map hotkeys help |
| `ui/tabbar/` | Tabbar widget used by mstab layout |

## Common Failure Modes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Client invisible after layout switch | Missing from `p.geometries` | Ensure every `p.clients[i]` has a geometry entry |
| Sub-pixel flickering | Float geometry values | Use `math.floor()` on calculated dimensions |
| Tabbar not showing in mstab | Wrong layout name check | Check `awful.layout.getname()` returns "mstab" |
| Grid keys don't work | Wrong Focus | Grid keygrabber only activates when navigator is running on grid layout |
| Navigator keygrabber issues | Missing `handler` entry | Ensure layout is registered in `common.register_custom_layouts()` |
| thrizen has format errors | Lua 5.2 syntax | Add `syntax = "Lua52"` to `.stylua.toml` or exclude file from formatting |
