-- ui/bar/modules/layoutbox_widget.lua
-- Encapsulates the wibar widget for the layoutbox.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local layouts_osd = require("ui.popups.on_screen_display.layouts").get_default()
local shapes = require("modules.shapes.init")

-- Creates a layout box widget to display and change the current layout.
-- @param s screen The screen object.
-- @return widget The layout box widget.
return function(s)
    local layoutbox = awful.widget.layoutbox({
        screen = s,
        resize = true,
        buttons = {}, -- Remove default buttons as they are on parent
    })
    -- layoutbox.imagebox.forced_width = dpi(28)
    --[[   layoutbox.imagebox.forced_height = dp(28) ]]

    local widget = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_gradient_button,
        shape = shapes.rrect(8),
        buttons = {
            awful.button({}, 1, function()
                awful.layout.inc(1)
                layouts_osd:show()
            end),
            awful.button({}, 3, function()
                awful.layout.inc(-1)
                layouts_osd:show()
            end),
        },
        {
            widget = wibox.container.margin,
            margins = dpi(0), -- Uniform margin
            layoutbox,
        },
    })

    -- Hover effects
    widget:connect_signal("mouse::enter", function(w)
        w:set_bg(beautiful.bg_gradient_button_alt)
    end)

    widget:connect_signal("mouse::leave", function(w)
        w:set_bg(beautiful.bg_gradient_button)
    end)

    return widget
end
