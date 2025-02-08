local awful = require("awful")
local gears = require("gears")
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function()
	ruled.client.append_rule({
		id = "global",
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen  +awful.placement.honor_workarea + awful.placement.honor_padding,
		},
	})

	ruled.client.append_rule({
		id = "titlebars",
		rule_any = {
			type = { "normal", "dialog" },
		},
		properties = {
			titlebars_enabled = true,
		},
	})

	ruled.client.append_rule({
		id = "floating",
		rule_any = {
			instance = { "copyq", "pinentry", "Xephyr" },
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"Sxiv",
				"Tor Browser",
				"Vlc",
				"xtightvncviewer",
				"nvidia-settings",
				"ark",
				"org.gnome.FileRoller",
				"xephyr_1",
				"Xephyr"
			},
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- thunderbird's calendar.
				"ConfigManager", -- thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
				}
			}, 
			properties = {
				titlebars_enabled = true,
				floating = true,
				raise = true,
				screen = awful.screen.preferred,
				placement = awful.placement.centered + awful.placement.no_offscreen  +awful.placement.honor_workarea + awful.placement.honor_padding,
			},
		})
end)
