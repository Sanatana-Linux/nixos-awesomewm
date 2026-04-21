<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# ui/titlebar

## Purpose
Window titlebar — custom title bar with close, maximize, and minimize buttons using SVG icons and themed styling.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Titlebar construction with buttons and layout |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `icons/` | Titlebar button SVG icons |

## For AI Agents

### Working In This Directory
- Titlebar uses `beautiful.titlebar_bg_*` and `beautiful.titlebar_fg_*` theme variables
- Colors use 8-char hex with alpha: `theme.bg .. "99"` for semi-transparent backgrounds
- Button icons are SVGs recolored via `gears.color.recolor_image()`