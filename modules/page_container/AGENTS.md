<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# modules/page_container

## Purpose
Swipeable page container — manages multiple pages with gesture-based navigation for the control panel and similar multi-view UIs.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Page container with swipe/transition animation |

## For AI Agents

### Working In This Directory
- Uses `modules.animations` for page transition effects
- Pages are added/removed dynamically
- Page change emits `property::current_page` signal