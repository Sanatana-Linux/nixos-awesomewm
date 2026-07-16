<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# modules/shapes

## Purpose
Shape function library — pure function module (no singleton, no signals) that returns shape closures for use in widget `shape` properties. All functions use `dpi()` for scaling.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Shape functions: `rrect(rad)`, `rrect_25`, `circle()`, and more |

## For AI Agents

### Working In This Directory
- **Utility library pattern**: returns plain table `M` of pure functions, no `gobject`/`gtable`
- Factory functions return closures: `M.rrect(rad)` returns `function(cr, w, h) ... end`
- Always use `dpi()` inside shape factories for responsive sizing
- Used via `shape = shapes.rrect(10)` in widget declarations