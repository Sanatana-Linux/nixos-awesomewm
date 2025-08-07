---@diagnostic disable: undefined-global
local awful = require("awful")
local capi = { awesome = awesome, client = client }
local dropdown = require("modules.dropdown")
local launcher = require("ui.popups.launcher").get_default()
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local day_info_panel = require("ui.popups.day_info_panel").get_default()
local modkey = "Mod4"
local control_panel = require("ui.popups.control_panel").get_default()

awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, "F1", hotkeys_popup.show_help, { description = "show keybindings table", group = "awesome" }),

	-- -------------------------------------------------------------------------- --

	awful.key({ modkey }, "r", capi.awesome.restart, { description = "reload awesome", group = "awesome" }),

	awful.key(
		{ modkey },
		"d",
		function() day_info_panel:toggle() end, -- Wrapped in a function
		{ description = "toggle day info panel", group = "awesome" } -- Updated description
	),
	awful.key(
		{ modkey },
		"e",
		function() control_panel:toggle() end, -- Wrapped in a function
		{ description = "toggle control panel", group = "awesome" } -- Updated description
	),

	

	-- -------------------------------------------------------------------------- --

	awful.key({ modkey, "Shift" }, "q", capi.awesome.quit, { description = "quit awesome", group = "awesome" }),

	-- -------------------------------------------------------------------------- --

	awful.key({ modkey }, "Return", function()
		dropdown.toggle("kitty", "left", "top", 0.75, 0.75)
	end, { description = "open a terminal", group = "awesome" }),

	-- -------------------------------------------------------------------------- --

	awful.key({ modkey, "Control" }, "Return", function()
		awful.spawn("kitty")
	end, { description = "open a dropdown terminal", group = "awesome" }),

	-- -------------------------------------------------------------------------- --

	awful.key({ modkey, "Shift" }, "Return", function()
		launcher:show()
	end, { description = "open application launch menu", group = "awesome" }),

	-- -------------------------------------------------------------------------- --

	awful.key({ modkey }, "p", function()
		menubar.show()
	end, { description = "show the menubar", group = "awesome" }),

	-- -- -------------------------------------------------------------------------- --
	-- -- Client Selection Menu
	-- awful.key({ modkey }, "Tab", function()
	-- 	awful.menu.menu_keys.down = { "Down", "Alt_L" }
	-- 	awful.menu.menu_keys.up = { "Up", "Alt_R" }
	-- 	awful.menu.clients({
	-- 		theme = {
	-- 			width = dpi(450),
	-- 			bg = beautiful.bg_gradient,
	-- 			border_color = beautiful.fg .. "99",
	-- 			border_width = dpi(1),
	-- 		},
	-- 	}, { keygrabber = true })
	-- end, { description = "Client Selection Menu", group = "awesome" }),
	-- -------------------------------------------------------------------------- --
	-- Tab Between Applications
	awful.keygrabber({
		keybindings = {
			--		awful.key({
--				modifiers = { "Mod1" },
--				key = "Tab",
--				on_press = function()
--					awesome.emit_signal("window_switcher::next")
--				end,
--			}),
		},
		root_keybindings = {
			awful.key({
				modifiers = { "Mod1" },
				key = "Tab",
				on_press = function() end,
			}),
		},
		stop_key = "Mod1",
		stop_event = "release",
		start_callback = function()
			awesome.emit_signal("window_switcher::toggle")
		end,
		stop_callback = function()
			awesome.emit_signal("window_switcher::raise")
			awesome.emit_signal("window_switcher::toggle")
		end,
		export_keybindings = true,
	}),
})
