-- helpers/mkbtn.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

return function(template, bg, hbg, radius, w, h)
    local button = wibox.widget({
        {
            template,
            margins = dpi(5),
            widget = wibox.container.margin,
        },
        bg = bg,
        forced_width = w,
        forced_height = h,
        widget = wibox.container.background,
        shape = helpers.rrect(radius),
        border_width = dpi(1),
        border_color = beautiful.fg .. "66",
    })
    if bg and hbg then
        helpers.add_hover(button, bg, hbg)
    end

    return button
end
