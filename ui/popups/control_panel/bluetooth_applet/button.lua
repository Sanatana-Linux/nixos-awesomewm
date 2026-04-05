--[[
Bluetooth Applet Button Widget

Creates a toggle button for the control panel that allows users to:
- Enable/disable Bluetooth adapter with a single click
- Reveal the full Bluetooth management page via the arrow button
--]]

local gfs = require("gears.filesystem")
local applet_button = require("modules.applet_button")
local adapter = require("service.bluetooth").get_default()

------------------------------------------------------------------------
-- Configuration
------------------------------------------------------------------------

local ICONS_DIR = gfs.get_configuration_dir()
    .. "ui/popups/control_panel/bluetooth_applet/icons/"
local BLUETOOTH_ICON = ICONS_DIR .. "bluetooth.svg"
local ARROW_ICON = ICONS_DIR .. "arrow-right.svg"

------------------------------------------------------------------------
-- Widget Factory
------------------------------------------------------------------------

local function new()
    return applet_button({
        icon = BLUETOOTH_ICON,
        arrow_icon = ARROW_ICON,
        name = "Bluetooth",
        active_text = "Enabled",
        inactive_text = "Disabled",
        service = adapter,
        state_property = "property::powered",
        get_state_func = function(s)
            return s:get_powered()
        end,
        on_toggle = function()
            adapter:set_powered(not adapter:get_powered())
        end,
    })
end

return setmetatable({ new = new }, {
    __call = function(_, ...)
        return new(...)
    end,
})
