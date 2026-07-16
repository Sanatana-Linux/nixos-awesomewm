--- Wibar layoutbox module.
-- Wraps the inner layoutbox constructor (from widget.lua) with a themed
-- background container, layout-switching click handlers, and hover effects.
-- @module ui.bar.modules.layoutbox_widget

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local layouts_osd = require("ui.popups.on_screen_display.layouts").get_default()
local shapes = require("modules.style.shapes")
local layoutbox_ctor = require("ui.bar.modules.layoutbox_widget.widget")
local color_alpha = require("lib.util").color_alpha

--- Build the layoutbox widget for a screen.
-- @tparam screen s Screen object
-- @treturn widget Themed layoutbox widget
return function(s)
    local layoutbox = layoutbox_ctor(s)

    local widget = wibox.widget({
        widget = wibox.container.background,
        bg = beautiful.bg_gradient_button,
        shape = shapes.rrect(8),
        border_width = dpi(1),
        border_color = color_alpha(beautiful.fg, "00"),
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
            margins = dpi(0),
            layoutbox,
        },
    })

    -- Hover effects
    widget:connect_signal("mouse::enter", function(w)
        w:set_bg(beautiful.bg_gradient_button_alt)
        w:set_border_color(color_alpha(beautiful.fg, "66"))
    end)

    widget:connect_signal("mouse::leave", function(w)
        w:set_bg(beautiful.bg_gradient_button)
        w:set_border_color(color_alpha(beautiful.fg, "00"))
    end)

    return widget
end
