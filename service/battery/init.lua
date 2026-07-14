--- Battery status service.
-- Polls `/sys/class/power_supply/BAT0` every 15 seconds and emits
-- `property::level`, `property::is_charging`, `property::health`,
-- `property::voltage`, `property::power`, `property::energy_full`,
-- and `property::energy_now` when values change. The single-shell
-- poll keeps the awesome main loop responsive (vs 7 separate spawns).
-- @module service.battery

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

--- Poll `/sys/class/power_supply/BAT0` and emit `property::*` signals.
-- Only emits when a value actually changes — see the early `if self.x ~= y`
-- guards. Asynchronous via `easy_async_with_shell`; safe to call from the
-- awesome main loop.
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

--- Construct a battery service instance.
-- Sets up a 15-second `gears.timer` to call `update()` periodically.
-- @treturn table A gobject with the public methods of `battery_service`
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

--- Singleton accessor: returns (and lazily constructs) the battery service.
-- @treturn table Cached service instance (same object on every call)
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
