-- ui/bar/modules/control_panel_button.lua
-- Encapsulates the wibar button for the control panel.

local awful = require("awful")
local beautiful = require("beautiful")
local modules = require("modules")
local wibox = require("wibox")
local control_panel = require("ui.popups.control_panel").get_default()
local dpi = beautiful.xresources.apply_dpi
local shapes = require("modules.shapes.init")

-- Creates a button to toggle the control panel.
-- @return widget The control panel button widget.
return function()
    return modules.hover_button({
        buttons = {
            awful.button({}, 1, function()
                control_panel:toggle()
            end),
        },
        -- Use theme gradients for background
        bg_normal = beautiful.bg_gradient_button,
        bg_hover = beautiful.bg_gradient_button_alt,
        fg_normal = beautiful.fg,
        fg_hover = beautiful.fg,
        shape = shapes.rrect(8),
        -- Pass the normal and hover icon surfaces from the theme
        child_widget = {
            widget = wibox.container.margin,
            margins = dpi(2),
            {
                widget = wibox.widget.imagebox,
                image = beautiful.settings_icon,
                forced_width = dpi(22),
                forced_height = dpi(22),
            },
        },
    })
end
