<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# modules/calendar

## Purpose
Instantiable calendar widget with month navigation, date selection, and themed styling. Uses `wibox.widget` + `setmetatable __call` pattern (not singleton).

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Calendar widget constructor with `_private` state for date tracking |

## For AI Agents

### Working In This Directory
- Uses `setmetatable({ new = new }, { __call = ... })` — multiple instances can exist
- Widget children are accessed via `:get_children_by_id("id")[1]`
- Day colors and selection styling come from `beautiful.*` theme variables