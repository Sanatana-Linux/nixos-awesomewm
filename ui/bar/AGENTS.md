<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# ui/bar

## Purpose
The wibar (dock) — a hover-reveal bar that slides up from the bottom of the screen. Uses `hover_bar.lua` for the animation and trigger zone mechanism, with pluggable widget modules.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Creates primary and secondary bars for each screen |
| `hover_bar.lua` | Hover-reveal wibox with slide animation and trigger zone |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `modules/` | Bar widget modules (see `modules/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- `hover_bar.lua` creates a `wibox({ type = "utility" })` with per-pixel alpha bg (`beautiful.bg .. "99"`)
- The bar slides in when mouse enters the bottom trigger zone, hides after 3s delay
- Primary screen gets a shorter bar (30dp), secondary gets taller (40dp)
- Widget modules are assembled in `init.lua` and passed to `hover_bar.create()`