local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi
local mkroundedrect = require("utilities.widgets.mkroundedcontainer")
local mkroundedcontainer = require("utilities.widgets.mkroundedcontainer")

return function(text, placement)
    local ret = {}

    ret.widget = wibox.widget({
        {
            {
                id = "image",
                image = icons.hints,
                forced_height = dpi(12),
                forced_width = dpi(12),
                halign = "center",
                valign = "center",
                widget = wibox.widget.imagebox,
            },
            {
                id = "text",
                markup = text or "",
                align = "center",
                widget = wibox.widget.textbox,
            },
            spacing = dpi(7),
            layout = wibox.layout.fixed.horizontal,
        },
        margins = dpi(12),
        widget = wibox.container.margin,
        set_text = function(self, t)
            self:get_children_by_id("text")[1].markup = t
        end,
        set_image = function(self, i)
            self:get_children_by_id("image")[1].image = i
        end,
    })

    ret.popup = awful.popup({
        visible = false,
        bg = beautiful.bg_normal .. "00",
        fg = beautiful.fg_normal,
        ontop = true,
        placement = placement or awful.placement.centered,
        screen = awful.screen.focused(),
        widget = mkroundedcontainer(ret.widget, beautiful.bg_normal),
    })

    local self = ret.popup

    function ret.show()
        self.screen = awful.screen.focused()
        self.visible = true
    end

    function ret.hide()
        self.visible = false
    end

    function ret.toggle()
        if not self.visible and self.screen ~= awful.screen.focused() then
            self.screen = awful.screen.focused()
        end
        self.visible = not self.visible
    end

    function ret.attach_to_object(object)
        object:connect_signal("mouse::enter", ret.show)
        object:connect_signal("mouse::leave", ret.hide)
    end

    return ret
end
