--- Spec for the audio service's `key=value` parsers and pactl output decoders.
-- Mirrors the production parsers from `service/audio/init.lua` so we can
-- unit-test the algorithm without running pactl.

local assert = require("tests.assert")
local runner = ...

-- Mirror of build_poll_cmd / parse_kv from service/audio/init.lua
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

local function parse_volume_pct(raw)
    if not raw then
        return nil
    end
    return tonumber(raw:match("/%s+(%d+)%%"))
end

local function parse_mute_bool(raw)
    if not raw then
        return false
    end
    return raw:match("(%w+)$") == "yes"
end

runner.describe("audio:build_poll_cmd", function()
    runner.it("emits one printf per field", function()
        local cmd = build_poll_cmd("@DEFAULT_SINK@", { "sink-volume", "sink-mute" })
        assert.truthy(cmd:find("pactl get-sink-volume", 1, true))
        assert.truthy(cmd:find("pactl get-sink-mute", 1, true))
        assert.truthy(cmd:find("@DEFAULT_SINK@", 1, true))
    end)

    runner.it("uses sink- prefix for sink targets", function()
        local cmd = build_poll_cmd("@DEFAULT_SINK@", { "volume" })
        assert.truthy(cmd:find("pactl get-volume", 1, true))
        assert.falsy(cmd:find("source", 1, true))
    end)

    runner.it("uses source- prefix for source targets", function()
        local cmd = build_poll_cmd("@DEFAULT_SOURCE@", { "mute" })
        assert.truthy(cmd:find("pactl get-mute", 1, true))
        assert.truthy(cmd:find("@DEFAULT_SOURCE@", 1, true))
    end)
end)

runner.describe("audio:parse_kv", function()
    runner.it("parses a single line", function()
        local v = parse_kv("sink-volume=/ 78%")
        assert.eq(v["sink-volume"], "/ 78%")
    end)

    runner.it("parses multiple lines", function()
        local v = parse_kv("sink-volume=/ 78%\nsink-mute= no")
        assert.eq(v["sink-volume"], "/ 78%")
        assert.eq(v["sink-mute"], " no")
    end)

    runner.it("returns empty table for empty input", function()
        local v = parse_kv("")
        assert.eq(type(v), "table")
        assert.eq(next(v), nil)
    end)

    runner.it("ignores malformed lines", function()
        local v = parse_kv("malformed line\nsink-volume=/ 50%")
        assert.eq(v["sink-volume"], "/ 50%")
        assert.eq(v["malformed"], nil)
    end)
end)

runner.describe("audio:parse_volume_pct", function()
    runner.it("extracts percentage from pactl volume output", function()
        assert.eq(parse_volume_pct("/ 78%"), 78)
    end)

    runner.it("returns nil for empty input", function()
        assert.eq(parse_volume_pct(""), nil)
    end)

    runner.it("returns nil for nil input", function()
        assert.eq(parse_volume_pct(nil), nil)
    end)

    runner.it("handles full-volume readings", function()
        assert.eq(parse_volume_pct("/ 100%"), 100)
    end)
end)

runner.describe("audio:parse_mute_bool", function()
    runner.it("returns true for bare 'yes'", function()
        assert.eq(parse_mute_bool("yes"), true)
    end)

    runner.it("returns true for 'Mute: yes'", function()
        assert.eq(parse_mute_bool("Mute: yes"), true)
    end)

    runner.it("returns false for 'no'", function()
        assert.eq(parse_mute_bool(" Mute: no"), false)
    end)

    runner.it("returns false for nil", function()
        assert.eq(parse_mute_bool(nil), false)
    end)

    runner.it("returns false for empty string", function()
        assert.eq(parse_mute_bool(""), false)
    end)
end)
