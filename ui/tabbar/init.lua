-- NOTE: Thanks again bling
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local awful = require("awful")
local size = dpi(28) -- Set the size
local position = "top" -- Set the position to default to "top" if not s

--------------------------------------------------------------------> signal ;

--|switching or loginspecified

-- Create the tabbar widget for a given client
-- NOTE: the tabbar is essentially just a second titlebar and thus is arranged the same way ultimately.
local function create(c, focused_bool, buttons)
    local bg_normal = beautiful.bg_gradient_titlebar
    local bg_focus = beautiful.bg_gradient_titlebar_alt
    local bg_temp = focused_bool and bg_focus or bg_normal
    local fg_temp = focused_bool and beautiful.fg or beautiful.fg
    -- Create the tabbar widget
    local wid_temp = wibox.widget({
        {
            { -- Left: Icon
                wibox.widget.base.make_widget(
                    awful.titlebar.widget.iconwidget(c)
                ),
                buttons = buttons,
                layout = wibox.layout.fixed.horizontal,
            },
            { -- Title
                wibox.widget.base.make_widget(
                    awful.titlebar.widget.titlewidget(c)
                ),
                buttons = buttons,
                widget = wibox.container.place,
            },
            nil, -- Right: No buttons needed
            layout = wibox.layout.align.horizontal,
        },
        bg = bg_temp,
        fg = fg_temp,
        widget = wibox.container.background,
    })

    return wid_temp -- Return the created tabbar widget
end

-- Return the configuration table
return {
    layout = wibox.layout.flex.horizontal, -- Set the layout to flex horizontal
    create = create, -- Set the create function
    position = position, -- Set the position
    size = size, -- Set the size
    bg_normal = beautiful.bg_gradient_titlebar, -- Set the normal background color
    bg_focus = beautiful.bg_gradient_titlebar_alt, -- Set the focused background color
}
