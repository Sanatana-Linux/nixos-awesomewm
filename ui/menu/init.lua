---@diagnostic disable: undefined-global

local menu = {}

menu.awesome = {
    {
        "Edit Config",
        editor_cmd .. " " .. awesome.conffile,
        icons.text_editor,
    },
    {
        "Edit Config (GUI)",
        visual_editor .. " " .. awesome.conffile,
        icons.text_editor,
    },
    {
        "Restart",
        awesome.restart,
        icons.restart,
    },
    {
        "Close Session",
        function()
            awesome.quit()
        end,
        icons.close,
    },
}

menu.mainmenu = awful.menu({
    items = {
        { "Terminal", terminal, icons.terminal },
        { "Explorer", filemanager, icons.files },
        { "Browser", browser, icons.web_browser },
        { "Editor", editor_cmd, icons.text_editor },
        { "GUI Editor", visual_editor, icons.text },
        { "AwesomeWM", menu.awesome, icons.awesome },
    },
})

menu.mainmenu.wibox.shape = utilities.widgets.mkroundedrect()
-- menu.mainmenu.wibox.bg = beautiful.bg_normal .. "00"
menu.mainmenu.wibox:set_widget(wibox.widget({
    {
        menu.mainmenu.wibox.widget,
        widget = wibox.container.margin,
        margins = dpi(15),
    },
    font = beautiful.nerd_font .. " 12",
    --   bg = beautiful.bg_normal .. "bb",
    shape = utilities.widgets.mkroundedrect(),
    widget = wibox.container.background,
}))

awful.menu.original_new = awful.menu.new

function awful.menu.new(...)
    local ret = awful.menu.original_new(...)

    ret.wibox.shape = utilities.widgets.mkroundedrect()
    ret.wibox:set_widget(wibox.widget({
        {
            ret.wibox.widget,
            widget = wibox.container.margin,
            margins = dpi(15),
        },
        widget = wibox.container.background,
        --  bg = beautiful.bg_normal .. "00",
        shape = utilities.widgets.mkroundedrect(),
    }))
    return ret
end

awful.mouse.append_client_mousebinding(awful.button({}, 1, function()
    menu:hide()
end))

awful.mouse.append_global_mousebinding(awful.button({}, 1, function()
    menu:hide()
end))

awful.mouse.append_client_mousebinding(awful.button({}, 3, function()
    menu:hide()
end))

awful.mouse.append_global_mousebinding(awful.button({}, 3, function()
    menu:hide()
end))

return menu
