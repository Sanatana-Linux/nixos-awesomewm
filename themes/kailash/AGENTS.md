<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# themes/kailash

## Purpose
The "kailash" theme — Monokai Pro Spectrum color palette. Defines all colors, gradients, fonts, icon paths, and layout images consumed via `beautiful.*` throughout the codebase.

## Key Files

| File | Description |
|------|-------------|
| `theme.lua` | Complete theme definition — colors, gradients, fonts, icons, wallpaper path |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `icons/` | SVG layout and UI icons (recolored at load time) |
| `wallpaper/` | Wallpaper image |

## For AI Agents

### Working In This Directory
- Base colors: bg `#1f1f1F`, fg `#f7f1ff`, accent colors from Monokai Pro Spectrum
- 8-char hex with alpha for transparency: `bg .. "99"` ≈ 60%, `bg .. "cc"` ≈ 80%
- Gradients use `radial:` and `linear:` prefix syntax with embedded hex colors
- Backdrop color: `#00000080` (50% black, blurred by picom)
- Icon SVGs are recolored via `gears.color.recolor_image(icon_path, theme.fg)`
- `theme.font_name` = "OperatorUltraNerdFontComplete Nerd Font Propo"
- `theme.text_icons` table maps icon names to Nerd Font glyphs