local function do_notify()
    local confirm = naughty.action({ name = "Confirm" })
    local cancel = naughty.action({ name = "Cancel" })
    -- -------------------------------------------------------------------------- --
    -- copy to clipboard button
    confirm:connect_signal("invoked", function()
        awful.spawn("doas systemctl reboot")
    end)
    -- -------------------------------------------------------------------------- --
    -- delete
    cancel:connect_signal("invoked", function()
        return
    end)
    -- -------------------------------------------------------------------------- --
    -- Show the notification.
    naughty.notify({
        app_name = "Confirmation",
        app_icon = icons.power,
        icon = icons.restart,
        title = "Please Confirm You Want to Reboot",
        text = "Please Confirm You Would Like to Reboot by Pressing Confirm Below",
        actions = { confirm, cancel },
    })
end

Restart = utilities.widgets.mkbtn({
    {
        {
            widget = wibox.widget.imagebox,
            image = icons.restart,
            resize = true,
            opacity = 1,
        },
        left = dpi(5),
        right = dpi(5),
        top = dpi(5),
        bottom = dpi(5),
        widget = wibox.container.margin,
    },
    shape = utilities.widgets.mkroundedrect(),
    widget = wibox.container.background,
    forced_height = dpi(48),
    forced_width = dpi(48),
}, beautiful.widget_back, beautiful.widget_back_focus)
Restart:connect_signal("button::press", function()
    do_notify()
end)
return Restart
