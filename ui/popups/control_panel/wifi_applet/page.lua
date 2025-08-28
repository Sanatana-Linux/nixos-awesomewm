local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local modules = require("modules")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local network = require("service.network")
local client = network.get_default()
local shapes = require('modules.shapes')

local wifi_page = {}

local function create_ap_widget(self, ap)
	local ap_ssid = ap:get_ssid()
	local ap_strength = ap:get_strength()
	local ap_is_active = ap == client.wireless:get_active_access_point()

	local ap_widget = wibox.widget {
		active = ap_is_active,
		widget = wibox.container.background,
		shape = shapes.rrect(10),
		{
			widget = wibox.container.margin,
			forced_height = dpi(50),
			margins = dpi(15),
			{
				layout = wibox.layout.align.horizontal,
				{
					widget = wibox.container.constraint,
					width = dpi(250),
					{
						id = "name",
						widget = wibox.widget.textbox
					}
				},
				nil,
				{
					id = "strength",
					widget = wibox.widget.textbox
				}
			}
		}
	}

	local name = ap_widget:get_children_by_id("name")[1]
	name:set_markup(ap_is_active and text_icons.check .. " " .. ap_ssid or ap_ssid)

	local strength = ap_widget:get_children_by_id("strength")[1]
	strength:set_markup(
		ap_strength > 70 and "▂▄▆█"
		or ap_strength > 45 and "▂▄▆"
		or ap_strength > 20 and "▂▄"
		or "▂"
	)

	ap_widget:connect_signal("mouse::enter", function(w)
		w:set_bg(beautiful.bg_urg)
	end)

	ap_widget:connect_signal("mouse::leave", function(w)
		w:set_bg(nil)
	end)

	ap_widget:buttons {
		awful.button({}, 1, function()
			self:open_ap_menu(ap)
		end)
	}

	return ap_widget
end

local function on_ap_list_changed(self)
	local wp = self._private
	local aps_layout = self:get_children_by_id("access-points-layout")[1]
	wp.ap_widgets = {}

	for _, ap in pairs(client.wireless:get_access_points()) do
		if ap:get_ssid() ~= nil then
			local ap_widget = create_ap_widget(self, ap)
			table.insert(wp.ap_widgets, ap_widget)
		end
	end

	if aps_layout.children[1] ~= wp.ap_menu and #wp.ap_widgets ~= 0 then
		aps_layout:reset()
		for _, ap_widget in ipairs(wp.ap_widgets) do
			if ap_widget.active then
				aps_layout:insert(1, ap_widget)
			else
				aps_layout:add(ap_widget)
			end
		end
	end
end

local function on_wireless_enabled(self, enabled)
	local wp = self._private
	local aps_layout = self:get_children_by_id("access-points-layout")[1]
	local bottombar_toggle_button = self:get_children_by_id("bottombar-toggle-button")[1]

	if enabled then
		bottombar_toggle_button:set_label(text_icons.switch_on)
		aps_layout:reset()
		aps_layout:add(wibox.widget {
			widget = wibox.container.background,
			fg = beautiful.fg_alt,
			forced_height = dpi(400),
			{
				widget = wibox.widget.textbox,
				align = "center",
				font = beautiful.font_name .. dpi(12),
				markup = text_icons.wait
			}
		})
	else
		wp.ap_widgets = {}
		bottombar_toggle_button:set_label(text_icons.switch_off)
		aps_layout:reset()
		aps_layout:add(wibox.widget {
			widget = wibox.container.background,
			fg = beautiful.fg_alt,
			forced_height = dpi(400),
			{
				widget = wibox.widget.textbox,
				align = "center",
				font = beautiful.font_name .. dpi(12),
				markup = "Wifi Disabled"
			}
		})
		wp.ap_menu:get_children_by_id("password-input")[1]:unfocus()
	end
end

function wifi_page:open_ap_menu(ap)
	local wp = self._private
	local aps_layout = self:get_children_by_id("access-points-layout")[1]

	local obscure = true
	local auto_connect = true

	local close_button = wp.ap_menu:get_children_by_id("close-button")[1]
	close_button:buttons {
		awful.button({}, 1, function()
			self:close_ap_menu()
		end)
	}

	local title = wp.ap_menu:get_children_by_id("title")[1]
	title:set_markup(ap:get_ssid())

	local password_widget = wp.ap_menu:get_children_by_id("password-widget")[1]
	local password_input = wp.ap_menu:get_children_by_id("password-input")[1]
	local connect_disconnect_button = wp.ap_menu:get_children_by_id("connect-disconnect-button")[1]

	if ap ~= client.wireless:get_active_access_point() then
		local obscure_icon = wp.ap_menu:get_children_by_id("obscure-icon")[1]
		obscure_icon:set_markup(text_icons.eye_off)
		obscure_icon:buttons {
			awful.button({}, 1, function()
				obscure = not obscure
				password_input:set_obscure(obscure)
				if obscure then
					obscure_icon:set_markup(text_icons.eye_off)
				else
					obscure_icon:set_markup(text_icons.eye_on)
				end
			end)
		}

		local auto_connect_icon = wp.ap_menu:get_children_by_id("auto-connect-icon")[1]
		auto_connect_icon:set_markup(text_icons.check_on)
		auto_connect_icon:buttons {
			awful.button({}, 1, function()
				auto_connect = not auto_connect
				if auto_connect then
					auto_connect_icon:set_markup(text_icons.check_on)
				else
					auto_connect_icon:set_markup(text_icons.check_off)
				end
			end)
		}

		connect_disconnect_button:set_label("Connect")
		connect_disconnect_button:buttons {
			awful.button({}, 1, function()
				client:connect_access_point(ap, password_input:get_input(), auto_connect)
				self:close_ap_menu()
			end)
		}

		password_input:on_focused(function()
			password_input:set_input("")
			password_input:set_cursor_index(1)
		end)

		password_input:on_unfocused(function()
			self:close_ap_menu()
		end)

		password_input:on_executed(function(_, input)
			client:connect_access_point(ap, input, auto_connect)
			self:close_ap_menu()
		end)

		password_widget.visible = true
		password_input:focus()
	else
		connect_disconnect_button:set_label("Disconnect")
		connect_disconnect_button:buttons {
			awful.button({}, 1, function()
				client:disconnect_active_access_point()
				self:close_ap_menu()
				client.wireless:request_scan()
			end)
		}
		password_widget.visible = false
	end

	aps_layout:reset()
	aps_layout:add(wp.ap_menu)
end

function wifi_page:close_ap_menu()
	local wp = self._private
	local aps_layout = self:get_children_by_id("access-points-layout")[1]
	local password_input = wp.ap_menu:get_children_by_id("password-input")[1]

	if client:get_wireless_enabled() then
		password_input:unfocus()
		password_input:set_obscure(true)
		aps_layout:reset()
		for _, ap_widget in ipairs(wp.ap_widgets) do
			if ap_widget.active then
				aps_layout:insert(1, ap_widget)
			else
				aps_layout:add(ap_widget)
			end
		end
	end
end

function wifi_page:refresh()
	on_ap_list_changed(self)
	client.wireless:request_scan()
end

local function new()
	local ret = wibox.widget {
		widget = wibox.container.background,
		{
			layout = wibox.layout.fixed.vertical,
			spacing = dpi(8),
			{
				widget = wibox.container.background,
				forced_height = dpi(400),
				forced_width = dpi(400),
				{
					id = "access-points-layout",
					layout = wibox.layout.overflow.vertical,
					scrollbar_enabled = false,
					step = 40,
					spacing = dpi(3)
				}
			},
			{
				widget = wibox.container.background,
				forced_height = dpi(50),
				bg = beautiful.bg_alt,
				shape = shapes.rrect(10),
				{
					layout = wibox.layout.align.horizontal,
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.separator_thickness + dpi(2),
						spacing_widget = {
							widget = wibox.container.margin,
							margins = { top = dpi(12), bottom = dpi(12) },
							{
								widget = wibox.widget.separator,
								orientation = "vertical"
							}
						},
						{
							id = "bottombar-toggle-button",
							widget = modules.hover_button {
								forced_width = dpi(50),
								forced_height = dpi(50),
								shape = shapes.rrect(10)
							}
						},
						{
							id = "bottombar-refresh-button",
							widget = modules.hover_button {
								label = text_icons.reboot,
								forced_width = dpi(50),
								forced_height = dpi(50),
								shape = shapes.rrect(10)
							}
						}
					},
					nil,
					{
						id = "bottombar-close-button",
						widget = modules.hover_button {
							label = text_icons.arrow_left,
							forced_width = dpi(50),
							forced_height = dpi(50),
							shape = shapes.rrect(10)
						}
					}
				}
			}
		}
	}

	gtable.crush(ret, wifi_page, true)
	local wp = ret._private

	wp.ap_widgets = {}

	wp.ap_menu = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		forced_height = dpi(400),
		{
			widget = wibox.container.margin,
			margins = dpi(15),
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(15),
				{
					id = "close-button",
					widget = wibox.widget.textbox,
					markup = text_icons.arrow_left
				},
				{
					id = "title",
					widget = wibox.widget.textbox
				}
			}
		},
		{
			layout = wibox.layout.fixed.vertical,
			spacing = dpi(15),
			{
				id = "password-widget",
				widget = wibox.container.background,
				bg = beautiful.bg_alt,
				shape = shapes.rrect(10),
				{
					widget = wibox.container.margin,
					margins = dpi(15),
					{
						layout = wibox.layout.fixed.vertical,
						spacing = dpi(10),
						{
							widget = wibox.container.margin,
							margins = { left = dpi(10), right = dpi(10) },
							{
								layout = wibox.layout.align.horizontal,
								{
									widget = wibox.container.constraint,
									forced_width = dpi(310),
									strategy = "max",
									height = dpi(25),
									{
										id = "password-input",
										widget = modules.text_input {
											placeholder = "Password",
											cursor_bg = beautiful.fg,
											cursor_fg = beautiful.bg,
											placeholder_fg = beautiful.fg_alt,
											obscure = true
										}
									}
								},
								nil,
								{
									id = "obscure-icon",
									widget = wibox.widget.textbox
								}
							}
						},
						{
							widget = wibox.container.background,
							forced_width = 1,
							forced_height = beautiful.separator_thickness,
							{
								widget = wibox.widget.separator,
								orientation = "horizontal"
							}
						},
						{
							widget = wibox.container.margin,
							margins = { left = dpi(10), right = dpi(10) },
							{
								layout = wibox.layout.align.horizontal,
								{
									widget = wibox.widget.textbox,
									markup = "Auto connect"
								},
								nil,
								{
									id = "auto-connect-icon",
									widget = wibox.widget.textbox
								}
							}
						}
					}
				}
			},
			{
				id = "connect-disconnect-button",
				widget = modules.hover_button {
					margins = dpi(10),
					shape = shapes.rrect(10)
				}
			}
		}
	}

	local bottombar_toggle_button = ret:get_children_by_id("bottombar-toggle-button")[1]
	bottombar_toggle_button:buttons {
		awful.button({}, 1, function()
			client:set_wireless_enabled(not client:get_wireless_enabled())
		end)
	}

	local bottombar_refresh_button = ret:get_children_by_id("bottombar-refresh-button")[1]
	bottombar_refresh_button:buttons {
		awful.button({}, 1, function()
			if client:get_wireless_enabled() then
				ret:refresh()
			end
		end)
	}

	client.wireless:connect_signal("property::access-points", function()
		on_ap_list_changed(ret)
	end)

	client.wireless:connect_signal("property::state", function(_, state)
		if state == network.DeviceState.ACTIVATED
		or state == network.DeviceState.DISCONNECTED then
			on_ap_list_changed(ret)
		end
	end)

	client:connect_signal("property::wireless-enabled", function(_, enabled)
		on_wireless_enabled(ret, enabled)
	end)

	on_wireless_enabled(ret, client:get_wireless_enabled())

	if client.wireless:get_state() == network.DeviceState.ACTIVATED
	or client.wireless:get_state() == network.DeviceState.DISCONNECTED then
		on_ap_list_changed(ret)
	end

	return ret
end

return setmetatable({
	new = new
}, {
	__call = new
})