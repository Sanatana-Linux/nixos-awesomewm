local wibox = require 'wibox'
local beautiful = require 'beautiful'
local mkroundedrect = require('utilities.mkroundedcontainer')
local add_hover =require('utilities.add_hover')
local dpi = beautiful.xresources.apply_dpi

return function (template, bg, hbg, radius)
    local button = wibox.widget {
        {
            template,
            margins = dpi(7),
            widget = wibox.container.margin,
        },
        bg = bg,
        widget = wibox.container.background,
        shape = mkroundedrect(radius),
    }

    if bg and hbg then
        add_hover(button, bg, hbg)
    end

    return button
end