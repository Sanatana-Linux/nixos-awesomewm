local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local notifwidget = require("ui.bar.popups.notification_center.widgets.notifcenter")

awful.screen.connect_for_each_screen(function(s)
	-- ----------------------------------------------------------- --
	notification_center = wibox({
		type = "dock",
		shape = utilities.widgets.mkroundedrect(),
		screen = s,
		width = dpi(380),
		height = dpi(560),
		bg = beautiful.bg_normal .. "cc",
		border_color = beautiful.grey .. "cc",
		border_width = dpi(2),
		margins = dpi(20),
		ontop = true,
		visible = false,
	})

	-- animations
	--------------
	local slide_right = rubato.timed({
		pos = s.geometry.height,
		rate = 60,
		intro = 0.14,
		duration = 0.33,
		subscribed = function(pos)
			notification_center.y = (s.geometry.y - beautiful.bar_height) + pos
		end,
	})

	local slide_end = gears.timer({
		single_shot = true,
		timeout = 0.33 + 0.08,
		callback = function()
			notification_center.visible = false
		end,
	})

	-- -------------------------------------------------------------------------- --
	-- keygrabber
	--
	keygrabber_no = awful.keygrabber({
		keybindings = {
			awful.key({
				modifiers = {},
				key = "Escape",
				on_press = function()
					no_toggle()
					keygrabber_no:stop()
					collectgarbage("collect")
				end,
			}),
			awful.key({
				modifiers = {},
				key = "q",
				on_press = function()
					no_toggle()
					keygrabber_no:stop()
					collectgarbage("collect")
				end,
			}),
			awful.key({
				modifiers = {},
				key = "x",
				on_press = function()
					no_toggle()
					keygrabber_no:stop()
					collectgarbage("collect")
				end,
			}),
		},
	})

	-- toggler script
	--~~~~~~~~~~~~~~~
	local screen_backup = 1

	no_toggle = function(screen)
		-- set screen to default, if none were found
		if not screen then
			screen = awful.screen.focused()
		end

		-- control center x position
		notification_center.x = screen.geometry.x + beautiful.useless_gap

		-- toggle visibility
		if notification_center.visible then
			-- check if screen is different or the same
			if screen_backup ~= screen.index then
				notification_center.visible = true
				keygrabber_no:start()
			else
				keygrabber_no:stop()
				slide_end:again()
				slide_right.target = s.geometry.height
			end
		elseif not notification_center.visible then
			slide_right.target = s.geometry.height - (notification_center.height + beautiful.useless_gap * 2)
			notification_center.visible = true
			keygrabber_no:start()
		end

		-- set screen_backup to new screen
		screen_backup = screen.index
	end
	-- Eof toggler script
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	no_off = function(screen)
		if notification_center.visible then
			slide_end:again()
			slide_right.target = s.geometry.height
		end
	end

	-- -------------------------------------------------------------------------- --
	function no_show(s)
		notification_center.visible = true
		keygrabber_no:start()
	end

	function no_hide(s)
		notification_center.visible = false
		keygrabber_no:stop()
		collectgarbage("collect")
	end

	awesome.connect_signal("notification_center::toggle", function(s)
		no_toggle(s)
	end)
	notification_center:setup({
		{
			{
				nil,
				require("ui.bar.popups.notification_center.widgets.notifcenter"),
				nil,
				halign = "center",
				valign = "center",
				layout = wibox.layout.align.horizontal,
			},
			widget = wibox.container.margin,
			margins = dpi(20),
		},
		layout = wibox.layout.fixed.vertical,
	})
end)
