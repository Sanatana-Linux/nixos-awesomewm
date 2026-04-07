-- ui/bar/modules/control_panel_button.lua

local awful = require("awful")
local gfs = require("gears.filesystem")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local styled_button = require("modules.styled_button")

local icon_path = gfs.get_configuration_dir()
    .. "ui/bar/modules/control_panel_button/icons/settings.svg"

return function()
    local control_panel = require("ui.popups.control_panel").get_default()
    
    return styled_button.create_icon_button({
        icon = icon_path,
        icon_size = dpi(22), -- Increased from default dpi(18) to match layout button coverage
        buttons = {
            awful.button({}, 1, function()
                control_panel:toggle()
            end),
        },
    })
end
