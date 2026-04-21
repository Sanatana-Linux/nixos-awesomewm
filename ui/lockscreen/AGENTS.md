<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-21 | Updated: 2026-04-21 -->

# ui/lockscreen

## Purpose
Screen locker with PAM authentication, animated word clock, and visual lock effects. Handles password input, failed attempt feedback, and session unlock.

## Key Files

| File | Description |
|------|-------------|
| `init.lua` | Lockscreen singleton — show/hide with PAM verification |
| `lockscreen.lua` | Lockscreen widget construction and layout |
| `lockscreen_body.lua` | Main body content (word clock, password input) |
| `grab_password.lua` | Password grabbing and PAM authentication logic |
| `lock_animation.lua` | Lock/unlock visual animation |
| `wordclock.lua` | Word-based time display |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `assets/` | Lockscreen visual assets |
| `lib/` | Lockscreen-specific library code |

## For AI Agents

### Working In This Directory
- PAM authentication uses `lib.liblua_pam.so` native module via `package.cpath`
- `grab_password.lua` uses keygrabber for password input
- Lockscreen uses `ontop = true` and grabs all input
- The lockscreen singleton follows the `get_default()` pattern