---@diagnostic disable: undefined-global
--- Window titlebar.
-- Builds a small themed titlebar with close / maximize / minimize buttons
-- for every managed client. Connects to `client.connect_signal("request::titlebars", ...)`.
-- The visual treatment uses the `beautiful.titlebar_*` theme variables plus a
-- 3 SVG icons (close, maximize, minus) recolored on instantiation.
-- @module ui.titlebar

local gfs = require("gears.filesystem")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local awful = require("awful")
local shapes = require("modules.style.shapes")

local client = client

local icons_dir = gfs.get_configuration_dir() .. "ui/titlebar/icons/"
local close_icon = icons_dir .. "close.svg"
local maximize_icon = icons_dir .. "maximize.svg"
local minimize_icon = icons_dir .. "minus.svg"

--- Build a titlebar button with hover effects.
-- Returns a factory function that takes a client and returns a styled button
-- widget with the given icon. Close buttons get a special red-gradient hover.
-- @tparam string icon_path Path to the SVG icon
-- @tparam function onclick Callback receiving the client on click
-- @treturn function Factory: `(client) -> wibox.widget`
-- @local
local function make_button(icon_path, onclick)
    return function(c)
        local icon_widget = wibox.widget.imagebox()
        icon_widget.image = gears.color.recolor_image(icon_path, beautiful.fg)
        icon_widget.resize = true
        icon_widget.align = "center"
        icon_widget.valign = "center"

        local btn = wibox.widget({
            {
                {
                    icon_widget,
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

        -- Check if this is a close button (based on icon path)
        local is_close_button = icon_path:find("close") ~= nil

        btn:connect_signal("mouse::enter", function()
            if is_close_button then
                -- Special red gradient effect for close buttons
                btn.bg = "linear:0,0:0,32:0,"
                    .. beautiful.red
                    .. ":1,"
                    .. "#b61442"
                -- Change icon to white on hover
                icon_widget.image =
                    gears.color.recolor_image(icon_path, beautiful.bg)
            else
                -- Normal hover effect for other buttons
                btn.bg = beautiful.bg_gradient_button_alt
            end
            btn:emit_signal("widget::redraw_needed")
        end)

        btn:connect_signal("mouse::leave", function()
            btn.bg = beautiful.bg_gradient_button
            -- Revert icon color to normal
            icon_widget.image =
                gears.color.recolor_image(icon_path, beautiful.fg)
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

local close_button = make_button(close_icon, function(c)
    c:kill()
end)

local maximize_button = make_button(maximize_icon, function(c)
    c.maximized = not c.maximized
end)

local minimize_button = make_button(minimize_icon, function(c)
    gears.timer.delayed_call(function()
        c.minimized = true
    end)
end)

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

    --- Update the titlebar background based on client focus state.
    -- @local
    local function update_background()
        if c.focused then
            titlebar.widget.bg = beautiful.bg .. "22"
        else
            titlebar.widget.bg = beautiful.bg_alt .. "22"
        end
    end

    -- Connect signals to update the background on focus change
    c:connect_signal("focus", update_background)
    c:connect_signal("unfocus", update_background)
    -- Also set the initial background color correctly
    update_background()
end)
