-- ui/bar/modules/launcher_button.lua
-- Encapsulates the wibar button for the application launcher.

local awful = require("awful")
local gfs = require("gears.filesystem")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local launcher = require("ui.popups.launcher").get_default()
local styled_button = require("modules.styled_button")

local icon_path = gfs.get_configuration_dir() .. "ui/bar/modules/launcher_button/icons/nix.svg"

-- Creates a button to toggle the application launcher using the SVG icon.
-- @return widget The launcher button widget.
return function()
    return styled_button.create_icon_button({
        icon = icon_path,
        icon_size = dpi(22), -- Increased from default dpi(18) to match layout button coverage
        buttons = {
            awful.button({}, 1, function()
                launcher:toggle()
            end),
        },
    })
end
