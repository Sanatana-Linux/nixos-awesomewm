local wibox = require("wibox")
local helpers = require("helpers")
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")
local Gdk = lgi.require("Gdk", "3.0")
local GdkPixbuf = lgi.GdkPixbuf
local dpi = beautiful.xresources.apply_dpi
local naughty = require("naughty")

local delay = tostring(3) .. " "

local clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)

local getName = function()
    local string = "~/Pictures/" .. os.date("%d-%m-%Y-%H:%M:%S") .. ".png"
    ---@diagnostic disable-next-line: param-type-mismatch
    string = string:gsub("~", os.getenv("HOME")) -- $HOME will never return nil, please
    return string
end

local defCommand = "maim " .. "-d " .. delay

local copyScrot = function(path)
    local image = GdkPixbuf.Pixbuf.new_from_file(path)
    clipboard:set_image(image)
    clipboard:store()
end

local createButton = function(icon, name, fn, col)
    return helpers.mkbtn(
        {
            {
                {
                    {
                        {
                            font = beautiful.icon .. " 38",
                            markup = helpers.colorizeText(icon, col),
                            valign = "center",
                            align = "center",
                            widget = wibox.widget.textbox,
                        },
                        widget = wibox.container.margin,
                        margins = dpi(16),
                    },
                    shape = helpers.rrect(10),
                    forced_width = dpi(72),
                    forced_height = dpi(72),
                    widget = wibox.container.background,
                },
                {
                    font = beautiful.font .. " 10",

                    markup = helpers.colorizeText(name, beautiful.fg),
                    valign = "center",
                    align = "center",
                    widget = wibox.widget.textbox,
                },
                spacing = dpi(4),
                layout = wibox.layout.fixed.vertical,
            },
            layout = wibox.layout.fixed.vertical,
            buttons = awful.button({}, 1, function()
                fn()
            end),
        },
        beautiful.bg_gradient_button,
        beautiful.bg_gradient_button1,
        dpi(8),
        dpi(108),
        dpi(108)
    )
end

awful.screen.connect_for_each_screen(function(s)
    local screenshot_popup = wibox({
        width = dpi(420),
        height = dpi(200),
        shape = helpers.rrect(),
        bg = beautiful.mbg .. "cc",
        border_width = dpi(2),
        border_color = beautiful.fg3 .. "66",
        ontop = true,
        visible = false,
    })

    local close = function()
        screenshot_popup.visible = not screenshot_popup.visible
    end

    local fullscreen = createButton("󰍹", "Fullscreen", function()
        close()
        local name = getName()
        local cmd = defCommand .. name
        awful.spawn.easy_async_with_shell(cmd, function()
            copyScrot(name)
        end)
        naughty.notify({
            title = "Screenshot Saved",
            text = "Your screenshot was saved as " .. name,
            timeout = 6,
        })
    end, beautiful.green)

    helpers.addHover(
        fullscreen,
        beautiful.bg_gradient_button,
        beautiful.bg_gradient_button_alt
    )
    local selection = createButton("󰩭", "Selection", function()
        close()
        local name = getName()
        local cmd = "maim" .. " -s " .. name
        awful.spawn.easy_async_with_shell(cmd, function()
            copyScrot(name)
        end)

        naughty.notify({
            title = "Screenshot Saved",
            text = "Your screenshot was saved as " .. name,
            timeout = 6,
        })
    end, beautiful.blue)

    helpers.addHover(
        selection,
        beautiful.bg_gradient,
        beautiful.bg_gradient_alt
    )

    local window = createButton("󰘔", "Window", function()
        close()
        local name = getName()
        local cmd = "maim"
            .. " --window $(xdotool getactivewindow) "
            .. " "
            .. name
        awful.spawn.with_shell(cmd)
        awful.spawn.easy_async_with_shell(cmd, function()
            copyScrot(name)
        end)
        naughty.notify({
            title = "Screenshot Saved",
            text = "Your screenshot was saved as " .. name,
            timeout = 6,
        })
    end, beautiful.red)

    helpers.addHover(window, beautiful.bg_gradient, beautiful.bg_gradient_alt)

    local close_button = wibox.widget({

        {
            {
                {
                    font = beautiful.icon .. " 12",
                    markup = helpers.colorizeText("󰅖", beautiful.fg),
                    valign = "center",
                    align = "center",
                    widget = wibox.widget.textbox,
                    buttons = {
                        awful.button({}, 1, function()
                            close()
                        end),
                    },
                },
                widget = wibox.container.margin,
                margins = dpi(1),
            },
            widget = wibox.container.background,
            bg = beautiful.bg_gradient_button,
            border_width = dpi(1),
            border_color = beautiful.fg3,
            forced_width = dpi(28),
            forced_height = dpi(28),
            shape = helpers.rrect(6),
        },
        widget = wibox.container.margin,
        margins = dpi(1),
        border_color = beautiful.bg,
        border_width = dpi(1),
    })
    helpers.add_hover(
        close_button,
        beautiful.bg_gradient_button,
        beautiful.bg_gradient_button_alt
    )

    screenshot_popup:setup({
        {
            {
                {
                    {
                        nil,
                        {
                            font = beautiful.font .. " 14",
                            markup = "Screenshot Menu",
                            valign = "center",
                            align = "center",
                            widget = wibox.widget.textbox,
                        },
                        close_button,
                        widget = wibox.layout.align.horizontal,
                    },
                    widget = wibox.container.margin,
                    margins = 10,
                },
                widget = wibox.container.background,
            },
            {
                {
                    fullscreen,
                    selection,
                    window,
                    spacing = dpi(25),
                    layout = wibox.layout.fixed.horizontal,
                },
                widget = wibox.container.place,
                halign = "center",
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.vertical,
        },
        widget = wibox.container.margin,
        margins = dpi(10),
    })

    awesome.connect_signal("toggle::screenshot_popup", function()
        screenshot_popup.visible = not screenshot_popup.visible
        awful.placement.centered(screenshot_popup)
    end)
end)
