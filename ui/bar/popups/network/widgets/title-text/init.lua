--  _______ __ __   __
-- |_     _|__|  |_|  |.-----.
--   |   | |  |   _|  ||  -__|
--   |___| |__|____|__||_____|
--  _______               __
-- |_     _|.-----.--.--.|  |_
--   |   |  |  -__|_   _||   _|
--   |___|  |_____|__.__||____|
-- ------------------------------------------------- --
local user_content =
    wibox.widget {
    text = ' Network Connections',
    font = beautiful.font .. ' 16',
    widget = wibox.widget.textbox
}

------------------------------------ --

local widget =
    wibox.widget {
    {
        user_content,
        layout = wibox.layout.flex.horizontal
    },
    fg = beautiful.fg_normal,
    bg = beautiful.normal,
    widget = wibox.container.background
}
-- ------------------------------------------------- --w
return widget
