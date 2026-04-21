<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# configuration/notification

## Purpose
Notification system configuration — sets up error handling, rule-based notification routing, and battery notification alerts.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Connects `naughty` error display and `ruled.notification` rules |
| `battery.lua` | Low/critical battery notification via battery service signals |

## For AI Agents

### Working In This Directory
- Uses `naughty` for display and `ruled.notification` for rule-based routing
- Error notifications are configured with `request::display_error` signal
- Battery notifications connect to `service.battery` signals for level changes