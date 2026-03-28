-- ui/bar/modules/control_panel_button.lua

local awful = require("awful")
local beautiful = require("beautiful")
local modules = require("modules")
local button_styles = require("modules.button_styles")
local control_panel = require("ui.popups.control_panel").get_default()
local dpi = beautiful.xresources.apply_dpi

local icon_path = beautiful.theme_path .. "/icons/settings.svg"

return function()
    return modules.hover_button(button_styles.icon_button({
        icon = icon_path,
        size = dpi(22),
        buttons = {
            awful.button({}, 1, function()
                control_panel:toggle()
            end),
        },
    }))
end
