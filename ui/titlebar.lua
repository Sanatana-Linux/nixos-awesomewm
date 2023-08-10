---@diagnostic disable: undefined-global
--  _______ __ __   __         __
-- |_     _|__|  |_|  |.-----.|  |--.---.-.----.
--   |   | |  |   _|  ||  -__||  _  |  _  |   _|
--   |___| |__|____|__||_____||_____|___._|__|

-- -------------------------------------------------------------------------- --

local function make_button(txt, onclick)
    return function(c)
        local btn = wibox.widget({
            {
                {
                    {
                        image = gears.color.recolor_image(
                            txt,
                            beautiful.fg_normal
                        ),
                        resize = true,
                        align = "center",
                        valign = "center",
                        widget = wibox.widget.imagebox,
                    },
                    left = dpi(3),
                    right = dpi(3),
                    top = dpi(3),
                    bottom = dpi(3),
                    widget = wibox.container.margin,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            shape = utilities.widgets.mkroundedrect(2),
            bg = beautiful.widget_back,
            widget = wibox.container.background,
        })

        btn:connect_signal("mouse::enter", function()
            btn.bg =
                beautiful.widget_back_focus,
                btn:emit_signal("widget::redraw_needed")
        end)

        btn:connect_signal("mouse::leave", function()
            btn.bg =
                beautiful.widget_back, btn:emit_signal("widget::redraw_needed")
        end)

        btn:add_button(awful.button({}, 1, function()
            if onclick then
                onclick(c)
            end
        end))

        return btn
    end
end

local close_button = make_button(icons.close, function(c)
    c:kill()
end)

local maximize_button = make_button(icons.maximize, function(c)
    c.maximized = not c.maximized
end)

local minimize_button = make_button(icons.minus, function(c)
    gears.timer.delayed_call(function()
        c.minimized = true
    end)
end)

client.connect_signal("request::titlebars", function(c)
    --   if c.requests_no_titlebar then
    --       return
    --   end

    local titlebar = awful.titlebar(c, { position = "top", size = dpi(26) })

    local titlebars_buttons = {
        awful.button({}, 1, function()
            c:activate({ context = "titlebar", action = "mouse_move" })
        end),
        awful.button({}, 3, function()
            c:activate({ context = "titlebar", action = "mouse_resize" })
        end),
    }

    local buttons_loader = {
        layout = wibox.layout.fixed.horizontal,
        buttons = titlebars_buttons,
    }

    titlebar:setup({
        buttons_loader,

        {
            {
                widget = awful.titlebar.widget.titlewidget(c),
                font = beautiful.title_font .. "  10",
            },
            widget = wibox.container.margin,
            left = dpi(16),
            right = dpi(2),
        },

        {

            {
                minimize_button(c),
                maximize_button(c),
                close_button(c),
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(6),
            },
            right = dpi(10),
            top = dpi(4),
            bottom = dpi(4),
            widget = wibox.container.margin,
        },

        layout = wibox.layout.align.horizontal,
    })
end)
