<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# bin

## Purpose
Shell scripts for managing the AwesomeWM test environment and system utilities.

## Key Files

| File | Description |
|------|-------------|
| `awmtt-ng.sh` | AwesomeWM Test Tool — starts/stops/restarts nested Xephyr sessions for testing config changes |

## For AI Agents

### Working In This Directory
- `awmtt-ng.sh` is the primary testing tool — always test changes via this script
- Commands: `start`, `stop`, `stop all`, `restart`, `run <cmd>`
- `start -R` enables auto-reload on file change (requires `entr`)
- Restart after any Lua changes to verify no runtime errors