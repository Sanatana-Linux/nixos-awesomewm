--               __                        __
-- .-----.-----.|  |_.--.--.--.-----.----.|  |--.
-- |     |  -__||   _|  |  |  |  _  |   _||    <
-- |__|__|_____||____|________|_____|__|  |__|__|
--  __           __   __
-- |  |--.--.--.|  |_|  |_.-----.-----.
-- |  _  |  |  ||   _|   _|  _  |     |
-- |_____|_____||____|____|_____|__|__|
-- ------------------------------------------------- --
 require("ui.notifications.notification_center")
local icon =
    wibox.widget {
    id = 'icon',
    image = icons.notifications,
    widget = wibox.widget.imagebox,
    valign = 'center',
    align = 'center',
    forced_width = dpi(84),
    forced_height = dpi(84)
}
-- ------------------------------------------------- --

local notifications_button =
    wibox.widget {
    {
        {
            icon,
            top = dpi(14),
            bottom = dpi(14),
            left = dpi(24),
            right = dpi(24),
            widget = wibox.container.margin
        },
        layout = wibox.layout.align.vertical,
        spacing = dpi(10)
    },
    shape = utilities.mkroundedrect(),
    widget = wibox.container.background,
    forced_width = dpi(96),
    forced_height = dpi(96)
}
-- ------------------------------------------------- --
notifications_button:buttons(
    gears.table.join(
        awful.button(
            {},
            1,
            function()
                not_toggle()
            end
        )
    )
)
-- ------------------------------------------------- --
return notifications_button
