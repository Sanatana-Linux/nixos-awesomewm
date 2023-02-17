local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi


--- Minimalist Exit Screen
--- ~~~~~~~~~~~~~~~~~~~~~~

--- Icons
local icon_font = beautiful.nerd_font .. " 98"
local poweroff_text_icon = ""
local reboot_text_icon = ""
local exit_text_icon = ""


local button_bg = beautiful.bg_lighter
local button_size = dpi(180)

--- Commands
local poweroff_command = function()
	awful.spawn.with_shell("systemctl poweroff")
	awesome.emit_signal("powermenu::hide")
end

local reboot_command = function()
	awful.spawn.with_shell("systemctl reboot")
	awesome.emit_signal("powermenu::hide")
end



local exit_command = function()
	awesome.quit()
end



local create_button = function(symbol, hover_color, text, command)
	local icon =
		wibox.widget(
		{
			forced_height = button_size,
			forced_width = button_size,
			align = "center",
			valign = "center",
			font = icon_font,
			markup = "<span foreground='" .. beautiful.fg_normal .. "'>" .. symbol .. "</span>",
			widget = wibox.widget.textbox()
		}
	)

	local button =
		wibox.widget(
		{
			{
				nil,
				icon,
				expand = "none",
				layout = wibox.layout.align.horizontal
			},
			forced_height = button_size,
			forced_width = button_size,
			border_width = 3.25,
			border_color = beautiful.grey,
			shape = utilities.mkroundedrect(),
			bg = button_bg,
			widget = wibox.container.background
		}
	)

	button:buttons(
		gears.table.join(
			awful.button(
				{},
				1,
				function()
					command()
				end
			)
		)
	)

	button:connect_signal(
		"mouse::enter",
		function()
			icon.markup = "<span foreground='" .. beautiful.grey .. "'>" .. icon.text .. "</span>"
			button.border_color = beautiful.dimblack
		end
	)
	button:connect_signal(
		"mouse::leave",
		function()
			icon.markup = "<span foreground='" .. beautiful.fg_normal .. "'>" .. icon.text .. "</span>"
			button.border_color = beautiful.grey
		end
	)

	return button
end

--- Create the buttons
local poweroff = create_button(poweroff_text_icon, beautiful.fg_normal, "Poweroff", poweroff_command)
local reboot = create_button(reboot_text_icon, beautiful.fg_normal, "Reboot", reboot_command)
local exit = create_button(exit_text_icon, beautiful.fg_normal, "Exit", exit_command)


local create_powermenu = function(s)
	s.powermenu =
		wibox(
		{
			screen = s,
			type = "splash",
			visible = false,
			ontop = true,
			bg = beautiful.bg_normal .. "00",
			fg = beautiful.fg_normal,
			height = s.geometry.height,
			width = s.geometry.width,
			x = s.geometry.x,
			y = s.geometry.y
		}
	)

	s.powermenu:buttons(
		gears.table.join(
			awful.button(
				{},
				2,
				function()
					awesome.emit_signal("powermenu::hide")
				end
			),
			awful.button(
				{},
				3,
				function()
					awesome.emit_signal("powermenu::hide")
				end
			)
		)
	)

	s.powermenu:setup(
		{
			nil,
			{
				nil,
				{
					poweroff,
					reboot,
					exit,
					spacing = dpi(50),
					layout = wibox.layout.fixed.horizontal
				},
				expand = "none",
				layout = wibox.layout.align.horizontal
			},
			expand = "none",
			layout = wibox.layout.align.vertical
		}
	)
end

screen.connect_signal(
	"request::desktop_decoration",
	function(s)
		create_powermenu(s)
	end
)

screen.connect_signal(
	"removed",
	function(s)
		create_powermenu(s)
	end
)

local powermenu_grabber =
	awful.keygrabber(
	{
		auto_start = true,
		stop_event = "release",
		keypressed_callback = function(self, mod, key, command)
			if key == "e" then
				exit_command()
			elseif key == "p" then
				poweroff_command()
			elseif key == "r" then
				reboot_command()
			elseif key == "Escape" or key == "q" or key == "x" then
				awesome.emit_signal("powermenu::hide")
			end
		end
	}
)


awesome.connect_signal(
	"powermenu::show",
	function()
		for s in screen do
			s.powermenu.visible = false
		end
		awful.screen.focused().powermenu.visible = true
		powermenu_grabber:start()
	end
)

awesome.connect_signal(
	"powermenu::hide",
	function()
		powermenu_grabber:stop()
		for s in screen do
			s.powermenu.visible = false
		end
	end
)
