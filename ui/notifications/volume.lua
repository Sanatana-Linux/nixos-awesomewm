---@diagnostic disable: undefined-global
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local width = dpi(50)
local height = dpi(300)

local active_color_1 = {
	type = "linear",
	from = { 0, 0 },
	to = { 200, 50 }, -- replace with w,h later
	stops = { { 0, beautiful.fg_focus }, { 0.50, beautiful.fg_normal } },
}

local volume_icon = wibox.widget({
	markup = "<span foreground='" .. beautiful.fg_normal .. "'><b></b></span>",
	align = "center",
	valign = "center",
	font = beautiful.font_name .. "15",
	widget = wibox.widget.textbox,
})

local volume_adjust = awful.popup({
	type = "normal",
	maximum_width = width,
	maximum_height = height,
	visible = false,
	ontop = true,
	widget = wibox.container.background,
	bg = "#00000000",
	placement = function(c)
		awful.placement.right(c, { margins = { right = 10 } })
	end,
})

local volume_bar = wibox.widget({
	bar_shape = gears.shape.rounded_rect,
	shape = gears.shape.rounded_rect,
	background_color = beautiful.bg_contrast,
	color = active_color_1,
	max_value = 100,
	value = 0,
	widget = wibox.widget.progressbar,
})

local volume_ratio = wibox.widget({
	layout = wibox.layout.ratio.vertical,
	{
		{ volume_bar, direction = "east", widget = wibox.container.rotate },
		top = dpi(20),
		left = dpi(20),
		right = dpi(20),
		widget = wibox.container.margin,
	},
	volume_icon,
	nil,
})

volume_ratio:adjust_ratio(2, 0.72, 0.28, 0)

volume_adjust.widget = wibox.widget({
	volume_ratio,
	shape = utilities.widgets.mkroundedrect(),
	border_width = dpi(0.75),
	border_color = beautiful.grey .. "cc",
	bg = beautiful.bg_normal .. "33",
	widget = wibox.container.background,
})

-- create a 3 second timer to hide the volume adjust
-- component whenever the timer is started
local hide_volume_adjust = gears.timer({
	timeout = 3,
	autostart = true,
	callback = function()
		volume_adjust.visible = false
		volume_bar.mouse_enter = false
	end,
})

awesome.connect_signal("signal::volume", function(vol, muted)
	volume_bar.value = vol

	if muted == 1 or vol == 0 then
		volume_icon.markup = "<span foreground='" .. beautiful.fg_normal .. "'></span>"
	else
		volume_icon.markup = "<span foreground='" .. beautiful.fg_normal .. "'></span>"
	end

	if volume_adjust.visible then
		hide_volume_adjust:again()
	else
		volume_adjust.visible = true
		hide_volume_adjust:start()
	end
end)
