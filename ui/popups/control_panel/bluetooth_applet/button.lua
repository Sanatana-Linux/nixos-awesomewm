local awful = require("awful")
local gcolor = require("gears.color")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local shapes = require("modules.shapes.init")
local dpi = beautiful.xresources.apply_dpi
local adapter = require("service.bluetooth").get_default()

local icons_dir = gfs.get_configuration_dir() .. "ui/popups/control_panel/bluetooth_applet/icons/"
local bluetooth_icon = icons_dir .. "bluetooth.svg"
local arrow_right = icons_dir .. "arrow-right.svg"

local applet_button = require("modules.applet_button")

local function new()
    return applet_button({
        icon = bluetooth_icon,
        description = "Bluetooth",
        active_text = "Enabled",
        inactive_text = "Disabled",
        adapter = adapter,
        powered_signal = "property::powered",
        handler = function()
            adapter:set_powered(not adapter:get_powered())
        end,
        arrow_icon = arrow_right,
    })
end

return setmetatable({
    new = new,
}, {
    __call = new,
})