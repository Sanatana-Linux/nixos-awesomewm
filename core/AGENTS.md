<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-08-11 -->

# core

## Purpose
Core AwesomeWM configuration entry point. Loads all modules required for basic WM functionality: autostart, theme, tags, client rules, screen management, and garbage collection.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Entry point — requires all submodules in order |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `autostart/` | Applications and scripts to run on startup (see `autostart/AGENTS.md`) |
| `client/` | Window (client) management rules and signals (see `client/AGENTS.md`) |
| `gc/` | Garbage collection service |
| `screen/` | Screen management and primary screen override (see `screen/AGENTS.md`) |
| `tag/` | Virtual desktop (tag) management and custom layouts (see `tag/AGENTS.md`) |
| `theme/` | Theme loading and beautiful initialization (see `theme/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Load order matters: autostart → theme → tag → client → screen
- Keybindings live in the top-level `bindings/` directory (not under `core/`)
- Adding a new config module requires a `require()` in `init.lua`
- New modules must be a directory with `init.lua` entry point

### Common Patterns
- Each subdirectory is a self-contained module loaded via `require("core.<name>")`
- Modules primarily use `connect_signal` to wire into AwesomeWM lifecycle events
