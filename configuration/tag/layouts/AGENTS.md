<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# configuration/tag/layouts

## Purpose
Custom tiling layout algorithms — each file implements an `awful.layout.suit`-compatible layout function for AwesomeWM's tag system.

## Key Files

| File | Description |
|------|-------------|
| `cascade.lua` | Cascading window layout |
| `center.lua` | Center-focused layout with master in center |
| `deck.lua` | Stacked/deck layout with padding |
| `equalarea.lua` | Equal area distribution layout |
| `horizon.lua` | Horizontal split layout |
| `mstab.lua` | Master-stack tabbed layout |
| `stack.lua` | Stacking layout |
| `thrizen.lua` | Three-column layout |
| `vertical.lua` | Vertical split layout |

## For AI Agents

### Working In This Directory
- Each layout file returns a layout object compatible with `awful.layout.suit`
- Layouts are registered in `configuration/tag/init.lua`
- New layouts must expose `name`, `arrange`, and optionally `gap` properties