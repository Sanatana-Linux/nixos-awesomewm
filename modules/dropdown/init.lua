---@diagnostic disable: undefined-global
-------------------------------------------------------------------
-- Drop-down applications manager for the awesome window manager
-------------------------------------------------------------------
-- Coded  by: * Lucas de Vries <lucas@glacicle.com>
-- Hacked by: * Adrian C. (anrxc) <anrxc@sysphere.org>
-- Licensed under the WTFPL version 2
--   * http://sam.zoy.org/wtfpl/COPYING
-------------------------------------------------------------------
-- To use this module add:
--   local Dropdown = require("Dropdown")
-- to the top of your rc.lua, and call it from a keybinding:
--   Dropdown(prog, vert, horiz, width, height, sticky, screen)
--
-- Parameters:
--   prog   - Program to run; "urxvt", "gmrun", "thunderbird"
--   vert   - Vertical; "bottom", "center" or "top" (default)
--   horiz  - Horizontal; "left", "right" or "center" (default)
--   width  - Width in absolute pixels, or width percentage
--            when <= 1 (1 (100% of the screen) by default)
--   height - Height in absolute pixels, or height percentage
--            when <= 1 (0.25 (25% of the screen) by default)
--   sticky - Visible on all tags, false by default
--   screen - Screen (optional), mouse.screen by default
-------------------------------------------------------------------

-- Grab environment
local pairs = pairs
local awful = require("awful")
local setmetatable = setmetatable
local capi = {
	mouse = mouse,
	client = client,
	screen = screen,
}

-- Dropdown: drop-down applications manager for the awesome window manager

local dropdown = {}

-- Use Meta + X to run
--      require('dropdown').showall()
-- if some of your windows lost in hidden space
function dropdown.showall()
	for prog, scrs in pairs(dropdown) do
		for src, c in pairs(scrs) do
			awful.client.movetotag(awful.tag.selected(capi.mouse.screen), c)
			c.hidden = false
			c:raise()
			capi.client.focus = c
		end
	end
end

-- Attach window under cursor to prog
function dropdown.attach(prog)
	if not dropdown[prog] then
		dropdown[prog] = {}
	end

	screen = capi.mouse.screen
	c = awful.mouse.client_under_pointer()
	dropdown[prog][screen] = c
end

-- Create a new window for the drop-down application when it doesn't
-- exist, or toggle between hidden and visible states when it does
function dropdown.toggle(prog, vert, horiz, width, height, sticky, screen)
	vert = vert or "top"
	horiz = horiz or "center"
	width = width or 1
	height = height or 0.25
	sticky = sticky or false
	screen = screen or capi.mouse.screen

	-- Determine signal usage in this version of awesome
	local attach_signal = capi.client.connect_signal or capi.client.add_signal
	local detach_signal = capi.client.disconnect_signal or capi.client.remove_signal

	if not dropdown[prog] then
		dropdown[prog] = {}

		-- Add unmanage signal for Dropdown programs
		attach_signal("unmanage", function(c)
			for scr, cl in pairs(dropdown[prog]) do
				if cl == c then
					dropdown[prog][scr] = nil
				end
			end
		end)
	end

	if not dropdown[prog][screen] then
		spawnw = function(c)
			dropdown[prog][screen] = c

			-- Dropdown clients are floaters
			 c.floating = true
			-- Client geometry and placement
			local screengeom = capi.screen[screen].workarea

			if width <= 1 then
				width = math.ceil(screengeom.width * width) - 3
			end
			if height <= 1 then
				height = math.ceil(screengeom.height * height)
			end

			if horiz == "left" then
				x = screengeom.x
			elseif horiz == "right" then
				x = screengeom.width - width
			else
				x = screengeom.x + math.ceil((screengeom.width - width) / 2) - 1
			end

			if vert == "bottom" then
				y = screengeom.height + screengeom.y - height
			elseif vert == "center" then
				y = screengeom.y + math.ceil((screengeom.height - height) / 2)
			else
				y = screengeom.y
			end

			-- Client properties
			c:geometry({ x = x, y = y, width = width, height = height })
			c.ontop = true
			c.above = true
			c.skip_taskbar = false
			if sticky then
				c.sticky = true
			end
			if c.titlebar then
				awful.titlebar.remove(c)
			end

			c:raise()
			capi.client.focus = c
			detach_signal("manage", spawnw)
		end

		-- Add manage signal and spawn the program
		attach_signal("manage", spawnw)
		awful.util.spawn_with_shell(prog, false) -- original without '_with_shell'
	else
		-- Get a running client
		c = dropdown[prog][screen]

		status, err = pcall(awful.client.movetotag, awful.tag.selected(screen), c)
		if err then
			dropdown[prog][screen] = false
			return
		end

		-- Switch the client to the current workspace
		if c:isvisible() == false then
			c.hidden = true
			awful.client.movetotag(awful.tag.selected(screen), c)
		end

		-- Focus and raise if hidden
		if c.hidden then
			-- Make sure it is centered
			if vert == "center" then
				awful.placement.center_vertical(c)
			end
			if horiz == "center" then
				awful.placement.center_horizontal(c)
			end
			c.hidden = false
			c:raise()
			capi.client.focus = c
		else -- Hide and detach tags if not
			c.hidden = true
			local ctags = c:tags()
			for i, t in pairs(ctags) do
				ctags[i] = nil
			end
			c:tags(ctags)
		end
	end
end

return dropdown
