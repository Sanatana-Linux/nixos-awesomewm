-- Import the awful library for window management and spawning processes
local awful = require("awful")

require("core.autostart.error_handling")

-- Start garbage collection service to manage memory usage
local gc_service = require("core.gc")
gc_service.start()

-- Auto-lock screen after 10 minutes of X inactivity.
-- `xautolock` is a proper idle daemon: it subscribes to XScreenSaver
-- idle events (DPMS-aware, keyboard + mouse + any input device) and
-- invokes `-locker` when the idle timer crosses `-time` (minutes). The
-- locker emits the in-process `lockscreen::visible` signal so the
-- existing lockscreen UI and keygrabber activate.
--
-- Nested quoting (read carefully):
--   - The Lua string uses single quotes; `\'` -> `'`, `\\"` -> `\"`.
--   - The resulting shell command contains `-locker "awesome-client '...\"...\"...'"`
--   - `sh -c` (run by awful.spawn.with_shell) parses the outer double
--     quotes around the -locker value, treating `\"` as literal `"`.
--   - xautolock stores the result and later calls system(), which runs
--     another `sh -c`; that shell sees the single-quoted Lua arg with
--     literal `"` inside, passing it verbatim to awesome-client.
--
-- This command runs OUTSIDE the restart guard below: `awesome.restart()`
-- (Mod4+Ctrl+r) skips the guarded autostart list, so a daemon spawned
-- only there would die on the first restart and never come back until
-- logout. The leading `pkill` makes this line idempotent — safe to run
-- on every start and restart.

-- List of shell commands to autostart when AwesomeWM starts
local autostart_commands = {
    -- "xrdb -merge ~/.Xresources", -- Merge X resources
    "pkill picom && sleep 1 && picom --daemon", -- Compositor for blur, shadows, and animations
    "xrandr --output eDP-1-1 --mode 2560x1600 --rate 144",
    --      "xrandr --output eDP-1-1 --mode 2560x1600 --rate 60",
    --      "clipse --listen &",
    "clipster -d &",
}

--- Checks if AwesomeWM was restarted in this session.
-- Uses X properties to detect if a restart has occurred.
-- @return boolean True if this is a restart, false otherwise.
local function was_restarted()
    awesome.register_xproperty("restarted", "boolean")
    local detected = awesome.get_xproperty("restarted") ~= nil
    awesome.set_xproperty("restarted", true)
    return detected
end

--- Runs autostart commands if this is not a restart.
-- Prevents duplicate processes on restart.
local function run_autostart()
    if not was_restarted() then
        for _, cmd in ipairs(autostart_commands) do
            awful.spawn.with_shell(cmd)
        end
    end
    -- Auto-lock: xautolock daemon triggers lockscreen after 10 min idle.
    -- Outside the restart guard — respawns on every start AND restart
    -- (idempotent thanks to the leading `pkill`).
    awful.spawn.with_shell(
        'pkill xautolock; xautolock -time 10 -locker "awesome-client \'awesome.emit_signal(\\"lockscreen::visible\\", true)\'"'
    )
end

-- Execute the autostart logic
run_autostart()
