<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# modules/remote_watch

## Purpose
Remote resource watcher — monitors URLs or files for changes and emits signals on update.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Remote watch singleton with configurable polling interval |

## For AI Agents

### Working In This Directory
- Uses `gears.timer` for periodic checks
- Emits `property::updated` signal when content changes
- Handles network errors gracefully with `pcall`