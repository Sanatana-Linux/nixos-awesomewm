<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# configuration/client

## Purpose
Client (window) management — sets up window rules, placement policies, focus handling, and signals. Configures behavior for fullscreen, maximized, transient, and floating clients, plus custom per-app rules.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Main module — connects client signals, sets rules and focus policy |
| `better_resize.lua` | Improved resize behavior for tiled clients |
| `center_in_parent.lua` | Centers transient windows on their parent |
| `restore_clients.lua` | Restores minimized clients when switching tags |

## For AI Agents

### Working In This Directory
- Client rules use `ruled.client` for declarative matching
- Focus follows mouse (sloppy focus) is configured here
- New per-app rules go in `init.lua`'s rules table
- Use `capi = { client = client }` to capture the global client API