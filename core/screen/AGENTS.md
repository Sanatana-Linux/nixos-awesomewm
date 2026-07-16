<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# configuration/screen

## Purpose
Screen management — overrides primary screen selection to prefer internal displays over HDMI, and handles multi-monitor geometry.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Detects preferred primary screen, sets up screen geometry handling |

## For AI Agents

### Working In This Directory
- Uses `capi = { screen = screen }` to capture the global screen API
- `get_preferred_primary()` selects internal displays over external
- Screen geometry changes trigger `property::geometry` signal handlers