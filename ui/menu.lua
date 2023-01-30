---@diagnostic disable: undefined-global
local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'


local menu = {}

menu.awesome = {
   { "Edit Config", editor_cmd .. " " .. awesome.conffile },
   { "Edit Config (GUI)", visual_editor .. " " .. awesome.conffile },
   { "Restart", awesome.restart },
   { "Close Session", function () awesome.quit() end }
}

menu.mainmenu = awful.menu {
   items = {
      { "Terminal", terminal },
      { "Explorer", explorer },
      { "Browser", browser },
      { "Editor", editor_cmd },
      { "GUI Editor", visual_editor },
      { "AwesomeWM", menu.awesome },
   }
}


-- apply rounded corners to menus when picom isn't available

menu.mainmenu.wibox.shape = utilities.mkroundedrect(12)
menu.mainmenu.wibox.bg = beautiful.bg_normal
menu.mainmenu.wibox:set_widget(wibox.widget({
    menu.mainmenu.wibox.widget,
    bg = beautiful.bg_normal,
    shape = utilities.mkroundedrect(12),
    widget = wibox.container.background,
}))

-- apply rounded corners to submenus, thanks to u/signalsourcesexy
-- also applies antialiasing! - By me.
awful.menu.original_new = awful.menu.new

function awful.menu.new(...)
    local ret = awful.menu.original_new(...)

    ret.wibox.shape = utilities.mkroundedrect()
    ret.wibox.bg = beautiful.bg_normal 
    ret.wibox:set_widget(wibox.widget {
        ret.wibox.widget,
        widget = wibox.container.background,
        bg = beautiful.bg_normal,
        shape = utilities.mkroundedrect(12),
    })

    return ret
end

return menu
