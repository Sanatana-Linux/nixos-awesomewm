--  ______ __
-- |      |  |.-----.---.-.----.
-- |   ---|  ||  -__|  _  |   _|
-- |______|__||_____|___._|__|
--  _______ __ __
-- |   _   |  |  |
-- |       |  |  |
-- |___|___|__|__|
-- ------------------------------------------------- --
-- NOTE icon
local widget_icon =
	wibox.widget {
	layout = wibox.layout.align.vertical,
	expand = 'none',
	nil,
	{
		id = 'icon',
		image = icons.clearNotifications,
		resize = true,
		widget = wibox.widget.imagebox
	},
	nil
}
-- ------------------------------------------------- --
-- NOTE widget template
local widget =
	wibox.widget {
	{
		{
			{
				widget_icon,
				layout = wibox.layout.fixed.horizontal
			},
			margins = dpi(9),
			widget = wibox.container.margin
		},
		widget = wibox.container.background
	},
	shape = utilities.mkroundedrect(),
	bg = beautiful.bg_lighter,
	widget = wibox.container.background
}
-- ------------------------------------------------- --
-- NOTE connect signal for mouse entry
widget:connect_signal(
	'mouse::enter',
	function()
		widget.bg = beautiful.accent
	end
)
-- ------------------------------------------------- --
-- NOTE connect signal for mouse departure
widget:connect_signal(
	'mouse::leave',
	function()
		widget.bg = beautiful.bg_lighter
	end
)
-- ------------------------------------------------- --
-- NOTE button binding
widget:buttons(
	gears.table.join(
		awful.button(
			{},
			1,
			nil,
			function()
				_G.resetPanelLayout()
			end
		)
	)
)

return widget
