<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# modules

## Purpose
Reusable UI modules consumed by both services and UI components. Includes utility libraries (shapes, icons), interactive widgets (calendar, text_input, menu, dropdown), and infrastructure (backdrop, animations, snap_edge). Aggregated via `modules/init.lua` as a flat require table.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Aggregator — returns flat table of all module requires |
| `arc_chart.lua` | Arc chart widget for progress display |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `animations/` | Animation primitives (slide, fade, easing functions) (see `animations/AGENTS.md`) |
| `applet_button/` | Reusable applet toggle/launcher button (see `applet_button/AGENTS.md`) |
| `applet_pages/` | Page container with applet integration for control panel (see `applet_pages/AGENTS.md`) |
| `backdrop/` | Semi-transparent overlay behind popups, blurred by picom (see `backdrop/AGENTS.md`) |
| `button_patterns/` | Standard button behavior patterns (hover, press, release) (see `button_patterns/AGENTS.md`) |
| `button_styles/` | Named button style definitions (see `button_styles/AGENTS.md`) |
| `calendar/` | Instantiable calendar widget with month navigation (see `calendar/AGENTS.md`) |
| `click_to_hide/` | Click-outside-to-dismiss behavior for popups (see `click_to_hide/AGENTS.md`) |
| `container_styles/` | Named container style definitions (see `container_styles/AGENTS.md`) |
| `crop_surface/` | Surface cropping utilities (see `crop_surface/AGENTS.md`) |
| `dropdown/` | Dropdown selection widget (see `dropdown/AGENTS.md`) |
| `hover_button/` | Button widget with hover effects (see `hover_button/AGENTS.md`) |
| `icon-lookup/` | Icon theme lookup across system and custom paths (see `icon-lookup/AGENTS.md`) |
| `menu/` | Custom menu widget (see `menu/AGENTS.md`) |
| `page_container/` | Swipeable page container for multi-view popups (see `page_container/AGENTS.md`) |
| `popup_animations/` | Popup-specific animation helpers (see `popup_animations/AGENTS.md`) |
| `remote_watch/` | Watch remote resources/URLs for changes (see `remote_watch/AGENTS.md`) |
| `shapes/` | Shape function library (rounded_rect, circle, etc.) (see `shapes/AGENTS.md`) |
| `snap_edge/` | Window edge snapping with preview (see `snap_edge/AGENTS.md`) |
| `styled_button/` | Themed button combining styles and patterns (see `styled_button/AGENTS.md`) |
| `text_input/` | Text input widget with cursor and selection (see `text_input/AGENTS.md`) |
| `ui_constants/` | Shared UI dimension and color constants (see `ui_constants/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Four module archetypes exist (see `.opencode/rules/patterns.md`):
  - **Service-style singleton**: `gobject` + `gtable.crush` + `get_default()` (backdrop)
  - **Instantiable widget**: `wibox.widget({})` + `setmetatable __call` (calendar, text_input)
  - **Utility library**: Plain function table, `return M` (shapes)
  - **Infrastructure**: Module with `connect_signal` pattern (animations, snap_edge)
- New modules must be added to `modules/init.lua` to be discoverable
- Use `dpi()` for all dimensions, `beautiful.*` for all colors