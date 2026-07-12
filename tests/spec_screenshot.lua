--- Spec for the screenshot service's shell-quoting helpers.
-- Mirrors `shell_quote` and `build_maim_cmd` from `service/screenshot/init.lua`.

local assert = require("tests.assert")
local runner = ...

-- Mirror the production helpers.
local function shell_quote(path)
    return "'" .. path:gsub("'", "'\\''") .. "'"
end

local function build_maim_cmd(args, outpath)
    return string.format("maim %s %s", args or "", shell_quote(outpath))
end

runner.describe("screenshot:shell_quote", function()
    runner.it("wraps a plain path in single quotes", function()
        assert.eq(shell_quote("/home/user/Pictures/foo.png"), "'/home/user/Pictures/foo.png'")
    end)

    runner.it("escapes embedded single quotes", function()
        -- 'foo'bar becomes 'foo'\\''bar'
        assert.eq(shell_quote("foo'bar"), "'foo'\\''bar'")
    end)

    runner.it("handles paths with spaces", function()
        assert.eq(
            shell_quote("/home/user/My Pictures/foo.png"),
            "'/home/user/My Pictures/foo.png'"
        )
    end)

    runner.it("handles empty string", function()
        assert.eq(shell_quote(""), "''")
    end)
end)

runner.describe("screenshot:build_maim_cmd", function()
    runner.it("emits empty args for full-screen", function()
        assert.eq(
            build_maim_cmd("", "/tmp/out.png"),
            "maim  '/tmp/out.png'"
        )
    end)

    runner.it("emits -s for selection", function()
        assert.eq(build_maim_cmd("-s", "/tmp/out.png"), "maim -s '/tmp/out.png'")
    end)

    runner.it("emits -u -d N for delayed", function()
        assert.eq(
            build_maim_cmd("-u -d 5", "/tmp/out.png"),
            "maim -u -d 5 '/tmp/out.png'"
        )
    end)

    runner.it("quotes output paths with spaces", function()
        local cmd = build_maim_cmd("-s", "/home/user/My Pictures/out.png")
        assert.truthy(cmd:find("'/home/user/My Pictures/out.png'", 1, true))
    end)
end)
