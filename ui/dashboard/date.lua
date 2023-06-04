---@diagnostic disable: undefined-global
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local dpi = beautiful.xresources.apply_dpi

-- enable signals
require("signal.date")

local hour = wibox.widget({
	markup = "00",
	font = beautiful.font_name .. " Bold 40",
	widget = wibox.widget.textbox,
})

awesome.connect_signal("date::hour", function(hour_val)
	hour.markup = hour_val
end)

local minutes = wibox.widget({
	markup = "00",
	font = beautiful.font_name .. " 40",
	widget = wibox.widget.textbox,
})

awesome.connect_signal("date::minutes", function(minutes_val)
	minutes.markup = minutes_val
end)

local function mksquare(color)
	return wibox.widget({
		{
			{
				left = dpi(8),
				top = dpi(8),
				bottom = dpi(8),
				right = dpi(8),
				widget = wibox.container.margin,
			},
			shape = gears.shape.cross,
			bg = color,
			widget = wibox.container.background,
		},
		widget = wibox.container.margin,
		left = dpi(8),
		top = dpi(8),
		bottom = dpi(8),
		right = dpi(8),
	})
end

local sep = wibox.widget({
	mksquare(beautiful.lessgrey .. "77"),
	mksquare(beautiful.lessgrey .. "77"),
	layout = wibox.layout.flex.vertical,
})

local date = wibox.widget({
	{
		{
			{
				hour,
				{
					sep,
					top = dpi(7),
					bottom = dpi(7),
					widget = wibox.container.margin,
				},
				minutes,
				spacing = dpi(17),
				layout = wibox.layout.fixed.horizontal,
			},
			halign = "center",
			widget = wibox.container.margin,
			layout = wibox.container.place,
		},
		widget = wibox.container.background,
		bg = beautiful.bg_contrast,
		border_color = beautiful.lessgrey .. "77",
		border_width = dpi(1),
		shape = utilities.widgets.mkroundedrect(),
	},
	widget = wibox.container.margin,
	layout = wibox.layout.flex.horizontal,
	left = dpi(48),
	right = dpi(48),
})

return date
