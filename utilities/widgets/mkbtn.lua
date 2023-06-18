local wibox = require("wibox")
local beautiful = require("beautiful")
local mkroundedrect = require("utilities.widgets.mkroundedrect")
local add_hover = require("utilities.visual.add_hover")
local dpi = beautiful.xresources.apply_dpi

return function(template, bg, hbg, radius)
	local button = wibox.widget({
		{
			template,
			margins = dpi(5),
			widget = wibox.container.margin,
		},
		bg = bg,
		widget = wibox.container.background,
		shape = mkroundedrect(radius),
		border_width = dpi(0.75),
		border_color = beautiful.grey,
	})

	if bg and hbg then
		add_hover(button, bg, hbg)
	end

	return button
end