local wibox = require "wibox"
local dpi = require "beautiful.xresources".apply_dpi
local beautiful = require "beautiful"

local calendar = require "ui.popups.bar.menu.widgets.calendar"
local layouts = require "ui.bar.popups.menu.widgets.layout"
local grindtimer = require "ui.bar.popups.menu.widgets.grinder"

local layout = wibox.widget {
    layout        = wibox.layout.grid,
    homogeneous   = true,
    spacing       = dpi(5),
	horizontal_expand = true,
	vertical_expand = true,
	forced_num_cols = 5,
	forced_num_rows = 3
}

layout:add_widget_at(calendar, 1, 3, 3, 3)
layout:add_widget_at(layouts, 1, 1, 1, 2)
layout:add_widget_at(grindtimer,2,1,2,2)

local function init(s)
	s.menu = wibox {
		height = dpi(300),
		width = dpi(500),
		screen = s,
		ontop = true,
		visible = false,
		x = s.geometry.x + s.geometry.width - 2*beautiful.useless_gap - dpi(500),
		y = s.geometry.y --[[+ s.geometry.height - dpi(400)]] + beautiful.wibar_height + 2*beautiful.useless_gap,
		bg = beautiful.bg_normal,
		widget = wibox.widget {
			widget = wibox.container.margin,
			margins = dpi(5),
			layout
		}
	}
    function s.menu:show()
        self.visible = true
    end
    function s.menu:hide()
        self.visible = false
    end
end


local function hide(s)
	s.menu:hide()
end
local function show(s)
	s.menu:show()
end

return {
	init = init,
	hide = hide,
	show = show
}
