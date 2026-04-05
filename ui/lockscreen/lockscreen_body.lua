local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi
local shapes = require("modules.shapes")

local wordclock = require("ui.lockscreen.wordclock")
local lock_animation = require("ui.lockscreen.lock_animation")

return wibox.widget {
    {
        {
            {
                wordclock,
                lock_animation,
                spacing = dpi(32),
                layout = wibox.layout.fixed.vertical
            },
            margins = dpi(52),
            widget = wibox.container.margin
        },
        id = "container",
        shape = shapes.rrect(beautiful.border_radius),
        bg = beautiful.bg,
        border_color = beautiful.focus,
        border_width = dpi(2),
        widget = wibox.container.background
    },
    widget = wibox.container.place
}
