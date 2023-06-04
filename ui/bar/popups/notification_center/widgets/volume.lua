local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local gears = require("gears")

local maticons = gears.filesystem.get_configuration_dir() .. "/themes/assets/icons/svg/"

local update_on_master

local entry_template = {
	widget = wibox.layout.fixed.horizontal,
	forced_height = dpi(30),
	spacing = dpi(5),
	{
		widget = wibox.container.margin,
		forced_width = dpi(30),
		margins = dpi(5),
		{
			id = "symbol",
			widget = wibox.widget.imagebox,
			image = gears.color.recolor_image(maticons .. "volume_up.svg", beautiful.fg_normal),
			resize = true,
		},
		buttons = {
			awful.button({
				modifiers = {},
				button = 1,
				on_press = function()
					awful.spawn("pamixer -t")
					update_on_master()
				end,
			}),
		},
	},
	{
		id = "slider",
		widget = wibox.widget.slider,
		handle_cursor = "hand1",
		handle_shape = gears.shape.circle,
		handle_width = dpi(20),
		handle_border_width = dpi(2),
		handle_border_color = beautiful.bg_normal,
		handle_color = beautiful.dark_grey,
		bar_shape = gears.shape.rounded_bar,
		bar_height = dpi(5),
		bar_color = beautiful.dark_grey,
		bar_active_color = beautiful.blue,
		maximum = 100,
		minimum = 0,
		value = 50,
	},
}

local widget = wibox.widget(entry_template)
local slider = widget:get_children_by_id("slider")[1]

slider:connect_signal("mouse::enter", function()
	slider.handle_color = beautiful.grey
end)
slider:connect_signal("mouse::leave", function()
	slider.handle_color = beautiful.dark_grey
end)

update_on_master = function()
	--volume
	awful.spawn.easy_async("pamixer --get-volume", function(out, _, _, code)
		if code == 0 then
			slider.value = out
		end
	end)
	--mute status
	awful.spawn.easy_async("pamixer --get-mute", function(_, _, _, code)
		if code == 0 then
			slider.bar_active_color = beautiful.grey
			widget
				:get_children_by_id("symbol")[1]
				:set_image(gears.color.recolor_image(maticons .. "volume_off.svg", beautiful.fg_normal))
		else
			slider.bar_active_color = beautiful.blue
			widget
				:get_children_by_id("symbol")[1]
				:set_image(gears.color.recolor_image(maticons .. "volume_up.svg", beautiful.fg_normal))
		end
	end)
end

local timer = gears.timer({
	timeout = 5,
	autostart = true,
	callback = update_on_master,
})

slider:add_button(awful.button({
	modifiers = {},
	button = 1,
	on_press = function()
		timer:stop()
		slider.handle_color = beautiful.grey
	end,
}))

slider:connect_signal("property::value", function()
	awful.spawn.with_shell("pamixer --set-volume " .. slider.value)
	timer:start()
end)

return widget
