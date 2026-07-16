<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# modules/menu

## Purpose
Custom menu widget — right-click context menu with themed items, submenus, and keyboard navigation.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Menu singleton with show/hide and item creation |

## For AI Agents

### Working In This Directory
- Uses `get_default()` singleton pattern
- Integrates with `click_to_hide` and `backdrop` modules
- Keyboard navigation via `awful.key` bindings