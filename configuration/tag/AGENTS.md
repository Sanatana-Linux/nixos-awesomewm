<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# configuration/tag

## Purpose
Virtual desktop (tag) configuration — defines tag names, layouts, and keybindings. Includes custom layout implementations imported from the `layouts/` subdirectory.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Defines tag list, default layouts, and connects tag signals |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `layouts/` | Custom tiling layout implementations (see `layouts/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Tags are defined with names and default layouts in `init.lua`
- Custom layouts are required from `configuration.tag.layouts.<name>`
- Adding a new layout requires: (1) create file in `layouts/`, (2) require it in `init.lua`