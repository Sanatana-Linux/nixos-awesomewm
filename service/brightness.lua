-- service/brightness.lua
-- This module provides a service for controlling screen brightness using the
-- 'brightnessctl' command-line utility.
-- It allows getting and setting brightness and emits signals when the brightness
-- is updated, enabling other widgets (like a slider or OSD) to react.

local awful = require("awful")
local gobject = require("gears.object")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local gdebug = require("gears.debug")

local brightness_service = {} -- Renamed for clarity to avoid conflict with file name

-- Fetches the current brightness percentage using brightnessctl.
-- Emits "brightness::updated" or "brightness::error".
function brightness_service:get(callback)
    -- Use async to avoid blocking the UI
    awful.spawn.easy_async_with_shell("brightnessctl g", function(stdout, stderr, reason, exit_code)
        if exit_code == 0 then
            local current_max_brightness_raw = ""
            local current_brightness_raw = stdout

            awful.spawn.easy_async_with_shell("brightnessctl m", function(stdout_max)
                current_max_brightness_raw = stdout_max
                local current_brightness = tonumber(current_brightness_raw)
                local max_brightness = tonumber(current_max_brightness_raw)

                if current_brightness ~= nil and max_brightness ~= nil and max_brightness > 0 then
                    local percentage = math.floor((current_brightness / max_brightness) * 100)
                    self._private.current_brightness = percentage
                    self:emit_signal("brightness::updated", percentage)
                    if callback then
                        callback(percentage)
                    end
                else
                    gdebug.print_error("Brightness service: Failed to parse brightness output. Current: " ..
                    tostring(current_brightness_raw) .. " Max: " .. tostring(current_max_brightness_raw))
                    self:emit_signal("brightness::error", "Failed to parse brightness output")
                end
            end)
        else
            gdebug.print_error("Brightness service: Failed to get brightness: " .. (stderr or reason))
            self:emit_signal("brightness::error", stderr or reason)
        end
    end)
    -- Return cached value immediately, if available
    return self._private.current_brightness
end

-- Sets the brightness to a specified percentage using brightnessctl.
-- @param value number The desired brightness percentage (0-100).
function brightness_service:set(value)
    local clamped_value = math.max(0, math.min(100, math.floor(value))) -- Clamp value between 0 and 100 and floor it
    -- Use `awful.spawn.with_shell` to ensure the command is executed correctly
    awful.spawn.with_shell("brightnessctl s " .. clamped_value .. "%", false)
    -- Assume success and update internal state and emit signal immediately for responsiveness.
    -- A timer could be added to verify the change by calling self:get() after a short delay.
    self._private.current_brightness = clamped_value
    self:emit_signal("brightness::updated", clamped_value)
end

-- Increases the brightness by a default step (e.g., 5%).
function brightness_service:increase(callback)
    awful.spawn.with_shell("brightnessctl s 5%+")
    gtimer.delayed_call(function()
        self:get(callback)
    end)
end

-- Decreases the brightness by a default step (e.g., 5%).
function brightness_service:decrease(callback)
    awful.spawn.with_shell("brightnessctl s 5%-")
    gtimer.delayed_call(function()
        self:get(callback)
    end)
end

-- Creates a new brightness service instance.
-- @return gobject The new brightness service object.
local function new()
    local ret = gobject {}                   -- Create a gears object for signal emission
    gtable.crush(ret, brightness_service, true) -- Mixin the brightness_service methods
    ret._private = {
        current_brightness = nil,            -- Store the last known brightness
    }

    -- Fetch initial brightness state
    -- A short delay ensures Awesome is fully up and running before the first call
    gtimer.delayed_call(function() ret:get() end)


    return ret
end

-- Manages the singleton instance of the brightness service.
local instance = nil
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default
}
