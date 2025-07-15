-- service/battery.lua
-- This service provides battery status information by polling system files.
-- It is structured as a singleton object to ensure a single source of truth for
-- battery data and emits signals when the level or charging status changes.

local awful = require("awful")
local gears = require("gears")
local gobject = require("gears.object")
local gtable = require("gears.table")

-- The battery service object definition
local battery_service = {}

-- Fetches the current battery level and status, then emits signals.
function battery_service:update()
    -- Asynchronously get battery capacity
    awful.spawn.easy_async_with_shell(
        "cat /sys/class/power_supply/BAT0/capacity",
        function(stdout_level)
            local level = tonumber(stdout_level)
            if level and self.level ~= level then
                self.level = level
                self:emit_signal("property::level", self.level)
            end
        end
    )

    -- Asynchronously get battery status (charging/discharging)
    awful.spawn.easy_async_with_shell(
        "cat /sys/class/power_supply/BAT0/status",
        function(stdout_status)
            local is_charging = not stdout_status:match("Discharging")
            if self.is_charging ~= is_charging then
                self.is_charging = is_charging
                self:emit_signal("property::is_charging", self.is_charging)
            end
        end
    )
end

-- Constructor for a new battery service instance.
-- @return gobject The new battery service object.
local function new()
    local ret = gobject({})
    gtable.crush(ret, battery_service, true)

    -- Initialize properties
    ret.level = 0
    ret.is_charging = false

    -- Set up a timer to periodically update battery info
    gears.timer({
        timeout = 15, -- Check every 15 seconds
        call_now = true,
        autostart = true,
        callback = function()
            ret:update()
        end,
    })

    return ret
end

-- Singleton pattern: ensures only one instance of the service exists.
local instance = nil
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

-- Expose the singleton accessor
return {
    get_default = get_default,
}
