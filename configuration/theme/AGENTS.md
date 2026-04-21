<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# configuration/theme

## Purpose
Theme initialization — loads the "kailash" theme via `beautiful.init()`. This is the single point where the active theme is selected.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Calls `beautiful.init()` with the kailash theme path |

## For AI Agents

### Working In This Directory
- Change `theme_name` to switch themes
- Must be loaded before any UI module (it's first in `configuration/init.lua`)
- All theme variables are defined in `themes/<theme_name>/theme.lua`