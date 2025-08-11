-- Import the awful library for window management and spawning processes
local awful = require("awful")

-- Start garbage collection service to manage memory usage
local gc_service = require("service.garbage_collection")
gc_service.start()

-- List of shell commands to autostart when AwesomeWM starts
local autostart_commands = {
    "xrdb -merge ~/.Xresources", -- Merge X resources
    "picom", -- Start the compositor
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
