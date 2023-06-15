---@diagnostic disable: undefined-global
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local playerctl = require("signal.playerctl").lib()
local art = wibox.widget({
	image = beautiful.songdefpicture,
	opacity = 0.25,
	forced_height = dpi(240),
	forced_width = dpi(285),
	widget = wibox.widget.imagebox,
})
local createStick = function(height)
	return wibox.widget({
		{
			valign = "center",
			shape = utilities.widgets.mkroundedrect(),
			forced_height = height,
			forced_width = 3,
			bg = beautiful.bg_normal .. "cc",
			widget = wibox.container.background,
		},
		widget = wibox.container.place,
	})
end
local visualizer = wibox.widget({
	createStick(20),
	createStick(10),
	createStick(15),
	createStick(19),
	createStick(8),
	createStick(23),
	spacing = 4,
	layout = wibox.layout.fixed.horizontal,
})
local songname = wibox.widget({
	markup = "Nothing Playing",
	align = "left",
	valign = "center",
	font = beautiful.font .. " 13",
	forced_width = dpi(40),
	widget = wibox.widget.textbox,
})
local artistname = wibox.widget({
	markup = "None",
	align = "left",
	valign = "center",
	forced_height = dpi(20),
	widget = wibox.widget.textbox,
})

local status = wibox.widget({
	markup = "Paused",
	align = "left",
	valign = "bottom",
	forced_height = dpi(20),
	widget = wibox.widget.textbox,
})

local prev = wibox.widget({
	align = "center",
	font = beautiful.nerd_font .. " 24",
	text = "󰒮",
	widget = wibox.widget.textbox,
	buttons = {
		awful.button({}, 1, function()
			playerctl:previous()
		end),
	},
})

local slider = wibox.widget({
	bar_shape = utilities.widgets.mkroundedrect(),
	bar_height = 6,
	handle_color = beautiful.fg_normal,
	bar_color = beautiful.grey .. "11",
	bar_active_color = beautiful.grey .. "88",
	handle_shape = gears.shape.rectangle,
	handle_width = 8,
	forced_height = 6,
	forced_width = 100,
	maximum = 100,
	widget = wibox.widget.slider,
})
local is_prog_hovered = false
slider:connect_signal("mouse::enter", function()
	is_prog_hovered = true
end)
slider:connect_signal("mouse::leave", function()
	is_prog_hovered = false
end)
slider:connect_signal("property::value", function(_, value)
	if is_prog_hovered then
		playerctl:set_position(value)
	end
end)
playerctl:connect_signal("position", function(_, interval_sec, length_sec)
	slider.maximum = length_sec
	slider.value = interval_sec
end)
local next = wibox.widget({
	align = "center",
	font = beautiful.nerd_font .. " 24",
	text = "󰒭",
	widget = wibox.widget.textbox,
	buttons = {
		awful.button({}, 1, function()
			playerctl:next()
		end),
	},
})

local play = wibox.widget({
	align = "center",
	font = beautiful.nerd_font .. " 23",
	markup = "󰐊",
	widget = wibox.widget.textbox,
	buttons = {
		awful.button({}, 1, function()
			playerctl:play_pause()
		end),
	},
})

local finalwidget = wibox.widget({
	{
		{
			art,
			{
				{
					widget = wibox.widget.textbox,
				},
				bg = {
					type = "linear",
					from = { 0, 0 },
					to = { 250, 0 },
					stops = {
						{ 0, beautiful.bg_normal .. "00" },
						{ 1, beautiful.bg_contrast },
					},
				},
				widget = wibox.container.background,
			},
			{
				nil,
				{
					{
						{
							songname,
							artistname,
							spacing = 3,
							layout = wibox.layout.fixed.vertical,
						},
						nil,
						{
							status,
							nil,
							visualizer,
							layout = wibox.layout.align.horizontal,
						},
						expand = "none",
						layout = wibox.layout.align.vertical,
					},
					widget = wibox.container.margin,
					margins = dpi(15),
				},
				slider,
				layout = wibox.layout.align.vertical,
			},
			layout = wibox.layout.stack,
		},
		{
			{
				{
					{
						prev,
						{
							{
								play,
								widget = wibox.container.margin,
								margins = 5,
							},
							shape = utilities.widgets.mkroundedrect(),
							widget = wibox.container.background,
							bg = beautiful.bg_normal .. "11",
						},
						next,
						expand = "none",
						layout = wibox.layout.align.vertical,
					},
					widget = wibox.container.margin,
					margins = dpi(10),
				},
				bg = beautiful.bg_normal .. "88",
				widget = wibox.container.background,
			},
			widget = wibox.container.margin,
			margins = {
				left = 20,
			},
		},
		layout = wibox.layout.align.horizontal,
	},
	widget = wibox.container.margin,
	margins = dpi(0),
})

playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, new, player_name)
	-- Set art widget
	if title == "" then
		title = "None"
	end
	if artist == "" then
		artist = "Unknown"
	end
	if album_path == "" then
		album_path = beautiful.songdefpicture
	end
	if string.len(title) > 30 then
		title = string.sub(title, 0, 30) .. "..."
	end
	if string.len(artist) > 22 then
		artist = string.sub(artist, 0, 22) .. "..."
	end
	songname:set_markup_silently(title)
	artistname:set_markup_silently(artist)
	art.image = utilities.visual.crop_surface(1.5, gears.surface.load_uncached(album_path))
end)

playerctl:connect_signal("position", function(_, interval_sec, length_sec, player_name) end)
playerctl:connect_signal("playback_status", function(_, playing, player_name)
	play.markup = playing
			and utilities.textual.get_colorized_markup("󰏤", beautiful.fg_normal)
		or utilities.textual.get_colorized_markup("󰐊", beautiful.fg_normal)
	status.markup = playing and "Playing" or "Paused"
end)

return finalwidget
