---
name: awesome-test
description:
  Test AwesomeWM config changes using Xephyr nested sessions. Use when testing
  configuration changes, debugging runtime errors, or validating syntax before
  reloading.
---

# AwesomeWM Testing Guide

This project has **no unit test framework** (no busted, no LuaUnit). All testing
is done via **Xephyr nested sessions** using the `awmtt-ng.sh` script. This skill
encodes the exact testing workflow used in this codebase.

## Quick Reference

| Action                      | Command                            |
| --------------------------- | ---------------------------------- |
| Syntax check                | `awesome -c rc.lua --check`        |
| Start test session          | `./bin/awmtt-ng.sh start`          |
| Start with auto-reload      | `./bin/awmtt-ng.sh start -R`       |
| Restart Awesome in test     | `./bin/awmtt-ng.sh restart`        |
| Run command in test         | `./bin/awmtt-ng.sh run <command>`  |
| Stop test session           | `./bin/awmtt-ng.sh stop`           |
| Stop all instances          | `./bin/awmtt-ng.sh stop all`       |
| Manual reload in test       | `Super+Shift+R`                    |
| Format code                 | `stylua .`                         |

## When to Use

- Making any change to `rc.lua`, `configuration/`, `ui/`, `service/`, `modules/`, or `upstream/`
- Debugging Lua errors or AwesomeWM warnings
- Adding or modifying keybindings
- Creating or modifying UI components (bars, popups, titlebars)
- Before committing any changes to the config

## Testing Workflow

### Step 1: Format Code

Always format before testing to catch trivial issues:

```bash
stylua .
```

### Step 2: Validate Syntax

Always run the syntax check **before** starting a test session:

```bash
awesome -c rc.lua --check
```

A clean exit (no output) means valid syntax. Any output means errors to fix.

If using a test config symlink, also validate that:

```bash
awesome -c /home/tlh/.config/awesome/rc.lua.test --check
```

**Never proceed to Step 3 if syntax validation fails.**

### Step 3: Start Test Session

```bash
./bin/awmtt-ng.sh start
```

This launches a Xephyr X server (default display `:1`) with a nested AwesomeWM
instance. The test session opens in its own window.

### Step 4: Apply Changes & Reload

After editing files, restart AwesomeWM inside the test session:

```bash
./bin/awmtt-ng.sh restart
```

Alternatively, for rapid iteration during development:

```bash
./bin/awmtt-ng.sh start -R
```

This enables **auto-reload via `entr`** — any file change under `rc.lua`,
`configuration/`, `ui/`, `service/`, `modules/`, or `theme/` triggers an
automatic restart. Only start once with `-R`; no need to re-run `restart`.

### Step 5: Check for Errors

After restarting, **read the stderr output** in the terminal where `awmtt-ng`
is running. Look for:

- **Lua runtime errors**: stack traces with file paths and line numbers
- **AwesomeWM warnings**: deprecation notices, configuration warnings
- **Module not found**: `require()` failures due to missing paths

**IMPORTANT:** Work through all errors until the test session runs cleanly.
Do not move on while errors remain.

### Step 6: Manual Testing Inside the Session

Inside the test Xephyr window:

- **`Super+Shift+R`** — Manual reload (also useful if auto-reload isn't active)
- **`Super+<number>`** — Switch tags
- **`Super+Enter`** — Open terminal
- **`Super+Q`** — Close focused client
- **`Super+Space`** — Toggle layout
- Test keybindings, UI popups, and service behavior interactively

To run a specific command inside the test environment:

```bash
./bin/awmtt-ng.sh run <command>
```

For example, check if a service is responding:

```bash
./bin/awmtt-ng.sh run pactl get-sink-volume @DEFAULT_SINK@
```

### Step 7: Stop the Session

When done:

```bash
./bin/awmtt-ng.sh stop
```

If multiple instances are running (e.g., from a previous session that wasn't
properly cleaned up):

```bash
./bin/awmtt-ng.sh stop all
```

## Common Failure Modes

### Lua Syntax Errors

- Missing `end` keywords, mismatched parentheses, or stray commas
- `stylua .` auto-formats and catches many simple issues before runtime
- `awesome -c rc.lua --check` catches syntax errors statically

### Module Not Found

- If a `require()` fails with "module not found", the path may not be in
  `package.path`
- Check `rc.lua` for the `upstream/` directory prepend to `package.path`:

```lua
package.path = path .. "/upstream/share/awesome/lib/?.lua;" .. package.path
```

- LuaJIT uses **Lua 5.1** semantics for module loading — tables returned from
  modules override previous globals of the same name
- New modules under `service/`, `ui/`, `modules/`, or `lib/` should be
  resolvable by path — no registration needed

### D-Bus Timeouts

- `NetworkManager` and `bluez` services may not be available in the test
  environment
- Services should use `pcall()` around D-Bus proxy creation to fall back
  gracefully:

```lua
local ok, proxy = pcall(function()
    return dbus_proxy({ name = "...", path = "...", interface = "..." })
end)
if not ok then
    -- run in degraded mode or skip initialization
end
```

### Keyd Interception

- Volume/media keys may not respond inside the test session
- The host's `keyd` daemon may be grabbing the input device (`ids = ["*"]`)
- The project works around this with **dual keysym + keycode** bindings
- If keys don't work in test, check if keyd is running and which devices it
  controls

### PipeWire Audio Suspension

- Audio may cut out after 5+ seconds of silence due to PipeWire's suspension
  of idle sinks
- The `service/audio/init.lua` keep-alive timer prevents this by periodically
  calling `pactl set-sink-volume @DEFAULT_SINK@ 100%`
- **If audio drops out unexpectedly**, check that the keep-alive timer is
  running:

```lua
-- In test session, run:
awful.spawn.with_shell("pactl list sinks short | grep SUSPENDED")
```

### Auto-reload Not Triggering

- Auto-reload (`-R` flag) requires `entr` to be installed
- Entr watches files via `inotify` — some editors may not trigger it if they
  use atomic saves
- If auto-reload isn't working, use manual `./bin/awmtt-ng.sh restart` instead

## Log Checking Pattern

After a restart, always check for errors. The standard pattern:

```bash
# Start test in one terminal
./bin/awmtt-ng.sh start

# In another terminal, make changes and restart
stylua .
awesome -c rc.lua --check && ./bin/awmtt-ng.sh restart

# Read the output from the first terminal for errors
```

Errors appear as stderr in the awmtt-ng terminal. Pipe to a log file if needed:

```bash
./bin/awmtt-ng.sh start 2>&1 | tee /tmp/awmtt.log
```

## Red Flags

- Skipping syntax validation before starting a test session
- Ignoring stderr output after restart — "it still works" doesn't mean no errors
- Using `os.execute()` or `io.popen()` in code being tested — will deadlock
  the event loop
- Not testing interactive behavior (keybindings, popups, focus) — syntax check
  alone is insufficient
- Leaving test sessions running when switching tasks — `stop all` to clean up
