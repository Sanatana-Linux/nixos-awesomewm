---@diagnostic disable: undefined-global
-- Mouse bindings configuration - excludes scroll wheel tag switching to avoid accidental workspace changes

-- Import required libraries
local awful = require("awful")                                       -- AwesomeWM core functionality
local capi = { awesome = awesome, client = client, screen = screen } -- Global API references
local menu = require("ui.menu").get_default()                        -- Desktop context menu
local modkey = "Mod4"                                                -- Super/Windows key modifier

-- GLOBAL MOUSE BINDINGS (work anywhere on desktop) --
awful.mouse.append_global_mousebindings({
	-- Right-click on desktop: Show context menu
	awful.button({}, 3, function()
		menu:toggle_desktop_menu() -- Display/hide the desktop right-click menu
	end),
})

-- -------------------------------------------------------------------------- --

-- CLIENT MOUSE BINDINGS (work when clicking on windows) --
-- Connect to signal that requests default mouse bindings for clients
capi.client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		-- Left-click on window: Focus and raise the window
		awful.button({}, 1, function(c)
			c:activate({ context = "mouse_click" }) -- Bring window to focus
		end),

		-- Mod4 + Left-click: Move window by dragging
		awful.button({ modkey }, 1, function(c)
			c:activate({ context = "mouse_click", action = "mouse_move" }) -- Enable window dragging
		end),

		-- Mod4 + Right-click: Resize window by dragging
		awful.button({ modkey }, 3, function(c)
			c:activate({ context = "mouse_click", action = "mouse_resize" }) -- Enable window resizing
		end),
	})
end)
