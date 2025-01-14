-- helpers/mkbtn.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

local json = require("mods.json")
local wibox = require("wibox")

return function(template, bg, hbg, radius, w, h)
    local button = wibox.widget({

        {
            template,
            margins = dpi(5),
            widget = wibox.container.margin,
            layout = wibox.layout.flex.horizontal,
        },
        bg = bg,
        forced_width = w,
        forced_height = h,
        widget = wibox.container.background,
        shape = require("helpers.rrect")(radius),
        border_width = dpi(1),
        border_color = beautiful.fg .. "66",
    })
    if bg and hbg then
        require("helpers.add_hover")(button, bg, hbg)
        require("helpers.hover_cursor")(button)
    end

    return button
end
