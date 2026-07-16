<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-26 -->

# configuration/client

## Purpose
Client (window) management — sets up window rules, placement policies, focus handling, shape/opacity management, and signals. Configures behavior for fullscreen, maximized, transient, and floating clients, plus custom per-app and notification rules.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Entry point — requires all submodules |
| `signals.lua` | Wiring hub — connects signals to handlers in submodules (placement, focus, opacity) + re-exports `center_and_keep_on_screen` |
| `ruled.lua` | Declarative rules for `ruled.client` (per-app, floating, titlebar) and `ruled.notification` (timeout) |
| `placement.lua` | Geometry placement (center, keep-on-screen, maximized/fullscreen adjustments) + client shape management |
| `focus.lua` | Sloppy focus (activate-under-pointer), debounced focus timer, focus-back on minimize/unmanage |
| `opacity.lua` | Data-driven client opacity by type, class, and focus state with fallback chain |
| `better_resize.lua` | Improved mouse resize behavior for tiled layouts |
| `restore_clients.lua` | Preserves and restores client/tag/focus state across AwesomeWM restarts |

## For AI Agents

### Working In This Directory
- Client rules go in `ruled.lua`, signal wiring goes in `signals.lua`
- `placement.lua` exports `center_and_keep_on_screen` for use as a `placement` function in rules — use this directly from `ruled.lua`
- Notification rules (via `ruled.notification`) live in `ruled.lua` alongside client rules
- Focus follows mouse (sloppy focus) lives in `focus.lua`
- Opacity tables (`type_opacity`, `class_opacity`, `class_focused_opacity`) and `apply_opacity` live in `opacity.lua`
- `signals.lua` is the wiring hub: it `require`s the submodules and connects signals. It should not contain handler logic.