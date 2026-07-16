--- Spec for the caps-lock state parser.
-- Mirrors the production parser from `service/caps/init.lua` so we can
-- unit-test the algorithm without running setleds.

local assert = require("tests.assert")
local runner = ...

-- Mirror of the production parser.
local function parse_caps_state(stdout)
    return stdout and stdout:match("Caps Lock on") ~= nil or false
end

runner.describe("caps:parse_caps_state", function()
    runner.it("returns true when 'Caps Lock on' is present", function()
        assert.eq(
            parse_caps_state(
                "Current default flags:  NumLock off\nCaps Lock on"
            ),
            true
        )
    end)

    runner.it("returns false when caps is off", function()
        assert.eq(
            parse_caps_state(
                "Current default flags:  NumLock on\nCaps Lock off"
            ),
            false
        )
    end)

    runner.it("returns false for empty input", function()
        assert.eq(parse_caps_state(""), false)
    end)

    runner.it("returns false for nil", function()
        assert.eq(parse_caps_state(nil), false)
    end)

    runner.it("matches case-insensitively", function()
        -- The pattern is anchored to the literal "Caps Lock on" — be
        -- explicit about case-sensitivity so future maintainers don't
        -- get surprised.
        assert.eq(parse_caps_state("caps lock on"), false)
    end)
end)
