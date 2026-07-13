--- Spec for `modules.snap_edge` geometry math.
-- The function depends on a global `screen` and `awful.placement`. We mock
-- both so the test can drive pure geometry math without a real X server.

local assert = require("tests.assert")
local runner = ...

-- ------------------------------------------------------------------
-- Mocks
-- ------------------------------------------------------------------

-- Mock screen: returns a single 1920x1080 workarea at (0, 0).
-- In AwesomeWM, `screen` is a callable (for `for s in screen do ... end`)
-- AND subscriptable (for `screen[1]`, `screen.primary`). We use a callable
-- table to support both.
local mock_screen_obj = {
    geometry = { x = 0, y = 0, width = 1920, height = 1080 },
    workarea = { x = 0, y = 0, width = 1920, height = 1080 },
}
setmetatable(mock_screen_obj, {
    __call = function() return mock_screen_obj end,
    __index = function(t, k) return rawget(t, k) end,
})
_G.screen = mock_screen_obj
-- For the screen[c.screen] indexing used in the production code:
-- c.screen is the screen index. The production reads `screen[c.screen]`.
-- In our mock we make screen[any_key] return the same screen.
setmetatable(_G.screen, {
    __call = function() return _G.screen end,
    __index = function() return _G.screen end,
})

-- Mock awful.placement with the methods snap_edge uses.
package.loaded["awful"] = {
    placement = {
        center_horizontal = function(c) end,
        centered = function(c) end,
        no_offscreen = function(c) end,
    },
}

-- Mock client constructor.
local function make_client(opts)
    opts = opts or {}
    local c = {
        border_width = opts.border_width or 0,
        floating = opts.floating or false,
        maximized = opts.maximized or false,
        struts_value = { left = 0, right = 0, top = 0, bottom = 0 },
        geometry_value = opts.geometry or { x = 0, y = 0, width = 100, height = 100 },
    }
    function c:struts(s)
        if s then
            self.struts_value = s
        end
        return self.struts_value
    end
    function c:geometry(g)
        if g then
            self.geometry_value = g
        end
        return self.geometry_value
    end
    return c
end

-- Load the production snap_edge after the mocks are in place.
local snap_edge = require("modules.snap_edge")

runner.describe("snap_edge:right", function()
    runner.it("resizes to right half and positions at right edge", function()
        local c = make_client({ border_width = 0 })
        snap_edge(c, "right")
        -- Right half: width = 1920/2 - 0 = 960, height = 1080
        assert.eq(c.geometry_value.width, 960)
        assert.eq(c.geometry_value.height, 1080)
        -- x = workarea.x_max - width = 1920 - 960 = 960
        assert.eq(c.geometry_value.x, 960)
        assert.eq(c.geometry_value.y, 0)
    end)

    runner.it("accounts for border width in width calculation", function()
        local c = make_client({ border_width = 5 })
        snap_edge(c, "right")
        -- width = 1920/2 - 2*5 = 950
        assert.eq(c.geometry_value.width, 950)
    end)

    runner.it("sets floating=true and unsets maximized", function()
        local c = make_client({ maximized = true })
        snap_edge(c, "right")
        assert.truthy(c.floating)
        assert.falsy(c.maximized)
    end)
end)

runner.describe("snap_edge:left", function()
    runner.it("resizes to left half and positions at left edge", function()
        local c = make_client({ border_width = 0 })
        snap_edge(c, "left")
        assert.eq(c.geometry_value.width, 960)
        assert.eq(c.geometry_value.height, 1080)
        assert.eq(c.geometry_value.x, 0)
        assert.eq(c.geometry_value.y, 0)
    end)
end)

runner.describe("snap_edge:top", function()
    runner.it("resizes to top half and positions at top edge", function()
        local c = make_client({ border_width = 0 })
        snap_edge(c, "top")
        assert.eq(c.geometry_value.width, 1920)
        assert.eq(c.geometry_value.height, 540)
        assert.eq(c.geometry_value.x, 0)
        assert.eq(c.geometry_value.y, 0)
    end)
end)

runner.describe("snap_edge:bottom", function()
    runner.it("resizes to bottom half and positions at bottom edge", function()
        local c = make_client({ border_width = 0 })
        snap_edge(c, "bottom")
        assert.eq(c.geometry_value.width, 1920)
        assert.eq(c.geometry_value.height, 540)
        -- y = workarea.y_max - height = 1080 - 540 = 540
        assert.eq(c.geometry_value.y, 540)
    end)
end)

runner.describe("snap_edge:quadrants", function()
    runner.it("topleft fills the top-left quarter", function()
        local c = make_client({ border_width = 0 })
        snap_edge(c, "topleft")
        assert.eq(c.geometry_value.width, 960)
        assert.eq(c.geometry_value.height, 540)
        assert.eq(c.geometry_value.x, 0)
        assert.eq(c.geometry_value.y, 0)
    end)

    runner.it("topright fills the top-right quarter", function()
        local c = make_client({ border_width = 0 })
        snap_edge(c, "topright")
        assert.eq(c.geometry_value.width, 960)
        assert.eq(c.geometry_value.height, 540)
        assert.eq(c.geometry_value.x, 960)
        assert.eq(c.geometry_value.y, 0)
    end)

    runner.it("bottomleft fills the bottom-left quarter", function()
        local c = make_client({ border_width = 0 })
        snap_edge(c, "bottomleft")
        assert.eq(c.geometry_value.width, 960)
        assert.eq(c.geometry_value.height, 540)
        assert.eq(c.geometry_value.x, 0)
        assert.eq(c.geometry_value.y, 540)
    end)

    runner.it("bottomright fills the bottom-right quarter", function()
        local c = make_client({ border_width = 0 })
        snap_edge(c, "bottomright")
        assert.eq(c.geometry_value.width, 960)
        assert.eq(c.geometry_value.height, 540)
        assert.eq(c.geometry_value.x, 960)
        assert.eq(c.geometry_value.y, 540)
    end)
end)

runner.describe("snap_edge:center", function()
    runner.it("calls awful.placement.centered (delegates to layout)", function()
        local called = false
        package.loaded["awful"].placement.centered = function(c)
            called = true
        end
        local c = make_client({})
        snap_edge(c, "center")
        assert.truthy(called)
    end)

    runner.it("returns early (no further mutations)", function()
        package.loaded["awful"].placement.centered = function(c) end
        local c = make_client({})
        local orig_geom = c.geometry_value
        snap_edge(c, "center", { x = 999, y = 999, width = 50, height = 50 })
        -- c.geometry_value is unchanged because center delegates to
        -- awful.placement.centered which is a no-op in our mock
        assert.eq(c.geometry_value, orig_geom)
    end)
end)

runner.describe("snap_edge:nil (reset)", function()
    runner.it("restores the original struts and geometry when called with nil", function()
        local c = make_client({ border_width = 0 })
        local original_geom = c.geometry_value
        -- First snap
        snap_edge(c, "right")
        assert.eq(c.geometry_value.width, 960) -- was changed
        -- Then reset with nil
        snap_edge(c, nil)
        -- c.geometry_value is restored to what was passed in originally
        assert.eq(c.geometry_value, original_geom)
    end)
end)
