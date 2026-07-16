<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# modules/hover_button

## Purpose
Button widget with hover effects — changes appearance on mouse enter/leave. Used throughout the UI for interactive elements.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Hover button widget with visual feedback on mouse events |

## For AI Agents

### Working In This Directory
- Uses `mouse::enter` / `mouse::leave` signals for hover state
- Background and foreground colors change on hover via `beautiful` theme values
- Exported via `modules/init.lua` as `hover_button`