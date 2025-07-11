local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local modules = require("modules")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local adapter = require("service.bluetooth").get_default()

local function create_dev_widget(path)
	local dev = adapter:get_device(path)

	local dev_widget = wibox.widget {
		path = path,
		widget = wibox.container.background,
		forced_height = dpi(40),
		{
			layout = wibox.layout.fixed.vertical,
			{
				id = "header",
				widget = wibox.container.background,
				forced_height = dpi(40),
				shape = beautiful.rrect(dpi(10)),
				{
					widget = wibox.container.margin,
					margins = { left = dpi(15), right = dpi(15) },
					{
						layout = wibox.layout.align.horizontal,
						{
							widget = wibox.container.constraint,
							width = dpi(220),
							{
								id = "name",
								widget = wibox.widget.textbox
							}
						},
						nil,
						{
							widget = wibox.container.constraint,
							width = dpi(130),
							{
								id = "percentage",
								widget = wibox.widget.textbox
							}
						}
					}
				}
			},
			{
				id = "buttons",
				widget = wibox.container.background,
				forced_height = dpi(50),
				{
					widget = wibox.container.margin,
					margins = { top = dpi(5) },
					{
						layout = wibox.layout.flex.horizontal,
						spacing = dpi(5),
						{
							id = "connect-button",
							widget = modules.hover_button {
								margins = { left = dpi(15), right = dpi(15) },
								shape = beautiful.rrect(dpi(10))
							}
						},
						{
							id = "pair-button",
							widget = modules.hover_button {
								margins = { left = dpi(15), right = dpi(15) },
								shape = beautiful.rrect(dpi(10))
							}
						},
						{
							id = "trust-button",
							widget = modules.hover_button {
								margins = { left = dpi(15), right = dpi(15) },
								shape = beautiful.rrect(dpi(10))
							}
						}
					}
				}
			}
		}
	}

	local header = dev_widget:get_children_by_id("header")[1]
	header:connect_signal("mouse::enter", function(w)
		w:set_bg(beautiful.bg_urg)
	end)

	header:connect_signal("mouse::leave", function(w)
		w:set_bg(nil)
	end)

	local dev_buttons = dev_widget:get_children_by_id("buttons")

	local buttons_visible = false
	local function toggle_buttons()
		buttons_visible = not buttons_visible
		dev_widget:set_forced_height(buttons_visible and dpi(80) or dpi(40))
		dev_buttons.visible = buttons_visible
	end

	header:buttons {
		awful.button({}, 1, function()
			toggle_buttons()
		end)
	}

	local connect_button = dev_widget:get_children_by_id("connect-button")[1]
	connect_button:buttons {
		awful.button({}, 1, function()
			if not dev:get_connected() then
				dev:connect()
			else
				dev:disconnect()
			end
		end)
	}

	local pair_button = dev_widget:get_children_by_id("pair-button")[1]
	pair_button:buttons {
		awful.button({}, 1, function()
			if not dev:get_paired() then
				dev:pair()
			else
				dev:cancel_pairing()
			end
		end)
	}

	local trust_button = dev_widget:get_children_by_id("trust-button")[1]
	trust_button:buttons {
		awful.button({}, 1, function()
			dev:set_trusted(not dev:get_trusted())
		end)
	}

	local percentage = dev_widget:get_children_by_id("percentage")[1]
	dev:connect_signal("property::percentage", function(_, perc)
		percentage:set_markup(perc ~= nil and string.format("%.0f%%", perc) or "")
	end)

	local name = dev_widget:get_children_by_id("name")[1]
	dev:connect_signal("property::connected", function(_, cnd)
		name:set_markup((cnd and text_icons.check .. " " or "") .. (dev:get_name() or dev:get_address()))
		connect_button:set_label(cnd and "Disconnect" or "Connect")
	end)

	dev:connect_signal("property::paired", function(_, prd)
		pair_button:set_label(prd and "Unpair" or "Pair")
	end)

	dev:connect_signal("property::trusted", function(_, trd)
		trust_button:set_label(trd and "Untrust" or "Trust")
	end)

	name:set_markup((dev:get_connected() and text_icons.check .. " " or "") .. (dev:get_name() or dev:get_address()))
	percentage:set_markup(dev:get_percentage() and string.format("%.0f%%", dev:get_percentage()) or "")
	connect_button:set_label(dev:get_connected() and "Disconnect" or "Connect")
	pair_button:set_label(dev:get_paired() and "Unpair" or "Pair")
	trust_button:set_label(dev:get_trusted() and "Untrust" or "Trust")

	return dev_widget
end

local function on_device_added(self, path)
	local devs_layout = self:get_children_by_id("devices-layout")[1]
	local dev_widget = create_dev_widget(path)

	if #devs_layout.children == 1 and not devs_layout.children[1].path then
		devs_layout:reset()
	else
		for _, old_dev_widget in ipairs(devs_layout.children) do
			if old_dev_widget.path == path then
				devs_layout:remove_widgets(old_dev_widget)
			end
		end
	end
	devs_layout:add(dev_widget)
end

local function on_device_removed(self, path)
	local devs_layout = self:get_children_by_id("devices-layout")[1]
	for _, dev_widget in ipairs(devs_layout.children) do
		if dev_widget.path == path then
			devs_layout:remove_widgets(dev_widget)
		end
	end

	if #devs_layout.children == 0 then
		devs_layout:add(wibox.widget {
			widget = wibox.container.background,
			fg = beautiful.fg_alt,
			forced_height = dpi(400),
			{
				widget = wibox.widget.textbox,
				align = "center",
				font = beautiful.font_h2,
				markup = text_icons.wait
			}
		})
	end
end

local function on_discovering(self, discovering)
	local bottombar_discover_button = self:get_children_by_id("bottombar-discover-button")[1]
	bottombar_discover_button:set_fg_normal(discovering and beautiful.fg_alt or beautiful.fg)
	bottombar_discover_button:set_bg_hover(discovering and beautiful.fg_alt or beautiful.ac)
	bottombar_discover_button:set_fg(discovering and beautiful.fg_alt or beautiful.fg)
	bottombar_discover_button:set_bg(beautiful.bg_alt)
end

local function on_powered(self, powered)
	local devs_layout = self:get_children_by_id("devices-layout")[1]
	local bottombar_toggle_button = self:get_children_by_id("bottombar-toggle-button")[1]
	local bottombar_discover_button = self:get_children_by_id("bottombar-discover-button")[1]

	on_discovering(self, adapter:get_discovering())

	if powered then
		bottombar_toggle_button:set_label(text_icons.switch_on)
		devs_layout:reset()
		devs_layout:add(wibox.widget {
			widget = wibox.container.background,
			fg = beautiful.fg_alt,
			forced_height = dpi(400),
			{
				widget = wibox.widget.textbox,
				align = "center",
				font = beautiful.font_h2,
				markup = text_icons.wait
			}
		})

		for _, dev in pairs(adapter:get_devices()) do
			on_device_added(self, dev:get_path())
		end

		adapter:start_discovery()
	else
		bottombar_toggle_button:set_label(text_icons.switch_off)
		bottombar_discover_button:set_fg(beautiful.fg)
		bottombar_discover_button:set_bg(beautiful.bg_alt)
		devs_layout:reset()
		devs_layout:add(wibox.widget {
			widget = wibox.container.background,
			fg = beautiful.fg_alt,
			forced_height = dpi(400),
			{
				widget = wibox.widget.textbox,
				align = "center",
				font = beautiful.font_h2,
				markup = "Bluetooth disabled"
			}
		})
	end
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
					id = "devices-layout",
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
				shape = beautiful.rrect(dpi(10)),
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
								shape = beautiful.rrect(dpi(10))
							}
						},
						{
							id = "bottombar-discover-button",
							widget = modules.hover_button {
								label = text_icons.search,
								forced_width = dpi(50),
								forced_height = dpi(50),
								shape = beautiful.rrect(dpi(10))
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
							shape = beautiful.rrect(dpi(10))
						}
					}
				}
			}
		}
	}

	local bottombar_toggle_button = ret:get_children_by_id("bottombar-toggle-button")[1]
	bottombar_toggle_button:buttons {
		awful.button({}, 1, function()
			adapter:set_powered(not adapter:get_powered())
		end)
	}

	local bottombar_discover_button = ret:get_children_by_id("bottombar-discover-button")[1]
	bottombar_discover_button:buttons {
		awful.button({}, 1, function()
			if adapter:get_powered() then
				if adapter:get_discovering() then
					adapter:stop_discovery()
				else
					adapter:start_discovery()
				end
			end
		end)
	}

	adapter:connect_signal("device-added", function(_, path)
		on_device_added(ret, path)
	end)

	adapter:connect_signal("device-removed", function(_, path)
		on_device_removed(ret, path)
	end)

	adapter:connect_signal("property::discovering", function(_, dsc)
		on_discovering(ret, dsc)
	end)

	adapter:connect_signal("property::powered", function(_, powered)
		on_powered(ret, powered)
	end)

	on_powered(ret, adapter:get_powered())

	return ret
end

return setmetatable({
	new = new
}, {
	__call = new
})
