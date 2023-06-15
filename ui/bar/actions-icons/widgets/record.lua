local wibox = require("wibox")

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local dpi = beautiful.xresources.apply_dpi

local getName = function()
    local string = os.getenv("HOME")
        .. "/Videos/Recordings/"
        .. os.date("%d-%m-%Y-%H:%M:%S")
        .. ".mp4"
    return string
end

local start = function(fps, file_name)
    local display = os.getenv("DISPLAY")
    local defCommand = string.format(
        "ffmpeg -y -f x11grab "
            .. '-r "%s" -i %s -f pulse -i 0 -c:v libx264 -qp 0 -profile:v main '
            .. "-preset ultrafast -tune zerolatency -crf 28 -pix_fmt yuv420p "
            .. " -c:a aac -b:a 64k -b:v 500k %s",
        fps,
        display,
        file_name
    )
    print(defCommand)
    awful.spawn.with_shell(defCommand)
end
local createButton = function(icon, name, fn, col)
    local button = wibox.widget({

        {
            {

                {
                    font = beautiful.nerd_font .. " 48",
                    markup = icon,
                    valign = "center",
                    align = "center",
                    widget = wibox.widget.textbox,
                },
                widget = wibox.container.background,
                forced_width = dpi(54),
                forced_height = dpi(54),
            },
            widget = wibox.container.margin,
            margins = 8,
        },

        bg = beautiful.widget_back,
        shape = utilities.widgets.mkroundedrect(),
        widget = wibox.container.background,
        border_color = beautiful.grey,
        border_width = dpi(1),
        buttons = awful.button({}, 1, function()
            fn()
        end),
    })
    utilities.visual.add_hover(
        button,
        beautiful.widget_back,
        beautiful.widget_back_focus_tag
    )

    local tooltip =
        utilities.widgets.make_popup_tooltip(name, awful.placement.centered())
    tooltip.attach_to_object(button)
    return button
end

awful.screen.connect_for_each_screen(function(s)
    local recorder = wibox({
        width = dpi(270),
        height = dpi(180),
        shape = utilities.widgets.mkroundedrect(),
        bg = beautiful.dimblack .. "66",
        border_width = dpi(1),
        border_color = beautiful.grey .. "66",
        ontop = true,
        visible = false,
    })
    local slide = rubato.timed({
        pos = s.geometry.height,
        rate = 60,
        intro = 0.14,
        duration = 0.33,
        subscribed = function(pos)
            recorder.y = (s.geometry.y - beautiful.bar_height) + pos
        end,
    })

    local slide_end = gears.timer({
        single_shot = true,
        timeout = 0.33 + 0.08,
        callback = function()
            recorder.visible = false
        end,
    })
    local close = function()
        slide_end:again()
        slide.target = s.geometry.height
        record_kg:stop()
    end

    local fullscreen = createButton("󰄄", "Start", function()
        close()
        local name = getName()
        start("60", name)
    end)

    local window = createButton("󰜺", "Finish", function()
        close()
        awful.spawn.with_shell("killall ffmpeg")
    end)

    record_kg = awful.keygrabber({
        keybindings = {
            awful.key({
                modifiers = {},
                key = "Escape",
                on_press = function()
                    close()
                    record_kg:stop()
                end,
            }),
            awful.key({
                modifiers = {},
                key = "q",
                on_press = function()
                    close()

                    record_kg:stop()
                end,
            }),
            awful.key({
                modifiers = {},
                key = "x",
                on_press = function()
                    close()
                    record_kg:stop()
                end,
            }),
        },
    })

    recorder:setup({
        {

            {
                fullscreen,
                window,
                spacing = 35,
                layout = wibox.layout.flex.horizontal,
            },
            widget = wibox.container.background,
            maximum_height = dpi(60),
            height= dpi(60)
        },
        widget = wibox.container.margin,
        margins = 13,
    })

    awesome.connect_signal("toggle::recorder", function()
        if recorder.visible then
            slide_end:again()
            slide.target = s.geometry.height
            record_kg:stop()
        elseif not recorder.visible then
            slide.target = s.geometry.height
                - (recorder.height + beautiful.useless_gap * 2)
            recorder.visible = true
            record_kg:start()
        end
        awful.placement.centered(recorder)
    end)
end)
