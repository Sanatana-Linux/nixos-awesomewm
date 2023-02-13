---@diagnostic disable: undefined-global


local menu = {}

menu.awesome = {
   { "Edit Config", editor_cmd .. " " .. awesome.conffile },
   { "Edit Config (GUI)", visual_editor .. " " .. awesome.conffile },
   { "Restart", awesome.restart },
   { "Close Session", function () awesome.quit() end }
}

menu.mainmenu = awful.menu {
   items = {
    { "  Terminal", terminal },
    { "  Explorer", filemanager },
    { "  Browser", browser },
    { "  Editor", editor_cmd },
    { "  GUI Editor", visual_editor },
    { "  AwesomeWM", menu.awesome },
   }
}


menu.mainmenu.wibox.shape = utilities.mkroundedrect()
menu.mainmenu.wibox.bg = beautiful.bg_normal .. '00'
menu.mainmenu.wibox:set_widget(wibox.widget({
    menu.mainmenu.wibox.widget,
    bg = beautiful.bg_normal,
    shape = utilities.mkroundedrect(),
    widget = wibox.container.background,
}))


awful.menu.original_new = awful.menu.new

function awful.menu.new(...)
    local ret = awful.menu.original_new(...)

    ret.wibox.shape = utilities.mkroundedrect()
    ret.wibox.bg = beautiful.bg_normal .. '00'
    ret.wibox:set_widget(wibox.widget {
        ret.wibox.widget,
        widget = wibox.container.background,
        bg = beautiful.bg_normal,
        shape = utilities.mkroundedrect(),
    })

    return ret
end

return menu
