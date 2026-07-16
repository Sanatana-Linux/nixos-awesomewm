--- Networking applet toggle button widget.
-- A toggle button for the control panel that enables/disables WiFi with
-- a single click, with an arrow to reveal the full network management page.
-- @module ui.popups.control_panel.networking_applet.button

local gfs = require("gears.filesystem")
local applet_button = require("modules.widgets.applet_button")
local nm_client = require("service.network").get_default()

local ICONS_DIR = gfs.get_configuration_dir()
    .. "ui/popups/control_panel/networking_applet/icons/"
local WIFI_ICON = ICONS_DIR .. "wifi.svg"
local ARROW_ICON = ICONS_DIR .. "arrow-right.svg"

--- Construct a new network applet toggle button.
-- Wraps `modules.applet_button` with WiFi-specific state (wireless-enabled
-- property from the network service).
-- @treturn widget The applet toggle button
-- @local
local function new()
    return applet_button({
        icon = WIFI_ICON,
        arrow_icon = ARROW_ICON,
        name = "Network",
        active_text = "Enabled",
        inactive_text = "Disabled",
        service = nm_client,
        state_property = "property::wireless-enabled",
        get_state_func = function(s)
            return s:get_wireless_enabled()
        end,
        on_toggle = function()
            nm_client:set_wireless_enabled(not nm_client:get_wireless_enabled())
        end,
    })
end

return setmetatable({ new = new }, {
    __call = function(_, ...)
        return new(...)
    end,
})
