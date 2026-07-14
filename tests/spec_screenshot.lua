--- Spec for `service.screenshot` pure helpers.
-- Tests the actual production `shell_quote` and `build_maim_cmd`
-- functions (no mirrored copies). Extracted via the same
-- source-rewriting technique used elsewhere in this suite.

local asrt = require("tests.assert")
local runner = ...

-- Stub the dependencies that the production module pulls in.
-- lgi is required; GIR loading must NOT happen.
package.loaded["lgi"] = {
    require = function()
        error("GIR not available in test")
    end,
}

-- awful: only the spawn API is referenced at runtime.
package.loaded["awful"] = {
    spawn = {
        with_shell = function() end,
        easy_async = function() end,
        easy_async_with_shell = function() end,
    },
}

-- naughty: only used in the failure notification path.
package.loaded["naughty"] = {
    notification = function() end,
}

-- gears.object: gobject({}) returns a plain table with signals.
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

-- gears.table
package.loaded["gears.table"] = {
    crush = function(t, m, _)
        for k, v in pairs(m) do
            t[k] = v
        end
        return t
    end,
}

-- lib: file_exists is required.
package.loaded["lib"] = {
    file_exists = function()
        return false
    end,
}

--- Load the production source, extract the two local helpers into
-- a returned `M` table, and short-circuit the rest.
local function load_helpers()
    local f = assert(io.open("service/screenshot/init.lua", "r"))
    local source = f:read("*a")
    f:close()

    -- Rewrite each `local function` decl to an M assignment.
    for _, name in ipairs({ "shell_quote", "build_maim_cmd" }) do
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
        '(local gtable = require%(%s*"gears%.table"%s*%))',
        "%1\nlocal M = {}"
    )

    -- Short-circuit after build_maim_cmd's end with `return M`.
    -- The function body ends with the `string.format` line followed by
    -- `end` and a blank. Use a literal pattern matching the exact line,
    -- then cut off everything after it (so the chunk doesn't try to
    -- parse the `function screenshot:take(args)` that follows).
    local marker =
        'return string.format("maim %s %s", args or "", shell_quote(outpath))\nend\n'
    local pos = source:find(marker, 1, true)
    if not pos then
        error("could not find build_maim_cmd end marker")
    end
    local cut = pos + #marker - 1
    source = source:sub(1, cut) .. "return M\n"

    -- Now rewrite internal references: `shell_quote(...)` inside
    -- build_maim_cmd must be `M.shell_quote(...)` since the local
    -- binding is gone. We do this AFTER the cut, so it only affects
    -- the kept portion.
    source = source:gsub("shell_quote%(outpath%)", "M.shell_quote(outpath)")

    local chunk, err = load(source, "service/screenshot/init.lua", "t")
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
local shell_quote = helpers.shell_quote
local build_maim_cmd = helpers.build_maim_cmd

runner.describe("screenshot:shell_quote", function()
    runner.it("wraps a plain path in single quotes", function()
        asrt.eq(
            shell_quote("/home/user/Pictures/foo.png"),
            "'/home/user/Pictures/foo.png'"
        )
    end)

    runner.it("escapes embedded single quotes", function()
        -- 'foo'bar becomes 'foo'\\''bar'
        asrt.eq(shell_quote("foo'bar"), "'foo'\\''bar'")
    end)

    runner.it("handles paths with spaces", function()
        asrt.eq(
            shell_quote("/home/user/My Pictures/foo.png"),
            "'/home/user/My Pictures/foo.png'"
        )
    end)

    runner.it("handles empty string", function()
        asrt.eq(shell_quote(""), "''")
    end)
end)

runner.describe("screenshot:build_maim_cmd", function()
    runner.it("emits empty args for full-screen", function()
        asrt.eq(build_maim_cmd("", "/tmp/out.png"), "maim  '/tmp/out.png'")
    end)

    runner.it("emits -s for selection", function()
        asrt.eq(build_maim_cmd("-s", "/tmp/out.png"), "maim -s '/tmp/out.png'")
    end)

    runner.it("emits -u -d N for delayed", function()
        asrt.eq(
            build_maim_cmd("-u -d 5", "/tmp/out.png"),
            "maim -u -d 5 '/tmp/out.png'"
        )
    end)

    runner.it("quotes output paths with spaces", function()
        local cmd = build_maim_cmd("-s", "/home/user/My Pictures/out.png")
        asrt.truthy(cmd:find("'/home/user/My Pictures/out.png'", 1, true))
    end)
end)
