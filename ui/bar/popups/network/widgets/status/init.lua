--  _______ __          __
-- |     __|  |_.---.-.|  |_.--.--.-----.
-- |__     |   _|  _  ||   _|  |  |__ --|
-- |_______|____|___._||____|_____|_____|

-- ------------------------------------------------- --
local left_content =
	wibox.widget {
	text = 'Network Connected:',
	font = 'Operaror SSm Black 11',
	widget = wibox.widget.textbox
}

local right_content =
	wibox.widget {
	text = 'None',
	font = 'Operaror SSm Black 11',
	widget = wibox.widget.textbox
}

local widget_user =
	wibox.widget {
	layout = wibox.layout.align.vertical,
	expand = 'none',
	nil,
	{
		left_content,
		layout = wibox.layout.align.horizontal
	},
	nil
}

local widget_host =
	wibox.widget {
	layout = wibox.layout.align.vertical,
	expand = 'none',
	nil,
	{
		right_content,
		layout = wibox.layout.align.horizontal
	},
	nil
}

local spacer_bar =
	wibox.widget {
	{
		orientation = 'vertical',
		forced_height = dpi(1),
		forced_width = dpi(2),
		shape = gears.shape.rounded_bar,
		widget = wibox.widget.separator
	},
	margins = dpi(10),
	widget = wibox.container.margin
}

awesome.connect_signal(
	'network::connected::wireless',
	function(interface, essid)
		right_content:set_text(essid)
	end
)
awesome.connect_signal(
	'network::connected::wired',
	function(interface)
		right_content:set_text(interface)
	end
)
awesome.connect_signal(
	'network::disconnected::wireless',
	function(interface, essid)
		right_content:set_text('Disconnected')
	end
)
awesome.connect_signal(
	'network::disconnected::wired',
	function(interface)
		right_content:set_text('Disconnected')
	end
)
local widget =
	wibox.widget {
	{
		widget_user,
		spacer_bar,
		widget_host,
		layout = wibox.layout.fixed.vertical
	},
	fg = colors.white,
	widget = wibox.container.background
}

return widget
