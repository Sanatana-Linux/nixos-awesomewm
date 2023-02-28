local wibox = require "wibox"
local awful = require "awful"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gears = require "gears"

local iconsdir = require("gears.filesystem").get_configuration_dir() .. "theme/assets/icons/svg/"
local lock_cmd ="i3lock-color -c " .. string.sub(beautiful.bg_normal,2,7) .. "60 --greeter-text='enter password' -efk --time-pos='x+w-100:y+h-50'"

local menu

local function create_menu_button (text, symbol, symbol_bg, callback)
    local btn = wibox.widget {
        widget = wibox.container.background,
        shape = utilities.mkroundedrect(),
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(5),
                {
                    widget = wibox.container.background,
                    bg = symbol_bg,
                    forced_width = beautiful.get_font_height(beautiful.font_thin .. " 10") + dpi(5),
                    forced_height = beautiful.get_font_height(beautiful.font_thin .. " 10") + dpi(5),
                    shape = utilities.mkroundedrect(),
                    {
                        widget = wibox.container.margin,
                        margins = dpi(2),
                        {
                            widget = wibox.widget.imagebox,
                            image = symbol
                        }
                    }
                },
                {
                    widget = wibox.widget.textbox,
                    font = beautiful.font_thin .. " 10",
                    text = text
                }
            }
        },
        buttons = awful.button {
            modifiers = {},
            button = 1,
            on_press = function ()
                callback()
            end
        }
    }
    btn:connect_signal("mouse::enter",function ()
        btn.bg = beautiful.bg_focus
    end)
    btn:connect_signal("mouse::leave",function ()
        btn.bg = beautiful.bg_normal
    end)
    utilities.pointer_on_focus(btn)
    return btn
end

--menu needs to be defined above so that the buttons work
menu = awful.popup {
    visible = false,
    ontop = true,
    shape = utilities.mkroundedrect(),
    widget = wibox.widget {
        widget = wibox.container.margin,
        margins = dpi(5),
        {
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(5),
            create_menu_button(
                "poweroff",
                gears.color.recolor_image(iconsdir .. "poweroff.svg", beautiful.bg_normal),
                beautiful.red,
                function ()
                    menu.visible = false
                    awful.spawn("poweroff")
                end
            ),
            create_menu_button(
                "reboot",
                gears.color.recolor_image(iconsdir .. "restart.svg", beautiful.bg_normal),
                beautiful.magenta,
                function ()
                    menu.visible = false
                    awful.spawn("reboot")
                end
            ),
            create_menu_button(
                "lock",
                gears.color.recolor_image(iconsdir .. "lock.svg", beautiful.bg_normal),
                beautiful.yellow,
                function ()
                    menu.visible = false
                    awful.spawn(lock_cmd)
                end
            ),
            create_menu_button(
                "suspend",
                gears.color.recolor_image(iconsdir .. "suspend.svg", beautiful.bg_normal),
                beautiful.blue,
                function ()
                    menu.visible = false
                    awful.spawn.with_shell(lock_cmd .. " && systemctl suspend")
                end
            ),
            create_menu_button(
                "hibernate",
                gears.color.recolor_image(iconsdir .. "hibernate.svg", beautiful.bg_normal),
                beautiful.green,
                function ()
                    menu.visible = false
                    awful.spawn.with_shell("systemctl hibernate")
                end
            ),
            create_menu_button(
                "logout",
                gears.color.recolor_image(iconsdir .. "logout.svg", beautiful.bg_normal),
                beautiful.cyan,
                function ()
                    menu.visible = false
                    awful.spawn("pkill awesome")
                end
            )
        }
    }
}

local menu_opener = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.bg_focus_dark,
    shape = utilities.mkroundedrect(),
    {
        widget = wibox.container.margin,
        margins = dpi(5),
        {
            layout = wibox.layout.fixed.horizontal,
			spacing = dpi(10),
            {
                widget = wibox.container.margin,
                margins = dpi(5),
                {
                    widget = wibox.widget.imagebox,
                    --clip_shape = gears.shape.circle,
                    clip_shape = utilities.mkroundedrect(),
                    image = os.getenv("HOME") .. "/.face"
                }
            },
            {
                widget = wibox.container.place,
                fill_horizontal = true,
                fill_vertical = true,
                halign = 'left',
                {
                    layout = wibox.layout.fixed.vertical,
                    {
                        widget = wibox.container.margin,
                        margins = { left = dpi(5) },
                        {
                            widget = wibox.widget.textbox,
                            font = beautiful.font_bold .. " 13",
                            text = "Hi " .. os.getenv("USER"),
                            valign = 'center'
                        }
                    },
                    {
                        widget = wibox.container.place,
                        fill_horizontal = true,
                        halign = 'left',
                        {
                            widget = wibox.container.background,
                            bg = beautiful.bg_focus_dark,
                            shape = utilities.mkroundedrect(),
                            id = 'bye_bg',
                            {
                                widget = wibox.container.margin,
                                margins = dpi(5),
                                {
                                    widget = wibox.widget.textbox,
                                    text = "bye",
                                }
                            }
                        }
                    }
                    --[[create_menu_button("bye", iconsdir .. "logout.svg", beautiful.fg_normal, function ()
                        local s = awful.screen.focused()
                        awful.placement.next_to(menu,{geometry = s.center, preferred_positions = {"right"}, preferred_anchors = "front"})
                        menu.visible = not menu.visible
                    end)
                    ]]
                }
            }
        }
    }
}

local bye_bg = menu_opener:get_children_by_id('bye_bg')[1]
utilities.pointer_on_focus(bye_bg)
bye_bg:connect_signal("button::press", function (_, _, _, b, _, fwr)
    if b == 1 then
        local s = awful.screen.focused()
        --awful.placement.next_to(menu,{geometry = s.center, preferred_positions = {"right"}, preferred_anchors = "front"})
        menu.x = s.menu.x + fwr.x
        menu.y = s.menu.y + fwr.y + fwr.height
        menu.visible = not menu.visible
    end
end)
bye_bg:connect_signal("mouse::enter", function ()
    bye_bg.bg = beautiful.bg_focus
end)
bye_bg:connect_signal("mouse::leave", function ()
    bye_bg.bg = beautiful.bg_focus_dark
end)

local function hide()
    menu.visible = false
end

return {
    widget = menu_opener,
    hide = hide
}
