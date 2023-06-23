---@diagnostic disable: undefined-global
--  _______ __ __   __         __
-- |_     _|__|  |_|  |.-----.|  |--.---.-.----.
--   |   | |  |   _|  ||  -__||  _  |  _  |   _|
--   |___| |__|____|__||_____||_____|___._|__|

-- -------------------------------------------------------------------------- --

local function make_button(txt, fg, bg, hfg, hbg, onclick)
    return function(c)
        local btn = wibox.widget({
            {
                {
                    nil,
                    {
                        markup = txt,
                        font = beautiful.nerd_font .. " 14",
                        widget = wibox.widget.textbox,
                    },
                    nil,
                    layout = wibox.layout.align.horizontal,
                    halign = "center",
                    valign = "center",
                    align = "center",
                    expand = "inside",
                },
                left = dpi(2),
                right = dpi(2),
                top = dpi(2),
                bottom = dpi(2),
                widget = wibox.container.margin,
            },
            shape = utilities.widgets.mkroundedrect(2),
            fg = beautiful[fg],
            bg = beautiful[bg],
            widget = wibox.container.background,
        })

        local fg_transition = utilities.visual.apply_transition({
            element = btn,
            prop = "fg",
            bg = beautiful[fg],
            hbg = beautiful[hfg],
        })

        local bg_transition = utilities.visual.apply_transition({
            element = btn,
            prop = "bg",
            bg = beautiful[bg],
            hbg = beautiful[hbg],
        })

        btn:connect_signal("mouse::enter", function()
            fg_transition.on()
            bg_transition.on()
        end)

        btn:connect_signal("mouse::leave", function()
            fg_transition.off()
            bg_transition.off()
        end)

        btn:add_button(awful.button({}, 1, function()
            if onclick then
                onclick(c)
            end
        end))

        return btn
    end
end

local close_button = make_button(
    "",
    "grey",
    "grey",
    "black",
    "red",
    function(c)
        c:kill()
    end
)

local maximize_button = make_button(
    "",
    "grey",
    "grey",
    "black",
    "lessgrey",
    function(c)
        c.maximized = not c.maximized
    end
)

local minimize_button = make_button(
    "",
    "grey",
    "grey",
    "black",
    "lessgrey",
    function(c)
        gears.timer.delayed_call(function()
            c.minimized = true
        end)
    end
)

client.connect_signal("request::titlebars", function(c)
    if c.requests_no_titlebar then
        return
    end

    local titlebar = awful.titlebar(c, { position = "top", size = dpi(25) })

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
                font = beautiful.font_name .. "  10",
            },
            widget = wibox.container.margin,
            left = dpi(16),
            right = dpi(2),
        },

        {

            {
                {
                    minimize_button(c),
                    widget = wibox.container.margin,
                    left = dpi(4),
                    right = dpi(4),
                },
                {
                    maximize_button(c),
                    widget = wibox.container.margin,
                    left = dpi(4),
                    right = dpi(4),
                },
                {
                    close_button(c),
                    widget = wibox.container.margin,
                    left = dpi(4),
                    right = dpi(4),
                },
                layout = wibox.layout.fixed.horizontal,
            },
            right = dpi(10),
            top = dpi(6),
            bottom = dpi(6),
            widget = wibox.container.margin,
        },

        layout = wibox.layout.align.horizontal,
    })
end)
