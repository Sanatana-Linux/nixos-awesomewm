<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# ui/notification

## Purpose
Custom notification daemon — replaces `naughty` defaults with themed notifications. Includes screenshot notification handling and notification caching.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Notification singleton — themed notification display and management |
| `cache.lua` | Notification cache for deduplication and history |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `icons/` | Notification icon assets |
| `screenshots/` | Screenshot notification handler (see `screenshots/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Notification styling comes from `beautiful.notification_*` theme variables
- `cache.lua` prevents notification spam for repeated events
- Screenshot notifications have specialized layout via `screenshots/` submodule