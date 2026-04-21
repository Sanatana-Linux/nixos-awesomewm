<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# themes

## Purpose
Visual themes defining colors, fonts, gradients, icons, and wallpaper. Currently contains the "kailash" theme (Monokai Pro Spectrum palette). Theme variables are accessed via `beautiful.*` throughout the codebase.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `kailash/` | Active theme — Monokai Pro Spectrum palette (see `kailash/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Theme values are consumed via `require("beautiful")` everywhere
- `theme.lua` defines all colors, gradients, fonts, and icon paths
- Gradient patterns use `radial:` and `linear:` prefix syntax
- 8-char hex colors include alpha: `"#1f1f1F99"` = `bg` at ~60% opacity
- Icon SVGs are recolored at load time via `gears.color.recolor_image()`