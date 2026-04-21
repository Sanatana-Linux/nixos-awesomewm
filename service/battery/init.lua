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
    
    -- Get additional battery details for popup
    self:update_detailed_info()
end

-- Get detailed battery information for popup display
function battery_service:update_detailed_info()
    -- Get health status
    awful.spawn.easy_async_with_shell(
        "cat /sys/class/power_supply/BAT0/health 2>/dev/null || echo 'Unknown'",
        function(stdout)
            local health = stdout:gsub("\n", "")
            if self.health ~= health then
                self.health = health
                self:emit_signal("property::health", self.health)
            end
        end
    )
    
    -- Get voltage (if available)
    awful.spawn.easy_async_with_shell(
        "cat /sys/class/power_supply/BAT0/voltage_now 2>/dev/null",
        function(stdout)
            local voltage_raw = tonumber(stdout)
            if voltage_raw then
                local voltage = math.floor(voltage_raw / 1000000 * 10) / 10 -- Convert to volts with 1 decimal
                if self.voltage ~= voltage then
                    self.voltage = voltage
                    self:emit_signal("property::voltage", self.voltage)
                end
            end
        end
    )
    
    -- Get power consumption (if available)
    awful.spawn.easy_async_with_shell(
        "cat /sys/class/power_supply/BAT0/power_now 2>/dev/null",
        function(stdout)
            local power_raw = tonumber(stdout)
            if power_raw then
                local power = math.floor(power_raw / 1000000 * 10) / 10 -- Convert to watts with 1 decimal
                if self.power ~= power then
                    self.power = power
                    self:emit_signal("property::power", self.power)
                end
            end
        end
    )
    
    -- Get battery capacity and cycle count for better estimates
    awful.spawn.easy_async_with_shell(
        "cat /sys/class/power_supply/BAT0/energy_full 2>/dev/null",
        function(stdout)
            local energy_full = tonumber(stdout)
            if energy_full then
                energy_full = energy_full / 1000000 -- Convert to Wh
                if self.energy_full ~= energy_full then
                    self.energy_full = energy_full
                    self:emit_signal("property::energy_full", self.energy_full)
                end
            end
        end
    )
    
    -- Get current energy
    awful.spawn.easy_async_with_shell(
        "cat /sys/class/power_supply/BAT0/energy_now 2>/dev/null",
        function(stdout)
            local energy_now = tonumber(stdout)
            if energy_now then
                energy_now = energy_now / 1000000 -- Convert to Wh
                if self.energy_now ~= energy_now then
                    self.energy_now = energy_now
                    self:emit_signal("property::energy_now", self.energy_now)
                end
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
    ret.health = "Unknown"
    ret.voltage = nil
    ret.power = nil
    ret.energy_full = nil
    ret.energy_now = nil

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
