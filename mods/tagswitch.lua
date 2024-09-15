-- DPI
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local awful = require("awful")
local fade = require("mods.animation.fade")

local M = wibox({
	visible = false,
	opacity = 0,
	bg = beautiful.mbg .. "88",
	border_color = beautiful.fg3 .. "aa",
	border_width = dpi(1),
	fg = beautiful.fg,
	ontop = true,
	height = dpi(90),
	width = dpi(90),
})

M:setup({
	{
		id = "text",
		markup = "<b>dev</b>",
		font = beautiful.prompt_font .. "36",
		widget = wibox.widget.textbox,
	},
	valign = "center",
	halign = "center",
	layout = wibox.container.place,
})

awful.placement.centered(M, { parent = awful.screen.focused() })

M.changeText = function(text)
	M:get_children_by_id("text")[1]:set_markup("<b>" .. text .. "</b>")
end

M.animate = function(text)
	M.changeText(text)
	fade(M, 50, 0.5)
end

return M
