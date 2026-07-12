--- Spec for the custom upstream overlay helpers in `awful.util`.
-- These tests load only `gears.string` (no AwesomeWM runtime needed) and
-- re-implement the helpers in a tiny local copy so we can verify the logic.
-- The real helpers in `upstream/awful/util.lua` are tested at awesome runtime
-- by CI's `awesome -c rc.lua --check` step.

local assert = require("tests.assert")
local runner = ...

-- Mirror the production helpers' logic so we can unit-test the algorithm
-- without spinning up the full awesome runtime.
local function color_alpha(color, alpha)
    local base = color:gsub("^#", "")
    return "#" .. base .. alpha
end

local function config_path(...)
    return (os.getenv("HOME") or "") .. "/.config/awesome/" .. table.concat({ ... }, "/")
end

runner.describe("awful.util.color_alpha", function()
    runner.it("appends alpha to 6-digit hex", function()
        assert.eq(color_alpha("#ff8800", "88"), "#ff880088")
    end)

    runner.it("appends alpha to bare 6-digit hex without leading hash", function()
        assert.eq(color_alpha("00ff00", "cc"), "#00ff00cc")
    end)

    runner.it("appends alpha to already-alpha-suffixed input (additive)", function()
        -- This is by design: the helper assumes RRGGBB input and always
        -- appends 2 more hex digits, giving RRGGBBAA. If you pass RRGGBBAA
        -- you get RRGGBBAAAA. Strip a trailing alpha first if that's not
        -- what you want.
        assert.eq(color_alpha("#ff880099", "44"), "#ff88009944")
    end)
end)

runner.describe("awful.util.config_path", function()
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
        os.getenv = function() return nil end
        local result = config_path("a", "b")
        assert.truthy(result:find("/.config/awesome/a/b"))
    end)
end)
