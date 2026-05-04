<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-26 -->

# configuration/client

## Purpose
Client (window) management — sets up window rules, placement policies, focus handling, shape/opacity management, and signals. Configures behavior for fullscreen, maximized, transient, and floating clients, plus custom per-app and notification rules.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Entry point — requires all submodules |
| `signals.lua` | All client signal handlers (focus, manage, shape, opacity, geometry) + shared `center_and_keep_on_screen` placement |
| `ruled.lua` | Declarative rules for `ruled.client` (per-app, floating, titlebar) and `ruled.notification` (timeout) |
| `better_resize.lua` | Improved mouse resize behavior for tiled layouts |
| `restore_clients.lua` | Preserves and restores client/tag/focus state across AwesomeWM restarts |

## For AI Agents

### Working In This Directory
- Client rules go in `ruled.lua`, signal handlers go in `signals.lua`
- `signals.lua` exports `center_and_keep_on_screen` for use as a `placement` function in rules
- Notification rules (via `ruled.notification`) live in `ruled.lua` alongside client rules
- Focus follows mouse (sloppy focus) is in `signals.lua`
- Opacity is managed via data-driven tables (`type_opacity`, `class_opacity`, `class_focused_opacity`) in `signals.lua`