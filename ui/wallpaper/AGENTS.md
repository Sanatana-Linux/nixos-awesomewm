<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# ui/wallpaper

## Purpose
Wallpaper setter — selects and applies wallpaper images, supporting random selection from a directory.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Wallpaper selection and application via `awful.wallpaper` |

## For AI Agents

### Working In This Directory
- Wallpaper path is set via `beautiful.wallpaper` theme variable
- Supports random wallpaper selection from a directory
- Uses `gears.wallpaper` for setting wallpapers on screen surfaces