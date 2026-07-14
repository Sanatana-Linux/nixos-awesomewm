--- Spec for `service.audio` pure helpers.
-- Tests the actual production functions (no mirrored copies) by
-- extracting them from the production source via the same
-- source-rewriting technique used by `spec_text_input.lua` and
-- `spec_battery_poll.lua`. The `audio` service's `get_default_sink_data`
-- and friends depend on `awful.spawn` — those are not tested here.

local asrt = require("tests.assert")
local runner = ...

-- awful: spawn with_shell and easy_async_with_shell — stubbed.
package.loaded["awful"] = {
    spawn = {
        with_shell = function() end,
        easy_async = function() end,
        easy_async_with_shell = function() end,
    },
}

-- gears.object: gobject({}) returns a plain table with signals.
local function fake_gobject(t)
    local obj = t or {}
    function obj:connect_signal() end
    function obj:emit_signal() end
    return obj
end
package.loaded["gears.object"] = setmetatable({}, {
    __call = function(_, t) return fake_gobject(t) end,
})

-- gears.table
package.loaded["gears.table"] = {
    crush = function(t, m, _)
        for k, v in pairs(m) do
            t[k] = v
        end
        return t
    end,
}

-- gears.debug
package.loaded["gears.debug"] = {
    print_error = function() end,
}

--- Load the production source, extract the four local helpers into
-- a returned `M` table, and short-circuit the rest.
local function load_helpers()
    local f = assert(io.open("service/audio/init.lua", "r"))
    local source = f:read("*a")
    f:close()

    -- Rewrite each `local function` decl to an M assignment.
    local helpers = { "build_poll_cmd", "parse_kv", "parse_volume_pct", "parse_mute_bool" }
    for _, name in ipairs(helpers) do
        local pat = "local function " .. name .. "%("
        local repl = "M." .. name .. " = function("
        local replaced, n = source:gsub(pat, repl, 1)
        if n == 0 then
            error("could not rewrite " .. name)
        end
        source = replaced
    end

    -- Inject `local M = {}` after the gears.table require.
    source = source:gsub(
        "(local gtable = require%(%s*\"gears%.table\"%s*%))",
        "%1\nlocal M = {}"
    )

    -- Short-circuit after the last helper's `end` with `return M`.
    -- The last helper is parse_mute_bool — its body ends with a
    -- `return raw:match("(%w+)$") == "yes"\nend`. We match that
    -- unique pattern.
    local replaced, n = source:gsub(
        "(    return raw:match%(\"%(%%%w%+%)$\"%) == \"yes\"\nend)\n.-$",
        "%1\nreturn M\n",
        1
    )
    if n == 0 then
        error("could not find parse_mute_bool end marker")
    end
    source = replaced

    local chunk, err = load(source, "service/audio/init.lua", "t")
    if not chunk then
        error("compile failed: " .. tostring(err))
    end
    local ok, result = pcall(chunk)
    if not ok then
        error("execution failed: " .. tostring(result))
    end
    return result
end

local helpers = load_helpers()
local build_poll_cmd = helpers.build_poll_cmd
local parse_kv = helpers.parse_kv
local parse_volume_pct = helpers.parse_volume_pct
local parse_mute_bool = helpers.parse_mute_bool

runner.describe("audio:build_poll_cmd", function()
    runner.it("emits one printf per field", function()
        local cmd = build_poll_cmd("@DEFAULT_SINK@", { "sink-volume", "sink-mute" })
        asrt.truthy(cmd:find("pactl get-sink-volume", 1, true))
        asrt.truthy(cmd:find("pactl get-sink-mute", 1, true))
        asrt.truthy(cmd:find("@DEFAULT_SINK@", 1, true))
    end)

    runner.it("uses sink- prefix for sink targets", function()
        local cmd = build_poll_cmd("@DEFAULT_SINK@", { "volume" })
        asrt.truthy(cmd:find("pactl get-volume", 1, true))
        asrt.falsy(cmd:find("source", 1, true))
    end)

    runner.it("uses source- prefix for source targets", function()
        local cmd = build_poll_cmd("@DEFAULT_SOURCE@", { "mute" })
        asrt.truthy(cmd:find("pactl get-mute", 1, true))
        asrt.truthy(cmd:find("@DEFAULT_SOURCE@", 1, true))
    end)
end)

runner.describe("audio:parse_kv", function()
    runner.it("parses a single line", function()
        local v = parse_kv("sink-volume=/ 78%")
        asrt.eq(v["sink-volume"], "/ 78%")
    end)

    runner.it("parses multiple lines", function()
        local v = parse_kv("sink-volume=/ 78%\nsink-mute= no")
        asrt.eq(v["sink-volume"], "/ 78%")
        asrt.eq(v["sink-mute"], " no")
    end)

    runner.it("returns empty table for empty input", function()
        local v = parse_kv("")
        asrt.eq(type(v), "table")
        asrt.eq(next(v), nil)
    end)

    runner.it("ignores malformed lines", function()
        local v = parse_kv("malformed line\nsink-volume=/ 50%")
        asrt.eq(v["sink-volume"], "/ 50%")
        asrt.eq(v["malformed"], nil)
    end)
end)

runner.describe("audio:parse_volume_pct", function()
    runner.it("extracts percentage from pactl volume output", function()
        asrt.eq(parse_volume_pct("/ 78%"), 78)
    end)

    runner.it("returns nil for empty input", function()
        asrt.eq(parse_volume_pct(""), nil)
    end)

    runner.it("returns nil for nil input", function()
        asrt.eq(parse_volume_pct(nil), nil)
    end)

    runner.it("handles full-volume readings", function()
        asrt.eq(parse_volume_pct("/ 100%"), 100)
    end)
end)

runner.describe("audio:parse_mute_bool", function()
    runner.it("returns true for bare 'yes'", function()
        asrt.eq(parse_mute_bool("yes"), true)
    end)

    runner.it("returns true for 'Mute: yes'", function()
        asrt.eq(parse_mute_bool("Mute: yes"), true)
    end)

    runner.it("returns false for 'no'", function()
        asrt.eq(parse_mute_bool(" Mute: no"), false)
    end)

    runner.it("returns false for nil", function()
        asrt.eq(parse_mute_bool(nil), false)
    end)

    runner.it("returns false for empty string", function()
        asrt.eq(parse_mute_bool(""), false)
    end)
end)
