---@diagnostic disable: undefined-global
local wibox = require 'wibox'
local beautiful = require 'beautiful'
local gfs = require 'gears.filesystem'
local awful = require 'awful'

require "signal.network"

local network = wibox.widget {
    widget = wibox.widget.imagebox,
   image = icons.wifi_3,
    align = 'center',
}

local tooltip = utilities.make_popup_tooltip('Press to toggle network', function (d)
    return awful.placement.bottom_right(d, {
        margins = {
            bottom = beautiful.bar_height + beautiful.useless_gap * 2,
            right = beautiful.useless_gap * 2 + 85,
        }
    })
end)

tooltip.attach_to_object(network)

network:add_button(awful.button({}, 1, function ()
    nc_toggle()
    awesome.emit_signal('network::networks:refreshPanel')
end))

awesome.connect_signal('network::connected', function ()
    network.image = icons.wifi_3
end)

awesome.connect_signal('network::disconnected', function()
network.image=icons.wifi_off
end)

return network
