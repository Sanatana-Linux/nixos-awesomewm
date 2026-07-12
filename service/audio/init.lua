--- Audio service.
-- PulseAudio/PipeWire volume control for the default sink and source.
-- Exposes a singleton that emits `default-sink::{volume,mute}` and
-- `default-source::{volume,mute}` signals on state change.
--
-- Performance note: `get_default_sink_data` and `get_default_source_data`
-- each read 2 fields (volume + mute) in a single shell call instead of
-- issuing them separately. This halves the spawn cost on the awesome main loop.
--
-- @module service.audio

local awful = require("awful")
local gobject = require("gears.object")
local gtable = require("gears.table")
local gdebug = require("gears.debug")

local audio = {}

-- Build a single shell command that emits `field=value` lines for the requested
-- properties of the given pactl target. Empty output for missing fields.
-- @tparam string target `@DEFAULT_SINK@` or `@DEFAULT_SOURCE@`
-- @tparam table fields List of property names to read (e.g. `{"volume", "mute"}`)
-- @treturn string Shell command
local function build_poll_cmd(target, fields)
    local pieces = {}
    for _, field in ipairs(fields) do
        table.insert(
            pieces,
            string.format(
                "printf '%%s=%%s\\n' '%s' \"$(pactl get-%s %s)\"",
                field,
                field,
                target
            )
        )
    end
    return table.concat(pieces, "\n")
end

-- Parse `key=value` output of the built poll command.
-- @tparam string stdout
-- @treturn table Decoded values keyed by field name
local function parse_kv(stdout)
    local values = {}
    for line in stdout:gmatch("[^\n]+") do
        local k, v = line:match("^([^=]+)=(.*)$")
        if k then
            values[k] = v
        end
    end
    return values
end

-- Decode pactl's percentage output ("/ 78%") to an integer.
-- @tparam string raw pactl volume output
-- @treturn number|nil Volume as 0..100, or nil if no match
local function parse_volume_pct(raw)
    if not raw then
        return nil
    end
    return tonumber(raw:match("/%s+(%d+)%%"))
end

-- Decode pactl mute output ("yes" / "no") to a boolean.
-- pactl prints both `Mute: yes` and just `yes` depending on caller; this parser
-- accepts either form.
-- @tparam string raw pactl mute output
-- @treturn boolean
local function parse_mute_bool(raw)
    if not raw then
        return false
    end
    return raw:match("(%w+)$") == "yes"
end

-- @tparam[opt] function callback Receives (volume, mute) when the read finishes
function audio:get_default_sink_data(callback)
    awful.spawn.easy_async_with_shell(
        build_poll_cmd("@DEFAULT_SINK@", { "sink-volume", "sink-mute" }),
        function(stdout)
            local values = parse_kv(stdout)

            local volume = parse_volume_pct(values["sink-volume"])
            if volume and self.default_sink_volume ~= volume then
                self.default_sink_volume = volume
                self:emit_signal("default-sink::volume", volume)
            end

            local mute = parse_mute_bool(values["sink-mute"])
            if self.default_sink_mute ~= mute then
                self.default_sink_mute = mute
                self:emit_signal("default-sink::mute", mute)
            end

            if callback then
                callback(self.default_sink_volume, self.default_sink_mute)
            end
        end
    )
end

-- @tparam number|string value 0..100 — written as a relative or absolute percent
-- @tparam[opt] function callback
function audio:set_default_sink_volume(value, callback)
    awful.spawn.with_shell(
        "pactl set-sink-volume @DEFAULT_SINK@ " .. tostring(value) .. "%"
    )
    self:get_default_sink_data(callback)
end

-- @tparam[opt] function callback
function audio:toggle_default_sink_mute(callback)
    awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    self:get_default_sink_data(callback)
end

-- @tparam[opt] function callback Receives (volume, mute) when the read finishes
function audio:get_default_source_data(callback)
    awful.spawn.easy_async_with_shell(
        build_poll_cmd("@DEFAULT_SOURCE@", { "source-volume", "source-mute" }),
        function(stdout)
            local values = parse_kv(stdout)

            local volume = parse_volume_pct(values["source-volume"])
            if volume and self.default_source_volume ~= volume then
                self.default_source_volume = volume
                self:emit_signal("default-source::volume", volume)
            end

            local mute = parse_mute_bool(values["source-mute"])
            if self.default_source_mute ~= mute then
                self.default_source_mute = mute
                self:emit_signal("default-source::mute", mute)
            end

            if callback then
                callback(self.default_source_volume, self.default_source_mute)
            end
        end
    )
end

-- @tparam number|string value 0..100
function audio:set_default_source_volume(value)
    awful.spawn.with_shell(
        "pactl set-source-volume @DEFAULT_SOURCE@ " .. tostring(value) .. "%"
    )
end

function audio:toggle_default_source_mute()
    awful.spawn.with_shell("pactl set-source-mute @DEFAULT_SOURCE@ toggle")
end

-- Construct a fresh service instance (used internally by `get_default`).
-- @treturn gobject
local function new()
    local ret = gobject({})
    gtable.crush(ret, audio, true)

    ret.default_sink_volume = 0
    ret.default_sink_mute = false
    ret.default_source_volume = 0
    ret.default_source_mute = false

    -- Kick off the initial reads. Errors here are non-fatal — the service
    -- operates on whatever cached state it has.
    pcall(function()
        ret:get_default_sink_data()
    end)
    pcall(function()
        ret:get_default_source_data()
    end)

    return ret
end

-- Singleton accessor.
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
