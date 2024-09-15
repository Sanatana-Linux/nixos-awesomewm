-- NOTE: Thanks again to our friends at bling, this is a stripped down,
-- documented version of the pure theme for the tab bar from that widget
-- library which I also took the liberty of commenting out more thoroughly
-- and adapting to my specific needs, which is also explained in comments
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local awful = require("awful")


local bg_normal = beautiful.bg_gradient_titlebar2 -- Set the normal background color
local fg_normal = beautiful.lesswhite -- Set the normal foreground color
local bg_focus = beautiful.bg_gradient_titlebar -- Set the focused background color
local fg_focus = beautiful.fg -- Set the focused foreground color
local bg_focus_inactive = beautiful.bg_gradient_titlebar -- Set the focused inactive background color
local fg_focus_inactive = beautiful.fg -- Set the focused inactive foreground color
local bg_normal_inactive = beautiful.bg_gradient_button -- Set the normal inactive background color
local fg_normal_inactive = beautiful.fg -- Set the normal inactive foreground color
local font = beautiful.font -- Set the font
local size = dpi(28) -- Set the size
local position = beautiful.tabbar_position or "top" -- Set the position to default to "top" if not specified

-- Create the tabbar widget for a given client
-- NOTE: the tabbar is essentially just a second titlebar and thus is arranged the same way ultimately.
local function create(c, focused_bool, buttons)
	local bg_temp, fg_temp
	if focused_bool then -- Check if the client is focused
		bg_temp = bg_focus -- Set the background color to focused color
		fg_temp = fg_focus -- Set the foreground color to focused color
	else
		bg_temp = bg_normal -- Set the background color to normal color
		fg_temp = fg_normal -- Set the foreground color to normal color
	end

	-- Create the tabbar widget
	local wid_temp = wibox.widget({
		{
			{ -- Left
				wibox.widget.base.make_widget(awful.titlebar.widget.iconwidget(c)), -- Create the icon widget
				buttons = buttons, -- Set the buttons
				layout = wibox.layout.fixed.horizontal, -- Set the layout to fixed horizontal
			},
			{ -- Title
				wibox.widget.base.make_widget(awful.titlebar.widget.titlewidget(c)), -- Create the title widget
				buttons = buttons, -- Set the buttons
				widget = wibox.container.place, -- Set the widget to container place
			},
			{ -- Right
				nil, -- I have no need for buttons I have already on the titlebar here, so nil to keep the layout in order
				layout = wibox.layout.fixed.horizontal, -- Set the layout to fixed horizontal
			},
			layout = wibox.layout.align.horizontal, -- Set the layout to align horizontally
		},
		bg = bg_temp, -- Set the background color
		fg = fg_temp, -- Set the foreground color
		widget = wibox.container.background, -- Set the widget to container background
	})

	return wid_temp -- Return the created tabbar widget
end

-- Return the configuration table
return {
	layout = wibox.layout.flex.horizontal, -- Set the layout to flex horizontal
	create = create, -- Set the create function
	position = position, -- Set the position
	size = size, -- Set the size
	bg_normal = bg_normal, -- Set the normal background color
	bg_focus = bg_focus, -- Set the focused background color
}
