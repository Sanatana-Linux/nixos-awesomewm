local awful = require "awful"
local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi

local widget = awful.widget.layoutlist {
    base_layout = wibox.widget {
        forced_num_cols = 4,
        layout          = wibox.layout.grid.vertical,
        expand = true,
        homogeneus = true
    },
    widget_template = {
        widget  = wibox.container.place,
        halign = 'center',
        valign = 'center',
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            {
                widget = wibox.container.background,
                shape = utilities.mkroundedrect(),
                {
                    id = 'background_role',
                    bg = beautiful.bg_focus,
                    widget = wibox.container.background,
                    {
                        widget = wibox.container.margin,
                        margins = dpi(5),
                        {
                            id = 'icon_role',
                            widget = wibox.widget.imagebox,
                        }
                    }
                }
            }
        },
        create_callback = function (self, _, _, _, _)
            utilities.pointer_on_focus(self:get_children_by_id('background_role')[1])
        end,
    }
}

return wibox.widget {
    widget = wibox.container.background,
    shape = utilities.mkroundedrect(),
    bg = beautiful.dimblack,
    {
        widget = wibox.container.place,
        valign = 'center',
        halign = 'center',
        fill_vertical = true,
        fill_horizontal = true,
        {
            widget = wibox.container.margin,
            margins = dpi(5),
            widget
        }
    }
}
