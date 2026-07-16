<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# modules/icon-lookup

## Purpose
Icon theme lookup — searches system and custom icon themes to find icons by name. Integrates with AwesomeWM's icon theme system and custom SVG paths.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Icon lookup functions — find icon path by name and theme |

## For AI Agents

### Working In This Directory
- Primary icon theme set in `beautiful.icon_theme` (currently "Honor-grey-dark")
- Fallback chain: custom theme → system theme → text icons
- Uses `gears.filesystem` for path resolution