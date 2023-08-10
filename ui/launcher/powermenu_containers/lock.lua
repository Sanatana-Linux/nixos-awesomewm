--      _____               __
--     |     |_.-----.----.|  |--.
--     |       |  _  |  __||    <
--     |_______|_____|____||__|__|
--   +---------------------------------------------------------------+
-- confirmation dialog
local function do_notify()
    local confirm = naughty.action({ name = "Confirm" })
    local cancel = naughty.action({ name = "Cancel" })
    --   +---------------------------------------------------------------+
    -- copy to clipboard button
    confirm:connect_signal("invoked", function()
        awful.spawn("dm-tool lock")
    end)
    --   +---------------------------------------------------------------+
    -- delete
    cancel:connect_signal("invoked", function()
        return
    end)
    --   +---------------------------------------------------------------+
    -- Show the notification.
    naughty.notify({
        app_name = "Confirmation",
        app_icon = icons.power,
        icon = icons.lock,
        ontop = true,
        position = "top_middle",
        title = "Please Confirm You Want to Lock the Screen",
        text = "Please Confirm You Would Like to Lock the Screen by Pressing Confirm Below",
        actions = { confirm, cancel },
    })
end
--   +---------------------------------------------------------------+
-- lock button
Lock = utilities.widgets.mkbtn({
    {
        {
            widget = wibox.widget.imagebox,
            image = icons.lock,
            resize = true,
            opacity = 1,
        },
        left = dpi(5),
        right = dpi(5),
        top = dpi(5),
        bottom = dpi(5),
        widget = wibox.container.margin,
    },
    bg = beautiful.widget_bg,
    shape = utilities.widgets.mkroundedrect(),
    widget = wibox.container.background,

    forced_height = dpi(48),
    forced_width = dpi(48),
}, beautiful.widget_back, beautiful.widget_back_focus)
Lock:connect_signal("button::press", function()
    do_notify()
end)

return Lock
