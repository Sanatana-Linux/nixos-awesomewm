-- Import the awful library for window management and spawning processes
local awful = require("awful")
local capi = { root = root, client = client }

require("core.autostart.error_handling")

-- Start garbage collection service to manage memory usage
local gc_service = require("core.gc")
gc_service.start()

-- Auto-lock screen after 5 minutes of inactivity (pcall'd so a failure
-- here doesn't prevent the startup commands below from running).
pcall(function()
    local gtimer = require("gears.timer")
    local last_activity = os.time()

    -- Track mouse and focus activity to detect idle time
    capi.root:connect_signal("mouse::enter", function()
        last_activity = os.time()
    end)
    capi.root:connect_signal("mouse::move", function()
        last_activity = os.time()
    end)
    capi.client:connect_signal("focus", function()
        last_activity = os.time()
    end)

    -- Poll every 30 seconds; emit lockscreen signal if idle > 5 minutes
    gtimer({
        timeout = 30,
        autostart = true,
        callback = function()
            if os.time() - last_activity >= 300 then
                awesome.emit_signal("lockscreen::visible", true)
                last_activity = os.time() -- prevent re-lock loop
            end
        end,
    })
end)

-- List of shell commands to autostart when AwesomeWM starts
local autostart_commands = {
    -- "xrdb -merge ~/.Xresources", -- Merge X resources
    "gnome-keyring-daemon --start --components=secrets",
    "pkill picom && sleep 1 && picom --daemon", -- Compositor for blur, shadows, and animations
    -- "xrandr --output eDP-1-1 --mode 2560x1600 --rate 144",
    "xrandr --output eDP-1-1 --mode 2560x1600 --rate 60",
    "clipse --listen &",
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
        -- Remove awesome.restart() to avoid unnecessary restarts
    end
end

-- Execute the autostart logic
run_autostart()
