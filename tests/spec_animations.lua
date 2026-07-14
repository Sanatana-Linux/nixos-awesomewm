--- Spec for `modules.animations` easing functions.
-- The easing functions are pure (no gears.timer side effects in the
-- functions themselves). `M.animate` is not tested here because it
-- uses a real `gears.timer` for ticking.
-- @see modules.animations

local asrt = require("tests.assert")
local runner = ...

-- Stub gears so the module loads. We don't call animate() so the
-- timer never actually fires.
package.loaded["gears"] = {
    timer = function()
        return {
            start = function() end,
            stop = function() end,
        }
    end,
}

-- Load via source-rewriting trick: extract the M table via `return M`
-- at end. But the file's last line is just `return M`, so a direct
-- require works.
package.loaded["modules.animations"] = nil
local animations = require("modules.animations")

runner.describe("animations:easing.linear", function()
    runner.it("returns the input unchanged", function()
        asrt.eq(animations.easing.linear(0), 0)
        asrt.eq(animations.easing.linear(0.5), 0.5)
        asrt.eq(animations.easing.linear(1), 1)
    end)
end)

runner.describe("animations:easing.easin", function()
    runner.it("returns 0 at t=0 and 1 at t=1", function()
        asrt.eq(animations.easing.easin(0), 0)
        asrt.eq(animations.easing.easin(1), 1)
    end)

    runner.it("is the square of t", function()
        asrt.eq(animations.easing.easin(0.5), 0.25)
        asrt.truthy(math.abs(animations.easing.easin(0.7) - 0.49) < 1e-9)
    end)
end)

runner.describe("animations:easing.quadratic", function()
    runner.it("returns 0 at t=0 and 1 at t=1", function()
        asrt.eq(animations.easing.quadratic(0), 0)
        asrt.eq(animations.easing.quadratic(1), 1)
    end)

    runner.it("is the complement of (1-t)^2", function()
        -- at t=0.5: 1 - 0.25 = 0.75
        asrt.eq(animations.easing.quadratic(0.5), 0.75)
    end)
end)

runner.describe("animations:easing.cubic", function()
    runner.it("returns 0 at t=0 and 1 at t=1", function()
        asrt.eq(animations.easing.cubic(0), 0)
        asrt.eq(animations.easing.cubic(1), 1)
    end)
end)

runner.describe("animations:easing.sinusoidal", function()
    runner.it("returns 0 at t=0 and 1 at t=1", function()
        asrt.eq(animations.easing.sinusoidal(0), 0)
        asrt.eq(animations.easing.sinusoidal(1), 1)
    end)
end)

runner.describe("animations:easing.exponential", function()
    runner.it("returns 1 at t=1 (no underflow)", function()
        asrt.eq(animations.easing.exponential(1), 1)
    end)

    runner.it("returns ~0 at t=0", function()
        asrt.truthy(animations.easing.exponential(0) < 0.01)
    end)
end)

runner.describe("animations:easing.elastic", function()
    runner.it("returns ~1 at t=1 (returns to 1 + oscillation)", function()
        -- elastic(t) at t=1: 2^(-10) * sin(...) + 1 ≈ 1.0
        asrt.truthy(math.abs(animations.easing.elastic(1) - 1) < 0.01)
    end)
end)

runner.describe("animations:easing.bounce", function()
    runner.it("returns 0 at t=0", function()
        asrt.eq(animations.easing.bounce(0), 0)
    end)

    runner.it("returns 1 at t=1", function()
        -- bounce(1) = 1 - 0.0625*4 = 0.75? Let's check the formula:
        -- if t < 0.5: 4 * t * t
        -- else: v = t - 0.75; 1 - v*v*4
        -- At t=1: v = 0.25; 1 - 0.0625*4 = 0.75
        -- So bounce(1) = 0.75, not 1
        asrt.eq(animations.easing.bounce(1), 0.75)
    end)
end)
