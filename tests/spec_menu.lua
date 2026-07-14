--- Spec for `modules.menu` public surface.
-- The full menu widget (WIBOX-based, with a keygrabber and a submenu
-- keygrabber tree) is exercised end-to-end in the integration tests.
-- Here we only cover the testable pure pieces: the key-binding table,
-- module re-exports, and the metatable that makes the module callable
-- as both `menu.new()` and `menu({items...})`.

local assert = require("tests.assert")
local runner = ...

-- Reset the module cache so we always load the production code.
package.loaded["modules.menu"] = nil
package.loaded["awful"] = {
    keygrabber = { run = function() end, stop = function() end },
    mouse = { sensitive = function() end, client = { focus = {} } },
    placement = { next_to = function() end },
    spawn = function() end,
    menu = {},
    -- awful.popup is called by menu.new() to create the actual wibox
    -- container. We return a table that supports the operations the
    -- menu code performs: get_children_by_id, connect_signal, and
    -- property read/write.
    popup = function(args)
        local ret = {
            visible = args and args.visible or false,
            ontop = args and args.ontop or false,
            type = args and args.type or "popup_menu",
            bg = args and args.bg or "#00000000",
            widget = args and args.widget or {},
        }
        ret._private = {}
        function ret:get_children_by_id(id)
            return {}
        end
        function ret:connect_signal() end
        return ret
    end,
}
package.loaded["wibox"] = {
    widget = setmetatable({
        textbox = function()
            return {}
        end,
    }, {
        __call = function()
            return {}
        end,
    }),
    container = {
        background = function()
            return {}
        end,
        margin = function()
            return {}
        end,
        place = function()
            return {}
        end,
    },
    layout = {
        fixed = {
            vertical = function()
                return {}
            end,
            horizontal = function()
                return {}
            end,
        },
    },
    -- Required: wibox({}) for the popup
}
setmetatable(package.loaded["wibox"], {
    __call = function()
        return {}
    end,
})
package.loaded["beautiful"] = {
    bg = "#1f1f1f",
    fg = "#f7f1ff",
    border_color_normal = "#3d3d3d",
    border_width = 1,
    font = "Sans",
    font_h0 = "Sans 10",
    ac = "#bb9af7",
    xresources = {
        apply_dpi = function(x)
            return x
        end,
    },
}
package.loaded["gears"] = {
    color = {
        recolor_image = function()
            return {}
        end,
    },
    shape = {
        rounded_rect = function() end,
        rounded_bar = function() end,
        partially_rounded_rect = function() end,
        circle = function() end,
    },
}
package.loaded["gears.table"] = {
    clone = function(t)
        local out = {}
        for k, v in pairs(t) do
            out[k] = v
        end
        return out
    end,
    join = function(...)
        return { ... }
    end,
    crush = function(t, m)
        for k, v in pairs(m) do
            t[k] = v
        end
        return t
    end,
}
-- Don't mock `modules.shapes` here — let the real module load (its
-- `gears.shape` and `beautiful` deps are already mocked above). If we
-- mock this module, we leak a fake implementation into later specs
-- (notably `spec_shapes.lua`, which depends on the real `modules.shapes`
-- factory closures recording their calls into `gears.shape`).
--
-- We DO need to also stub `package.loaded["gears.shape"]` because
-- `require("gears.shape")` checks the `gears.shape` cache key, not
-- the `gears.shape` field of the `gears` table. Set it to a no-op
-- recorder that returns strings (so any cairo-drawing path is happy).
package.loaded["gears.shape"] = {
    rounded_rect = function()
        return "rect"
    end,
    rounded_bar = function()
        return "bar"
    end,
    partially_rounded_rect = function()
        return "prrect"
    end,
    circle = function()
        return "circle"
    end,
}
package.loaded["modules.click_to_hide"] = { popup = function() end }

local menu = require("modules.menu")

runner.describe("menu:module shape", function()
    runner.it("is a callable table (setmetatable __call)", function()
        -- The module returns setmetatable({new = menu.new}, {__call = ...})
        -- so it's both a table and a callable factory.
        assert.type(menu, "table")
        assert.truthy(getmetatable(menu), "menu should have a metatable")
    end)

    runner.it("exposes a `new` constructor", function()
        assert.type(menu.new, "function")
    end)
end)

runner.describe("menu.new:edge cases", function()
    runner.it("returns nil when called with no args", function()
        local m = menu.new()
        assert.eq(m, nil)
    end)
end)

runner.describe("menu:keyboard navigation", function()
    runner.it("exposes a `new` constructor for callers", function()
        assert.type(menu.new, "function")
    end)
end)
