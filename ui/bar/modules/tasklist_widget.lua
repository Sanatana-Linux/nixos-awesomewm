-- ui/bar/modules/tasklist_widget.lua
-- Encapsulates the wibar widget for the tasklist.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gsurface = require("gears.surface")
local Gio = require("lgi").Gio
local menu = require("ui.menu").get_default()
local dpi = beautiful.xresources.apply_dpi
local client = client -- For direct access to focused client

-- Creates a tasklist widget for the given screen.
-- Includes icons for each task item.
-- @param s screen The screen object.
-- @return widget The tasklist widget.
return function(s)
	local tasklist_widget = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = { -- Button bindings for interacting with tasks
			awful.button({}, 1, function(c)
				c:activate({ context = "tasklist", action = "toggle_minimization" })
				menu:hide() -- Hide any open menus
			end),
			awful.button({}, 3, function(c)
				menu:toggle_client_menu(c)
			end),
		},
		layout = {
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(5),
		},
		widget_template = { -- Template for each task item
			id = "c-background",
			widget = wibox.container.background,
			shape = beautiful.rrect(dpi(8)),
			{
				layout = wibox.layout.stack, -- Stack layout for pointer and content
				{ -- Main content (icon and text)
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(6),
					{ -- Icon
						widget = wibox.container.margin,
						margins = { left = dpi(8), right = dpi(0), top = dpi(5), bottom = dpi(5) },
						{
							id = "c-icon",
							widget = wibox.widget.imagebox,
							resize = true,
							forced_width = dpi(16), -- Consistent icon size
							forced_height = dpi(16),
							valign = "center",
							halign = "center",
						},
					},
					{ -- Text
						widget = wibox.container.margin,
						margins = { left = dpi(0), right = dpi(8), top = dpi(5), bottom = dpi(5) },
						{
							widget = wibox.container.constraint,
							strategy = "max",
							width = dpi(120), -- Max width for task name
							{
								id = "c-text",
								widget = wibox.widget.textbox,
								align = "center",
								valign = "center",
								ellipsize = "end",
							},
						},
					},
				},
				{ -- Active client indicator (pointer)
					layout = wibox.layout.align.vertical,
					nil,
					nil, -- Align to bottom
					{
						widget = wibox.container.margin,
						margins = { left = dpi(12), right = dpi(12) },
						{
							id = "c-pointer",
							widget = wibox.container.background,
							shape = beautiful.prrect(true, true, false, false, dpi(2)),
							bg = beautiful.ac,
						},
					},
				},
			},
		},
	})

	-- Callback to update task item appearance and icon.
	local function c_callback(tw, c)
		local c_background = tw:get_children_by_id("c-background")[1]
		local c_pointer = tw:get_children_by_id("c-pointer")[1]
		local c_text = tw:get_children_by_id("c-text")[1]
		local c_icon_widget = tw:get_children_by_id("c-icon")[1]

		-- Set task text (class or "untitled")
		c_text:set_markup_silently((c.class and c.class ~= "") and c.class or c.name or "untitled")
		c_background:set_bg(beautiful.bg_gradient_button)

		-- Set foreground based on minimized state
		if c.minimized then
			c_background:set_fg(beautiful.fg_alt)
		else
			c_background:set_fg(beautiful.fg)
		end

		-- Set active pointer visibility
		if c == client.focus and c.screen == s and c:isvisible() then
			c_pointer:set_forced_height(dpi(3))
		else
			c_pointer:set_forced_height(0)
		end

		-- Set icon for the client
		local icon_surface
		if c.icon then -- If client provides an icon directly (path or surface)
			icon_surface = gsurface.load(c.icon)
		end
		if not icon_surface and c.app_id then -- Try app_id for Wayland/DBus based apps
			local app_info = Gio.DesktopAppInfo.new(c.app_id)
			if app_info then
				local gicon = app_info:get_icon()
				if gicon then
					icon_surface = gsurface.load_gicon(gicon, dpi(16))
				end
			end
		end
		if not icon_surface and c.class then -- Fallback to class name
			icon_surface = gsurface.load_gicon_from_theme(c.class, dpi(16))
		end
		if not icon_surface and c.instance then -- Fallback to instance name
			icon_surface = gsurface.load_gicon_from_theme(c.instance, dpi(16))
		end
		if not icon_surface then -- Ultimate fallback
			icon_surface = gsurface.load_gicon_from_theme("application-x-executable", dpi(16))
		end

		if icon_surface then
			c_icon_widget:set_image(icon_surface)
		else
			c_icon_widget:set_image(nil) -- Clear image if no icon found
		end
	end

	-- Apply callback for creation and updates, and add hover effects.
	tasklist_widget.widget_template.create_callback = function(tw, c, _, _)
		c_callback(tw, c)
		local c_background = tw:get_children_by_id("c-background")[1]

		tw:connect_signal("mouse::enter", function()
			c_background:set_bg(beautiful.bg_gradient_button_alt)
		end)
		tw:connect_signal("mouse::leave", function()
			c_background:set_bg(beautiful.bg_gradient_button)
		end)
	end

	tasklist_widget.widget_template.update_callback = function(tw, c, _, _)
		c_callback(tw, c)
	end

	return tasklist_widget
end
