# modules/layouts

## Purpose
Custom tiling layouts registered through `awful.layout.suit`. Each layout returns a table
with `name`, `arrange(p)`, and optional `key_handler` / `startup` / `cleanup` / `tip` hooks.

## Architecture

Layouts MUST work with the rest of the AwesomeWM ecosystem by exposing the standard hooks at
the top level of the returned table. The shared keyboard handlers, tips, and lifecycle hooks
for these layouts live in `widgets/common.lua`.

| File                                | What it does                                          |
|-------------------------------------|-------------------------------------------------------|
| `init.lua`                          | Aggregator — registers all layouts with `common.lua`  |
| `cascade.lua`                       | Cascading window layout with offset + tile variant    |
| `centerwork.lua`                    | Center-focused vertical master layout                 |
| `deck.lua`                          | Cascading deck of cards                               |
| `equalarea.lua`                     | Equal area BSP distribution                           |
| `grid.lua`                          | Floating layout with discrete geometry grid           |
| `map.lua`                           | Tiling layout with user-defined geometry groups       |
| `mstab.lua`                         | Master-stack with tabbed slaves                       |
| `stack.lua`                         | Deprecated, retained for reference                    |
| `termfair.lua`                      | Terminal-friendly fair layout (with center + stable)  |
| `thrizen.lua`                       | 3-column balanced grid                                |
| `widgets/common.lua`                | Shared key grabbing, tips, mouse handling             |
| `widgets/navigator.lua`             | Overlay markers for keyboard navigation (Mod4+F2)    |

## Layout Authoring Conventions

A new layout should:

1. Return a table with `name = "your_layout"` and an `arrange(p)` function — `awful.layout.suit` calls `arrange` on each tag switch and client update.
2. Optionally expose `key_handler(mod, key, event)` for layout-specific keygrabbing (called by
   `widgets/navigator.lua` when Mod4+F2 is pressed).
3. Optionally expose `startup()` and `cleanup()` if the layout needs prep/teardown when the navigator enters/exits.
4. Optionally expose `tip` (a table of `awful.key` entries) for the hotkeys popup.
5. Read all theme values through `beautiful` and theme-aware constants — never hardcode pixels.
6. Use `awful.util.dpi()` (from `upstream/awful/util.lua`) for any DPI-scaled value.
7. Call `awful.util.color_alpha(color, "88")` instead of `color .. "88"` for color alpha concatenation.

## Working In This Directory

- Adding a new layout: create `your_layout.lua`, require from `init.lua`, then add an entry to `common.register_custom_layouts()` in `init.lua`.
- Adding key navigators: see `widgets/navigator.lua` — every layout hooks at `l.key_handler`.
- All layouts MUST use `awful.util.dpi()` (re-exported from `beautiful.xresources.apply_dpi` in `widgets/common.lua`'s setup helper). Never redeclare dpi locally — pull from the shared helper.
- The shared `widgets/common.lua` already provides `register_custom_layouts()` which wires handlers + tips. New layouts added there get all the Mod4+F2 navigation keys automatically.
