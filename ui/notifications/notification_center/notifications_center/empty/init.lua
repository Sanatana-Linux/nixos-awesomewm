--  _______                  __
-- |    ___|.--------.-----.|  |_.--.--.
-- |    ___||        |  _  ||   _|  |  |
-- |_______||__|__|__|   __||____|___  |
--                   |__|        |_____|
-- ------------------------------------------------- --

-- ------------------------------------------------- --
-- NOTE box it renders in
local box =
	wibox.widget {
	{
		{
			layout = wibox.layout.align.horizontal,
			nil,
			{
				text = 'No New Notifications',
				font = 'Operaror SSm Black 12',
				widget = wibox.widget.textbox,
				align = 'center'
			},
			nil
		},
		widget = wibox.container.margin,
		margins = dpi(5)
	},
	shape = utilities.mkroundedrect(),
	fg = beautiful.fg_normal,
	bg = beautiful.bg_normal,
	widget = wibox.container.background
}

return box
