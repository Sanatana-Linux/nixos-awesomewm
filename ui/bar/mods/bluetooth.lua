local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi
local helpers = require("helpers")

local blue = helpers.mkbtn({
	font = beautiful.icon .. " 22",
	markup = helpers.colorize_text("󰂯", beautiful.fg),
	widget = wibox.widget.textbox,
	valign = "center",
	align = "center",
}, beautiful.bg_gradient_button, beautiful.bg_gradient_button_alt, dpi(5), dpi(32), dpi(32))

awesome.connect_signal("signal::bluetooth", function(value)
	if value then
		blue.markup = helpers.colorize_text("󰂯", beautiful.blue)
	else
		blue.markup = helpers.colorize_text("󰂲", beautiful.fg2 .. "99")
	end
end)

return blue
