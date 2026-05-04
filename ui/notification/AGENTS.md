<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# ui/notification

## Purpose
Unified notification system — handles error display, rule-based notification routing, battery alerts, custom themed notification popups, screenshot notifications, notification caching, and cleanup on exit.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Notification singleton — error handling, ruled notification rules, themed notification display, and exit cleanup |
| `battery.lua` | Low/critical battery notification via battery service signals |
| `cache.lua` | Notification cache for deduplication and history |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `icons/` | Notification icon assets |
| `screenshots/` | Screenshot notification handler (see `screenshots/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Error notifications configured with `naughty.connect_signal("request::display_error", ...)`
- Ruled notifications configure timeouts via `rnotification.connect_signal("request::rules", ...)`
- Battery notifications connect to `service.battery` signals for level changes
- Notification styling comes from `beautiful.notification_*` theme variables
- `cache.lua` prevents notification spam for repeated events
- Screenshot notifications have specialized layout via `screenshots/` submodule
- All notifications are destroyed silently on AwesomeWM exit via `awesome.connect_signal("exit", ...)`