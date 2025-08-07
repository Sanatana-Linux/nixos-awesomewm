---@diagnostic disable: undefined-global
local gfs = require("gears.filesystem")
local gears = require("gears")
local theme_path = gfs.get_configuration_dir() .. "/theme/"
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local awful = require("awful")
local shapes = require('modules.shapes')

local client = client

local function make_button(txt, onclick)
    return function(c)
        local btn = wibox.widget({
            {
                {
                    {
                        image = gears.color.recolor_image(txt, beautiful.fg),
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
            shape = shapes.rrect(2),
            border_width = dpi(1),
            border_color = beautiful.fg_alt .. "aa",
            bg = beautiful.bg_gradient_button,
            widget = wibox.container.background,
        })

        btn:connect_signal("mouse::enter", function()
            btn.bg =
                beautiful.bg_gradient_button_alt,
                ---@diagnostic disable-next-line: redundant-value
                btn:emit_signal("widget::redraw_needed")
        end)

        btn:connect_signal("mouse::leave", function()
            btn.bg =
                beautiful.bg_gradient_button,
                ---@diagnostic disable-next-line: redundant-value
                btn:emit_signal("widget::redraw_needed")
        end)

        btn:add_button(awful.button({}, 1, function()
            if onclick then
                onclick(c)
            end
        end))

        return btn
    end
end

local close_button = make_button(beautiful.titlebar_icons.close, function(c)
    c:kill()
end)

local maximize_button = make_button(
    beautiful.titlebar_icons.maximize,
    function(c)
        c.maximized = not c.maximized
    end
)

local minimize_button = make_button(
    beautiful.titlebar_icons.minimize,
    function(c)
        gears.timer.delayed_call(function()
            c.minimized = true
        end)
    end
)

client.connect_signal("request::titlebars", function(c)
    -- Create the titlebar with a transparent background initially,
    -- as we will manage the background color dynamically.
    local titlebar = awful.titlebar(c, {
        position = "top",
        size = dpi(35),
        bg = "#00000000",
    })

    local titlebars_buttons = {
        awful.button({}, 1, function()
            c:activate({ context = "titlebar", action = "mouse_move" })
        end),
        awful.button({}, 3, function()
            c:activate({ context = "titlebar", action = "mouse_resize" })
        end),
    }

    -- Define the main widget for the titlebar layout
    local titlebar_widget = {
        {
            { -- Left
                {
                    {
                        {

                            wibox.widget.base.make_widget(
                                awful.titlebar.widget.iconwidget(c)
                            ),
                            buttons = titlebars_buttons,
                            layout = wibox.layout.fixed.horizontal,
                            clip_shape = shapes.rrect_6,
                        },
                        widget = wibox.container.margin,
                        right = dpi(2),
                        left = dpi(2),
                        top = dpi(2),
                        bottom = dpi(2),
                    },
                    widget = wibox.container.background,
                    bg = beautiful.bg .. "00",
                    shape = shapes.rrect_6,
                },
                widget = wibox.container.margin,
                right = dpi(2),
                left = dpi(12),
                top = dpi(2),
                bottom = dpi(2),
            },
            { -- Title
                wibox.widget.base.make_widget(
                    awful.titlebar.widget.titlewidget(c)
                ),
                buttons = titlebars_buttons,
                widget = wibox.container.place,
            },
            { -- Right
                {
                    {
                        {
                            minimize_button(c),
                            maximize_button(c),
                            close_button(c),
                            layout = wibox.layout.fixed.horizontal,
                            spacing = dpi(8),
                        },
                        widget = wibox.container.margin,
                        top = dpi(6),
                        bottom = dpi(6),
                        left = dpi(10),
                        right = dpi(10),
                    },
                    widget = wibox.container.background,
                    bg = beautiful.bg .. "00",
                    shape = shapes.rrect_6,
                },
                widget = wibox.container.margin,
                left = dpi(6),
                right = dpi(8),
                top = dpi(2),
                bottom = dpi(2),
            },
            layout = wibox.layout.align.horizontal,
        },
        widget = wibox.container.background,
        -- The 'bg' property will be set dynamically below
    }

    -- Set the titlebar's layout
    titlebar:setup(titlebar_widget)

    -- Function to update the background based on focus state
    local function update_background()
        if c.focused then
            titlebar.widget.bg = beautiful.bg_gradient_titlebar
        else
            -- Use a different background when the window is not focused
            titlebar.widget.bg = beautiful.bg_titlebar_alt or beautiful.bg_alt
        end
    end

    -- Connect signals to update the background on focus change
    c:connect_signal("focus", update_background)
    c:connect_signal("unfocus", update_background)
    -- Also set the initial background color correctly
    update_background()
end)
