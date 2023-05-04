--  _______                         __     __
-- |     __|.-----.---.-.----.----.|  |--.|__|.-----.-----.
-- |__     ||  -__|  _  |   _|  __||     ||  ||     |  _  |
-- |_______||_____|___._|__| |____||__|__||__||__|__|___  |
--                                                  |_____|
-- ------------------------------------------------- --
local box = {}

local signalIcon =
	wibox.widget {
	layout = wibox.layout.align.vertical,
	expand = 'none',
	nil,
	{
		id = 'icon',
		image = icons.wifi_2,
		resize = true,
		widget = wibox.widget.imagebox
	},
	nil
}

local wifiIcon =
	wibox.widget {
	{
		{
			signalIcon,
			margins = dpi(7),
			widget = wibox.container.margin
		},
		shape = beautiful.client_shape_rounded_small,
		bg = beautiful.bg_button,
		widget = wibox.container.background
	},
	forced_width = dpi(48),
	forced_height = dpi(48),
	widget = clickable_container
}

local content =
	wibox.widget {
	{
		{
			{
				text = 'Searching...',
				font = beautiful.font .. ' Bold  14',
				widget = wibox.widget.textbox
			},
			layout = wibox.layout.align.vertical
		},
		margins = dpi(10),
		widget = wibox.container.margin
	},
	shape = beautiful.client_shape_rounded_small,
	bg = beautiful.bg_normal,
	widget = wibox.container.background
}

box =
	wibox.widget {
	{
		wifiIcon,
		content,
		-- buttons,
		layout = wibox.layout.align.horizontal
	},
	shape = beautiful.client_shape_rounded_xl,
	fg = colors.white,
	border_width = dpi(2),
	border_color = colors.alpha(colors.black, 'cc'),
	widget = wibox.container.background
}

return box
