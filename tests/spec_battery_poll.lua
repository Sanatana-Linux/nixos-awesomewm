--- Spec for `service.battery` pure helper `parse_kv`.
-- The production code defines `parse_kv` as a local function. We
-- extract it via the same source-rewriting technique used by
-- `spec_text_input.lua` and `spec_lib.lua`. The `update()` method
-- has a real shell-spawn dep, so we only test the pure parser.

local asrt = require("tests.assert")
local runner = ...

-- awful: stub easy_async_with_shell so module load doesn't fail.
package.loaded["awful"] = {
    spawn = {
        easy_async_with_shell = function() end,
    },
}

-- gears: only the timer factory is referenced at load time.
package.loaded["gears"] = {
    timer = function()
        return { start = function() end }
    end,
}

-- gears.object / gears.table
package.loaded["gears.object"] = {
    extend = function(self, other)
        for k, v in pairs(other) do
            self[k] = v
        end
    end,
    -- production uses gobject({}) which is gears.object()
    __call = function(_, t)
        return setmetatable(t or {}, {
            __index = {
                connect_signal = function() end,
                emit_signal = function() end,
            },
        })
    end,
}
-- Simpler mock: gobject returns a plain table with signals.
local function fake_gobject(t)
    local obj = t or {}
    function obj:connect_signal() end
    function obj:emit_signal() end
    return obj
end
package.loaded["gears.object"] = setmetatable({}, {
    __call = function(_, t)
        return fake_gobject(t)
    end,
})

package.loaded["gears.table"] = {
    crush = function(t, m, _)
        for k, v in pairs(m) do
            t[k] = v
        end
        return t
    end,
}

--- Load the production source, extract `parse_kv` and `update_num`
-- (the latter is a closure inside `update`, so we extract it via
-- `debug.getupvalue` after the file's chunk returns its module table).
-- Actually we only need `parse_kv` — the spec rewrites the file to
-- assign it to an `M` table.
local function load_helpers()
    local f = assert(io.open("service/battery/init.lua", "r"))
    local source = f:read("*a")
    f:close()

    -- Rewrite `local function parse_kv(line)` into an M assignment.
    source = source:gsub(
        "local function parse_kv%(line%)",
        "M.parse_kv = function(line)"
    )
    -- Inject `local M = {}` after the last require.
    source = source:gsub(
        '(local gtable = require%(%s*"gears%.table"%s*%))',
        "%1\nlocal M = {}"
    )
    -- After the parse_kv function's `end`, insert a return to short-circuit
    -- the rest (which uses awful.spawn and timers we don't want to fire).
    -- parse_kv's unique ending pattern is `return k, v\nend\n`.
    local replaced, n =
        source:gsub("(    return k, v\nend)\n.-$", "%1\nreturn M\n", 1)
    if n == 0 then
        error("could not find parse_kv end marker")
    end
    source = replaced

    local chunk, err = load(source, "service/battery/init.lua", "t")
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
local parse_kv = helpers.parse_kv

runner.describe("battery:parse_kv", function()
    runner.it("parses a simple key=value line", function()
        local k, v = parse_kv("capacity=87")
        asrt.eq(k, "capacity")
        asrt.eq(v, "87")
    end)

    runner.it("parses a value with spaces", function()
        local k, v = parse_kv("status=Discharging")
        asrt.eq(k, "status")
        asrt.eq(v, "Discharging")
    end)

    runner.it("parses an empty value", function()
        local k, v = parse_kv("energy_now=")
        asrt.eq(k, "energy_now")
        asrt.eq(v, "")
    end)

    runner.it("parses a value containing '='", function()
        local k, v = parse_kv("name=foo=bar")
        asrt.eq(k, "name")
        asrt.eq(v, "foo=bar")
    end)

    runner.it("returns nil for a non-key-value line", function()
        local k, v = parse_kv("not a kv line")
        asrt.eq(k, nil)
        asrt.eq(v, nil)
    end)

    runner.it("returns nil for an empty line", function()
        local k, v = parse_kv("")
        asrt.eq(k, nil)
        asrt.eq(v, nil)
    end)
end)
