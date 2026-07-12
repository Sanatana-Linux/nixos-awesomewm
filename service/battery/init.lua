-- service/battery.lua
-- This service provides battery status information by polling system files.
-- It is structured as a singleton object to ensure a single source of truth for
-- battery data and emits signals when the level or charging status changes.
--
-- Performance: a single `cat` invocation reads every field at once, instead of
-- 7 separate spawns per poll. This is materially cheaper on the awesome main loop.

local awful = require("awful")
local gears = require("gears")
local gobject = require("gears.object")
local gtable = require("gears.table")

-- The battery service object definition
local battery_service = {}

-- Path to the power supply sysfs root. Override at the top to support systems
-- with a different battery name (e.g. BAT1 on dual-battery laptops).
local BAT_PATH = "/sys/class/power_supply/BAT0"

-- One shell call reads all the fields we care about. The output is one
-- `key=value` line per field, blank lines for missing files. Parsing this in
-- Lua is faster than 7 individual spawn+read round-trips on the awesome
-- main loop.
local POLL_CMD = string.format(
    [[
for f in capacity status health voltage_now power_now energy_full energy_now; do
    if [ -r "%s/$f" ]; then
        printf '%%s=%%s\n' "$f" "$(cat '%s'/"$f" 2>/dev/null)"
    fi
done]],
    BAT_PATH,
    BAT_PATH
)

--- Parse a single `key=value` line into a key/value pair.
-- @tparam string line Output from POLL_CMD
-- @treturn string|nil key, string|nil value
local function parse_kv(line)
    local k, v = line:match("^([^=]+)=(.*)$")
    if not k then
        return nil, nil
    end
    return k, v
end

-- Fetches the current battery level and status, then emits signals.
function battery_service:update()
    awful.spawn.easy_async_with_shell(POLL_CMD, function(stdout)
        local values = {}
        for line in stdout:gmatch("[^\n]+") do
            local k, v = parse_kv(line)
            if k then
                values[k] = v
            end
        end

        local level = tonumber(values.capacity)
        if level and self.level ~= level then
            self.level = level
            self:emit_signal("property::level", self.level)
        end

        local is_charging = not (values.status or ""):match("Discharging")
        if self.is_charging ~= is_charging then
            self.is_charging = is_charging
            self:emit_signal("property::is_charging", self.is_charging)
        end

        local health = (values.health or "Unknown"):gsub("\n", "")
        if self.health ~= health then
            self.health = health
            self:emit_signal("property::health", self.health)
        end

        -- Numeric fields — only update when the file is present and the
        -- value actually changed (in volts/watts). We don't pollute the
        -- signal stream with no-op updates.
        local function update_num(field, divisor, decimals)
            local raw = tonumber(values[field])
            if not raw then
                return
            end
            local factor = 10 ^ decimals
            local value = math.floor(raw / divisor * factor) / factor
            if self[field] ~= value then
                self[field] = value
                self:emit_signal("property::" .. field, value)
            end
        end

        update_num("voltage_now", 1000000, 1) -- → volts
        update_num("power_now", 1000000, 1) -- → watts
        update_num("energy_full", 1000000, 3) -- → Wh
        update_num("energy_now", 1000000, 3) -- → Wh
    end)
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
