--- Spec for `modules.hover_button` setters.
-- `hover_button` returns a wibox widget whose interface depends on the
-- real wibox library. We mock `wibox` with a minimal recordable stub and
-- verify the public setters (`set_label`, `set_bg_normal`, `set_fg_normal`,
-- `set_bg_hover`, `set_fg_hover`) correctly mutate `_private` and call
-- the underlying wibox methods.

local assert = require("tests.assert")
local runner = ...

-- ------------------------------------------------------------------
-- Mock: build a minimal wibox stub
-- ------------------------------------------------------------------
-- Track which constructor was called and with what args.
-- Declared at top-level so the closures below can read/write it.
local created_widgets = {}

local function make_widget_stub()
    local w = {
        _private = {},
        bg_set = nil,
        fg_set = nil,
        _children_by_id = {},
    }
    function w:connect_signal(signal, handler)
        if not self._private[signal] then
            self._private[signal] = {}
        end
        table.insert(self._private[signal], handler)
    end
    function w:emit(signal, ...)
        local handlers = self._private[signal] or {}
        for _, h in ipairs(handlers) do
            h(w, ...)
        end
    end
    function w:set_bg(c)
        self.bg_set = c
    end
    function w:set_fg(c)
        self.fg_set = c
    end
    function w:get_children_by_id(id)
        return self._children_by_id[id]
    end
    function w:set_widget(w2)
        self._current_widget = w2
    end
    function w:set_markup(m)
        self._markup = m
    end
    return w
end

-- Mock wibox. The production code uses BOTH `wibox.widget({...})` (callable
-- constructor) AND `wibox.widget.textbox` / `wibox.container.background`
-- (widget classes). The real wibox uses a metatable so `wibox.widget{}`
-- creates a generic widget and `wibox.widget.textbox` is a class.
-- We provide a single callable stub here.
local wibox_widget_call_count = 0
local mock_wibox_widget_constructor = function(args)
    wibox_widget_call_count = wibox_widget_call_count + 1
    local w = make_widget_stub()
    if args then
        w._initial = args
        w._bg = args.bg
        w._fg = args.fg
        w._border_width = args.border_width
        w._border_color = args.border_color
        -- Recursive widget-tree walk that follows the `widget` field
        -- and registers every widget with an `id`. The real wibox
        -- does this lazily on `get_children_by_id`; we do it eagerly
        -- at construction time.
        local function register(t)
            if type(t) ~= "table" then
                return
            end
            -- Register this table if it has an id
            if t.id and not w._children_by_id[t.id] then
                -- Specialize: if t.widget is a function (a class), call
                -- it so the registered entry is the actual widget
                -- instance (which has the methods like set_markup).
                if type(t.widget) == "function" then
                    local instance = t.widget(t)
                    if type(instance) == "table" then
                        w._children_by_id[t.id] = { instance }
                    end
                else
                    w._children_by_id[t.id] = { t }
                end
            end
            -- Recurse into integer-indexed children
            if #t > 0 then
                for i = 1, #t do
                    register(t[i])
                end
            end
            -- Recurse into named children (content_widget etc.)
            for k, v in pairs(t) do
                if type(v) == "table" and k ~= "id" and k ~= "widget" then
                    register(v)
                end
            end
        end
        register(args)
    end
    table.insert(created_widgets, w)
    return w
end

-- Make wibox.widget a callable that also exposes .textbox and .container
-- The wibox.widget.textbox call is intercepted and the returned widget
-- has the source-table fields (id, font, align, markup) attached. The
-- outer container's `walk` also registers any returned widgets so
-- `get_children_by_id` works on the outer button.
local mock_wibox_widget = setmetatable({
    textbox = function(args)
        local w = make_widget_stub()
        if args then
            for k, v in pairs(args) do
                w[k] = v
            end
        end
        -- The real textbox widget has these methods
        w.set_markup = function(self, m)
            self._markup = m
        end
        w.set_image = function(self, img)
            self._image = img
        end
        return w
    end,
}, {
    __call = function(_, args)
        return mock_wibox_widget_constructor(args)
    end,
})

local mock_wibox = {
    widget = mock_wibox_widget,
    container = {
        background = function(args)
            local w = make_widget_stub()
            if args then
                w._initial = args
                w._bg = args.bg
                w._fg = args.fg
                w._border_width = args.border_width
                w._border_color = args.border_color
                if args[1] then
                    w._child_widget = args[1]
                end
            end
            table.insert(created_widgets, w)
            return w
        end,
        margin = function(args)
            local w = make_widget_stub()
            return w
        end,
    },
}

package.loaded["wibox"] = mock_wibox
package.loaded["gears.color"] = {
    recolor_image = function(path, color)
        return path .. "@" .. color
    end,
}
package.loaded["gears.table"] = {
    crush = function(t, m, raw)
        for k, v in pairs(m) do
            t[k] = v
        end
        return t
    end,
}
package.loaded["beautiful"] = {
    font = "Sans",
    font_h0 = "Sans 10",
    bg_urg = "#3d3d3d",
    bg_gradient_button = "#222",
    bg_gradient_recessed = "#111",
    fg = "#fff",
    fg_alt = "#ccc",
}

-- Reset and load
package.loaded["modules.widgets.hover_button"] = nil
local hover_button = require("modules.widgets.hover_button")

-- ------------------------------------------------------------------
-- Tests
-- ------------------------------------------------------------------

runner.describe("hover_button:set_label", function()
    runner.it("updates the markup of the inner textbox", function()
        local btn = hover_button({ label = "Hello" })
        local label_role = btn:get_children_by_id("label-role")
        assert.truthy(label_role, "label-role widget not found")
        local tb = label_role[1]
        -- The mock's textbox attaches set_markup, so this works
        btn:set_label("World")
        assert.eq(tb._markup, "World")
    end)
end)

runner.describe("hover_button:set_bg_normal", function()
    runner.it("sets _private.bg_normal and calls set_bg", function()
        local btn = hover_button({})
        btn:set_bg_normal("#ff0000")
        assert.eq(btn._private.bg_normal, "#ff0000")
        assert.eq(btn.bg_set, "#ff0000")
    end)

    runner.it("successive calls update _private and call set_bg", function()
        local btn = hover_button({})
        btn:set_bg_normal("#aaaaaa")
        btn:set_bg_normal("#bbbbbb")
        assert.eq(btn._private.bg_normal, "#bbbbbb")
        assert.eq(btn.bg_set, "#bbbbbb")
    end)
end)

runner.describe("hover_button:set_fg_normal", function()
    runner.it("sets _private.fg_normal and calls set_fg", function()
        local btn = hover_button({})
        btn:set_fg_normal("#00ff00")
        assert.eq(btn._private.fg_normal, "#00ff00")
        assert.eq(btn.fg_set, "#00ff00")
    end)
end)

runner.describe("hover_button:set_bg_hover", function()
    runner.it(
        "stores the hover bg in _private but does not apply immediately",
        function()
            local btn = hover_button({})
            -- Reset bg_set so we can detect that no set_bg call happens
            btn.bg_set = nil
            btn:set_bg_hover("#ff5500")
            assert.eq(btn._private.bg_hover, "#ff5500")
            -- No immediate set_bg call expected (the value is only applied
            -- on mouse::enter)
            assert.eq(btn.bg_set, nil)
        end
    )
end)

runner.describe("hover_button:set_fg_hover", function()
    runner.it("stores the hover fg in _private", function()
        local btn = hover_button({})
        btn.fg_set = nil
        btn:set_fg_hover("#ff5500")
        assert.eq(btn._private.fg_hover, "#ff5500")
        assert.eq(btn.fg_set, nil)
    end)
end)

runner.describe("hover_button:construction", function()
    runner.it("uses the args-provided bg_normal when set", function()
        created_widgets = {}
        hover_button({ bg_normal = "#123456" })
        assert.truthy(#created_widgets >= 1)
        local first = created_widgets[1]
        assert.eq(first._bg, "#123456")
    end)

    runner.it("uses the args-provided fg_normal when set", function()
        created_widgets = {}
        hover_button({ fg_normal = "#abcdef" })
        assert.truthy(#created_widgets >= 1)
        local first = created_widgets[1]
        assert.eq(first._fg, "#abcdef")
    end)

    runner.it("stores border_normal and border_hover in _private", function()
        local btn = hover_button({
            border_color = "#ff0000",
            border_hover = "#00ff00",
        })
        assert.eq(btn._private.border_normal, "#ff0000")
        assert.eq(btn._private.border_hover, "#00ff00")
    end)

    runner.it("stores icon_source if provided", function()
        local btn = hover_button({ icon_source = "/path/icon.svg" })
        assert.eq(btn._private.icon_source, "/path/icon.svg")
    end)
end)
