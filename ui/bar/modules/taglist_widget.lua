-- ui/bar/modules/taglist_widget.lua
-- Encapsulates the wibar widget for the taglist.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local capi = { client = client }
local modkey = "Mod4"

-- Creates a taglist widget for the given screen.
-- @param s screen The screen object.
-- @return widget The taglist widget.
return function(s)
	local taglist_widget = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = { -- Button bindings for interacting with tags
			awful.button({}, 1, function(t)
				t:view_only()
			end),
			awful.button({ modkey }, 1, function(t)
				if capi.client.focus then
					capi.client.focus:move_to_tag(t)
				end
			end),
			awful.button({}, 3, function(t)
				awful.tag.viewtoggle(t)
			end),
			awful.button({ modkey }, 3, function(t)
				if capi.client.focus then
					capi.client.focus:toggle_tag(t)
				end
			end),
			awful.button({}, 4, function(t)
				awful.tag.viewprev(t.screen)
			end),
			awful.button({}, 5, function(t)
				awful.tag.viewnext(t.screen)
			end),
		},
		layout = {
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(2),
		},
		widget_template = { -- Template for each tag item
			id = "t-background",
			widget = wibox.container.background,
			shape = beautiful.rrect(dpi(5)),
			{
				widget = wibox.container.margin,
				margins = { left = dpi(7), right = dpi(7), top = dpi(4), bottom = dpi(4) },
				{
					id = "t-text",
					widget = wibox.widget.textbox,
					align = "center",
				},
			},
		},
	})

	-- Callback to update tag item appearance based on its state.
	local function t_callback(tw, t)
		local t_background = tw:get_children_by_id("t-background")[1]
		local t_text = tw:get_children_by_id("t-text")[1]

		t_text.markup = t.index -- Display tag index

		-- Set background and foreground based on tag state (selected, occupied, urgent)
		if t.selected then
			t_background:set_bg(beautiful.ac)
			t_background:set_fg(beautiful.bg)
		elseif #t:clients() > 0 then
			t_background:set_bg(beautiful.bg_gradient_button)
			t_background:set_fg(beautiful.fg)
		else
			t_background:set_bg(beautiful.bg_gradient_button)
			t_background:set_fg(beautiful.fg_alt)
		end

		-- Highlight if any client on the tag is urgent
		for _, c in ipairs(t:clients()) do
			if c.urgent then
				t_background:set_fg(beautiful.red)
				break
			end
		end
	end

	-- Apply callback for creation and updates, and add hover effects.
	taglist_widget.widget_template.create_callback = function(tw, t)
		t_callback(tw, t)
		local t_background = tw:get_children_by_id("t-background")[1]

		tw:connect_signal("mouse::enter", function()
			if not t.selected then
				t_background:set_bg(beautiful.bg_gradient_button_alt)
			end
		end)

		tw:connect_signal("mouse::leave", function()
			if not t.selected then
				t_background:set_bg(beautiful.bg_gradient_button)
			end
		end)
	end

	taglist_widget.widget_template.update_callback = function(tw, t)
		t_callback(tw, t)
	end

	-- Wrap the taglist in a styled background container
	return wibox.widget({
		widget = wibox.container.background,
		bg = beautiful.bg_gradient_button,
		shape = beautiful.rrect(dpi(8)),
		{
			widget = wibox.container.margin,
			margins = dpi(4),
			{
				widget = taglist_widget,
			},
		},
	})
end
