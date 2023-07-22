--  _______                         __     __
-- |     __|.-----.---.-.----.----.|  |--.|__|.-----.-----.
-- |__     ||  -__|  _  |   _|  __||     ||  ||     |  _  |
-- |_______||_____|___._|__| |____||__|__||__||__|__|___  |
--                                                  |_____|
-- ------------------------------------------------- --
local box = {}

local signalIcon = wibox.widget({
    layout = wibox.layout.align.vertical,
    expand = "none",
    nil,
    {
        id = "icon",
        image = icons.wifi_3,
        resize = true,
        widget = wibox.widget.imagebox,
    },
    nil,
})

local wifiIcon = wibox.widget({
    {
        {
            signalIcon,
            margins = dpi(7),
            widget = wibox.container.margin,
        },
        shape = utilities.widgets.mkroundedrect(),
        bg = beautiful.widget_back,
        widget = wibox.container.background,
    },
    forced_width = dpi(48),
    forced_height = dpi(48),
    shape = utilities.widgets.mkroundedrect(),
    border_width = dpi(2),
    border_color = beautiful.grey .. "cc",
})

local content = wibox.widget({
    {
        {
            {
                text = "Searching...",
                font = beautiful.font .. " Bold  14",
                widget = wibox.widget.textbox,
            },
            layout = wibox.layout.align.vertical,
        },
        margins = dpi(10),
        widget = wibox.container.margin,
    },
    shape = utilities.widgets.mkroundedrect(),
    bg = beautiful.bg_normal,
    widget = wibox.container.background,
})

box = wibox.widget({
    {
        wifiIcon,
        content,
        -- buttons,
        layout = wibox.layout.align.horizontal,
    },
    shape = utilities.widgets.mkroundedrect(),
    fg = beautiful.white,
    border_width = dpi(2),
    border_color = beautiful.grey .. "cc",
    widget = wibox.container.background,
})

return box
