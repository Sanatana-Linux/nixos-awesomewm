<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# modules/snap_edge

## Purpose
Window edge snapping — shows preview when dragging a client to screen edges, with configurable zones and preview shapes.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Snap edge singleton with zone definitions and preview rendering |

## For AI Agents

### Working In This Directory
- Enabled via `awful.mouse.snap.edge_enabled = true` in keybind config
- Preview uses `wibox` overlay with `ontop = true`
- Compatible with AwesomeWM's built-in snap mechanism