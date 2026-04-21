<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# configuration/autostart

## Purpose
Autostart module — launches system utilities (picom, xrandr, clipse) and starts the garbage collection service when AwesomeWM initializes.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Defines autostart command list and spawns each with `awful.spawn.with_shell` |

## For AI Agents

### Working In This Directory
- Add new autostart entries to the `autostart_commands` table
- Picom must start here for blur/shadows on the backdrop
- Commands run once at AwesomeWM startup via `awful.spawn.with_shell`