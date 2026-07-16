--- Spec for the utility helpers in `lib.util` (formerly `awful.util`).
-- These tests require the production module directly since none of these
-- functions need the AwesomeWM runtime.

local assert = require("tests.assert")
local runner = ...
local color_alpha = require("lib.util").color_alpha
local config_path = require("lib.util").config_path

runner.describe("lib.util.color_alpha", function()
    runner.it("appends alpha to 6-digit hex", function()
        assert.eq(color_alpha("#ff8800", "88"), "#ff880088")
    end)

    runner.it(
        "appends alpha to bare 6-digit hex without leading hash",
        function()
            assert.eq(color_alpha("00ff00", "cc"), "#00ff00cc")
        end
    )

    runner.it(
        "appends alpha to already-alpha-suffixed input (additive)",
        function()
            -- This is by design: the helper assumes RRGGBB input and always
            -- appends 2 more hex digits, giving RRGGBBAA. If you pass RRGGBBAA
            -- you get RRGGBBAAAA. Strip a trailing alpha first if that's not
            -- what you want.
            assert.eq(color_alpha("#ff880099", "44"), "#ff88009944")
        end
    )
end)

runner.describe("lib.util.config_path", function()
    runner.it("joins components under ~/.config/awesome/", function()
        os.getenv = function(k)
            if k == "HOME" then
                return "/home/test"
            end
            return nil
        end
        assert.eq(config_path("ui", "bar"), "/home/test/.config/awesome/ui/bar")
    end)

    runner.it("returns empty prefix when HOME is unset", function()
        os.getenv = function()
            return nil
        end
        local result = config_path("a", "b")
        assert.truthy(result:find("/.config/awesome/a/b"))
    end)
end)
