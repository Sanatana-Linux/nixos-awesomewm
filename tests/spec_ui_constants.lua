--- Spec for `modules.ui_constants` token table.
-- The constants are computed at load time via `dpi(...)` (which we mock to
-- pass-through) — the test verifies the structure and that the values
-- survive the load.

local assert = require("tests.assert")
local runner = ...

-- Mock `beautiful` so the module loads without a real X server.
package.loaded["beautiful"] = {
    xresources = {
        apply_dpi = function(x)
            return x
        end,
    },
}

-- Reset and require the module.
package.loaded["modules.style.ui_constants"] = nil
local ui_constants = require("modules.style.ui_constants")

runner.describe("ui_constants:structure", function()
    runner.it("has a SPACING group with 6 tokens", function()
        assert.type(ui_constants.SPACING, "table")
        assert.eq(type(ui_constants.SPACING.TINY), "number")
        assert.eq(type(ui_constants.SPACING.SMALL), "number")
        assert.eq(type(ui_constants.SPACING.MEDIUM), "number")
        assert.eq(type(ui_constants.SPACING.LARGE), "number")
        assert.eq(type(ui_constants.SPACING.XLARGE), "number")
        assert.eq(type(ui_constants.SPACING.XXLARGE), "number")
    end)

    runner.it("has a RADIUS group with 4 raw-pixel tokens", function()
        assert.type(ui_constants.RADIUS, "table")
        assert.eq(type(ui_constants.RADIUS.SMALL), "number")
        assert.eq(type(ui_constants.RADIUS.MEDIUM), "number")
        assert.eq(type(ui_constants.RADIUS.LARGE), "number")
        assert.eq(type(ui_constants.RADIUS.XLARGE), "number")
    end)

    runner.it("has an ANIMATION group with timing defaults", function()
        assert.type(ui_constants.ANIMATION, "table")
        assert.eq(type(ui_constants.ANIMATION.DURATION_SHORT), "number")
        assert.type(ui_constants.ANIMATION.EASING_DEFAULT, "string")
        assert.truthy(ui_constants.ANIMATION.EASING_DEFAULT == "quadratic")
    end)

    runner.it("has a BUTTON group with bar and icon sizes", function()
        assert.type(ui_constants.BUTTON, "table")
        assert.eq(type(ui_constants.BUTTON.BAR_SIZE), "number")
        assert.eq(type(ui_constants.BUTTON.ICON_SIZE), "number")
        assert.eq(type(ui_constants.BUTTON.SMALL_ICON_SIZE), "number")
    end)

    runner.it("has a BORDER group with 2 thickness tokens", function()
        assert.type(ui_constants.BORDER, "table")
        assert.eq(type(ui_constants.BORDER.THIN), "number")
        assert.eq(type(ui_constants.BORDER.MEDIUM), "number")
    end)

    runner.it("has a COLORS group with reusable hex colors", function()
        assert.type(ui_constants.COLORS, "table")
        assert.eq(type(ui_constants.COLORS.WHITE), "string")
        assert.eq(type(ui_constants.COLORS.TRANSPARENT_BLACK), "string")
        assert.eq(type(ui_constants.COLORS.SEMI_TRANSPARENT_BLACK), "string")
    end)
end)

runner.describe("ui_constants:spacing progression", function()
    runner.it("SPACING tokens are strictly increasing", function()
        local s = ui_constants.SPACING
        assert.truthy(s.TINY < s.SMALL)
        assert.truthy(s.SMALL < s.MEDIUM)
        assert.truthy(s.MEDIUM < s.LARGE)
        assert.truthy(s.LARGE < s.XLARGE)
        assert.truthy(s.XLARGE < s.XXLARGE)
    end)
end)

runner.describe("ui_constants:colors", function()
    runner.it("WHITE is exactly #FFFFFF", function()
        assert.eq(ui_constants.COLORS.WHITE, "#FFFFFF")
    end)

    runner.it("alpha-suffixed colors end with 2 hex digits", function()
        local c = ui_constants.COLORS
        assert.truthy(c.TRANSPARENT_BLACK:match("^#%x%x%x%x%x%x%x%x$"))
        assert.truthy(c.SEMI_TRANSPARENT_BLACK:match("^#%x%x%x%x%x%x%x%x$"))
    end)
end)
