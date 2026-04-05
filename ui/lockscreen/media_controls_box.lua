local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi

-- Simplified media controls box for lockscreen
-- Returns an empty, invisible widget for now to avoid missing dependencies

local media_controls_box = wibox.widget {
    visible = false,
    forced_width = dpi(1),
    forced_height = dpi(1),
    widget = wibox.widget.base.empty_widget()
}

return media_controls_box
