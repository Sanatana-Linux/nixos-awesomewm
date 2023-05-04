--  _______ __          __
-- |     __|  |_.---.-.|  |_.--.--.-----.
-- |__     |   _|  _  ||   _|  |  |__ --|
-- |_______|____|___._||____|_____|_____|
--  _______
-- |_     _|.----.-----.-----.
--  _|   |_ |  __|  _  |     |
-- |_______||____|_____|__|__|
-- ------------------------------------------------- --

-- Icon widget
local widget_icon =
wibox.widget {
	layout = wibox.layout.align.vertical,
	expand = "none",
	nil,
	{
		id = "icon",
		image = icons.wifi_problem,
		resize = true,
		widget = wibox.widget.imagebox
	},
	nil
}

-- Icon widget container
local widget =
wibox.widget {
	{
		{
			{
				widget_icon,
				layout = wibox.layout.fixed.horizontal
			},
			margins = dpi(4),
			widget = wibox.container.margin
		},
		forced_height = dpi(40),
		widget = clickable_container
	},
	shape = beautiful.client_shape_rounded_small,
	bg = "transparent",
	widget = wibox.container.background
}

awesome.connect_signal(
	"network::status::wireless",
	function(interface, healthy, essid, bitrate, strength)
		if healthy == true then
			if strength <= 100 then
				widget_icon.icon:set_image(icons.wifi_3)
			elseif strength <= 75 then
				widget_icon.icon:set_image(icons.wifi_2)
			elseif strength <= 50 then
				widget_icon.icon:set_image(icons.wifi_1)
			elseif strength <= 25 then
				widget_icon.icon:set_image(icons.wifi_0)
			end
		else
			widget_icon.icon:set_image(icons.wifi_problem)
		end
	end
)
awesome.connect_signal(
	"network::status::wired",
	function(interface, healthy)
		if healthy == true then
			widget_icon.icon:set_image(icons.wired)
		else
			widget_icon.icon:set_image(icons.wired_alert)
		end
	end
)

awesome.connect_signal(
	"network::disconnected::wireless",
	function()
		widget_icon.icon:set_image(icons.wifi_off)
	end
)
awesome.connect_signal(
	"network::disconnected::wired",
	function()
		widget_icon.icon:set_image(icons.wired_off)
	end
)

widget_icon:buttons(
	awful.util.table.join(
		awful.button(
			{},
			1,
			nil,
			function()
				awesome.emit_signal("networks::network:refreshPanel")
			end
		)
	)
)
return widget
