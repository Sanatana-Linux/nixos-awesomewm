local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")

local theme = modules.icon_theme(beautiful.icon_theme)

local extract_icon = function(c)
	-- exceptions (add support for simple terminal and many mores).
	if c.class then
		if string.lower(c.class) == "st" then
			return theme:get_icon_path(string.lower(c.class))
		end
	end

	-- has support for some others apps like spotify
	return theme:get_client_icon_path(c)
end

local mktag = function(tag)
	local content_layout = wibox.layout.fixed.horizontal()

	content_layout:add(wibox.widget({
		markup = tostring(tag.name),
		widget = wibox.widget.textbox,
		font = beautiful.title_font,
	}))

	local clients_layout = wibox.layout.fixed.horizontal()
	local margin_widget = wibox.container.margin()

	clients_layout.spacing = 6
	margin_widget.left = 0

	content_layout:add(margin_widget)
	content_layout:add(clients_layout)

	local update_clients = function()
		clients_layout:reset()
		margin_widget.left = 0

		if #tag:clients() > 0 then
			margin_widget.left = dpi(9)
			for _, c in ipairs(tag:clients()) do
				clients_layout:add(wibox.widget({
					image = c.icon or extract_icon(c),
					valign = "center",
					forced_height = dpi(16),
					forced_width = dpi(16),
					widget = wibox.widget.imagebox,
				}))
			end
		end
	end

	update_clients()

	client.connect_signal("request::manage", update_clients)
	client.connect_signal("request::unmanage", update_clients)
	client.connect_signal("tagged", update_clients)
	client.connect_signal("untagged", update_clients)

	local container = wibox.widget({
		{
			content_layout,
			top = dpi(3),
			bottom = dpi(3),
			left = dpi(8),
			right = dpi(8),
			widget = wibox.container.margin,
		},
		bg = beautiful.widget_back,
		shape = utilities.widgets.mkroundedrect(),
		border_color = beautiful.grey .. "cc",
		border_width = dpi(2),
		widget = wibox.container.background,
	})

	container:add_button(awful.button({}, 1, function()
		tag:view_only()
	end))

	utilities.visual.add_hover(container, beautiful.widget_back_tag, beautiful.widget_back_focus_tag)

	-- local active_transition = utilities.visual.apply_transition {
	--   element = container,
	--   prop = 'bg',
	--   bg = scheme.colorE,
	--   hbg = scheme.colorM
	-- }

	local update_tag_status = function()
		if tag.selected then
			container.bg = beautiful.widget_back_focus
		else
			container.bg = beautiful.widget_back_tag
		end
	end

	update_tag_status()

	tag:connect_signal("property::selected", update_tag_status)

	return container
end

return function(s)
	local layout = wibox.layout.fixed.horizontal()

	layout.spacing = dpi(9)

	for _, tag in ipairs(s.tags) do
		layout:add(mktag(tag))
	end

	return layout
end
