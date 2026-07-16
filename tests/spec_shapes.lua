--- Spec for `modules.style.shapes` factories.
-- The shape factories all return closures `(cr, w, h) -> nil` that call into
-- `gears.shape.*` to draw on a cairo context. We mock `gears.shape` with a
-- recorder so the spec can verify the call arguments without a real cairo
-- surface. Since the production module requires `gears.shape` at load time,
-- we stub it via a `package.loaded` override before requiring `modules.style.shapes`.

local assert = require("tests.assert")
local runner = ...

-- Mock `gears.shape` with a recording stub.
local recorded = {}
local fake_shape = {}
for _, fname in ipairs({
    "rounded_rect",
    "rounded_bar",
    "partially_rounded_rect",
    "circle",
}) do
    fake_shape[fname] = function(cr, w, h, ...)
        table.insert(recorded, { fname = fname, w = w, h = h, args = { ... } })
    end
end

-- Stub the require.
package.loaded["gears.shape"] = fake_shape

-- Force a fresh load of the production module. Earlier specs (e.g.
-- spec_menu) may have already required it, in which case Lua would
-- return the cached module — bound to whatever `gears.shape` looked
-- like at that earlier load. Reset to nil so we get a fresh module
-- bound to the recorder above.
package.loaded["modules.style.shapes"] = nil

-- Now load the production module.
-- It also requires `beautiful`, so stub that too with a fake dpi().
package.loaded["beautiful"] = {
    xresources = {
        apply_dpi = function(x)
            return x
        end,
    },
}
local shapes = require("modules.style.shapes")

runner.describe("shapes.rrect", function()
    runner.it(
        "returns a closure that calls gears.shape.rounded_rect",
        function()
            recorded = {}
            local shape = shapes.rrect(10)
            assert.type(shape, "function")
            shape(nil, 100, 50)
            assert.eq(#recorded, 1)
            assert.eq(recorded[1].fname, "rounded_rect")
            assert.eq(recorded[1].w, 100)
            assert.eq(recorded[1].h, 50)
        end
    )
end)

runner.describe("shapes.rbar", function()
    runner.it("returns a closure that calls gears.shape.rounded_bar", function()
        recorded = {}
        local shape = shapes.rbar()
        shape(nil, 200, 30)
        assert.eq(#recorded, 1)
        assert.eq(recorded[1].fname, "rounded_bar")
        assert.eq(recorded[1].w, 200)
    end)
end)

runner.describe("shapes.prrect", function()
    runner.it(
        "passes per-corner radii and DPI-scaled uniform radius",
        function()
            recorded = {}
            local shape = shapes.prrect(5, 10, 15, 20, 100)
            shape(nil, 80, 60)
            assert.eq(#recorded, 1)
            assert.eq(recorded[1].fname, "partially_rounded_rect")
            assert.eq(recorded[1].w, 80)
            assert.eq(recorded[1].h, 60)
            -- Args should be (tl, tr, br, bl, dpi(rad)) = (5, 10, 15, 20, 100)
            assert.eq(recorded[1].args[1], 5)
            assert.eq(recorded[1].args[2], 10)
            assert.eq(recorded[1].args[3], 15)
            assert.eq(recorded[1].args[4], 20)
            assert.eq(recorded[1].args[5], 100)
        end
    )
end)

runner.describe("shapes.circle", function()
    runner.it("calls gears.shape.circle with width/height", function()
        recorded = {}
        local shape = shapes.circle(15)
        shape(nil, 60, 60)
        assert.eq(#recorded, 1)
        assert.eq(recorded[1].fname, "circle")
        assert.eq(recorded[1].w, 60)
        assert.eq(recorded[1].h, 60)
    end)
end)
