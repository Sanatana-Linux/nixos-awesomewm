-- ui/bar/modules/launcher_button.lua
-- Encapsulates the wibar button for the application launcher.

local awful = require("awful")
local gfs = require("gears.filesystem")
local launcher = require("ui.popups.launcher").get_default()
local styled_button = require("modules.styled_button")

local icon_path = gfs.get_configuration_dir() .. "ui/bar/modules/launcher_button/icons/nix.svg"

-- Creates a button to toggle the application launcher using the SVG icon.
-- @return widget The launcher button widget.
return function()
    return styled_button.create_icon_button({
        icon = icon_path,
        buttons = {
            awful.button({}, 1, function()
                launcher:toggle()
            end),
        },
    })
end
