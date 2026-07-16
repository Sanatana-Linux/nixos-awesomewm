--- Brightness service.
-- Backlight control via the `brightnessctl` CLI. Reads both current and max
-- brightness in a single shell call (one spawn) and emits
-- `brightness::updated` / `brightness::error` signals accordingly.
-- @module service.brightness

local awful = require("awful")
local gobject = require("gears.object")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local gdebug = require("gears.debug")

local brightness_service = {}

-- Single shell command that emits `current=N` and `max=M` lines.
local POLL_CMD = [[
printf 'current=%s\n' "$(brightnessctl g)"
printf 'max=%s\n'     "$(brightnessctl m)"
]]

--- Parse `current=N` / `max=M` lines from the POLL_CMD output.
-- @tparam string stdout The raw output of the brightnessctl poll
-- @treturn table Map of `current` and `max` to their string values
local function parse_poll(stdout)
    local values = {}
    for line in stdout:gmatch("[^\n]+") do
        local k, v = line:match("^([^=]+)=(.*)$")
        if k then
            values[k] = v
        end
    end
    return values
end

-- Fetches the current brightness percentage. Emits "brightness::updated" or
-- "brightness::error".
-- @tparam[opt] function callback Receives the percentage (0..100)
-- @treturn number|nil Cached value if available, else nil
function brightness_service:get(callback)
    awful.spawn.easy_async_with_shell(
        POLL_CMD,
        function(stdout, stderr, reason, exit_code)
            if exit_code ~= 0 then
                gdebug.print_error(
                    "Brightness service: poll failed: " .. (stderr or reason)
                )
                self:emit_signal("brightness::error", stderr or reason)
                return
            end

            local values = parse_poll(stdout)
            local current = tonumber(values.current)
            local max = tonumber(values.max)

            if not current or not max or max <= 0 then
                gdebug.print_error(
                    "Brightness service: failed to parse output ("
                        .. tostring(values.current)
                        .. " / "
                        .. tostring(values.max)
                        .. ")"
                )
                self:emit_signal(
                    "brightness::error",
                    "Failed to parse brightness output"
                )
                return
            end

            local percentage = math.floor((current / max) * 100)
            self._private.current_brightness = percentage
            self:emit_signal("brightness::updated", percentage)
            if callback then
                callback(percentage)
            end
        end
    )

    -- Return the cached value immediately if known
    return self._private.current_brightness
end

--- Sets the brightness to a specified percentage.
-- @tparam number value 0..100 (clamped and floored)
function brightness_service:set(value)
    local clamped = math.max(0, math.min(100, math.floor(value)))
    awful.spawn.with_shell("brightnessctl s " .. clamped .. "%", false)
    -- Assume success and update internal state for responsiveness. A follow-up
    -- poll would confirm the actual value, but a 50ms debounce feels sluggish.
    self._private.current_brightness = clamped
    self:emit_signal("brightness::updated", clamped)
end

--- Increases brightness by `brightnessctl`'s default step (5%).
-- Re-reads the actual brightness after the shell command settles.
-- @tparam[opt] function callback Invoked after the re-read
function brightness_service:increase(callback)
    awful.spawn.with_shell("brightnessctl s 5%+")
    gtimer.delayed_call(function()
        self:get(callback)
    end)
end

--- Decreases brightness by `brightnessctl`'s default step (5%).
-- Re-reads the actual brightness after the shell command settles.
-- @tparam[opt] function callback Invoked after the re-read
function brightness_service:decrease(callback)
    awful.spawn.with_shell("brightnessctl s 5%-")
    gtimer.delayed_call(function()
        self:get(callback)
    end)
end

--- Construct a new brightness service instance.
-- Sets up `_private.current_brightness = nil` and schedules the
-- initial poll via `gtimer.delayed_call` so the awesome main loop
-- has fully started before the spawn fires.
-- @treturn table A gobject with the public methods of `brightness_service`
local function new()
    local ret = gobject({})
    gtable.crush(ret, brightness_service, true)
    ret._private = {
        current_brightness = nil,
    }

    -- Defer the first read so Awesome is fully up before we ask
    gtimer.delayed_call(function()
        ret:get()
    end)

    return ret
end

--- Singleton accessor: returns (and lazily constructs) the brightness service.
-- @treturn table Cached service instance (same object on every call)
local instance
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
