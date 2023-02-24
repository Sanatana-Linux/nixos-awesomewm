---@diagnostic disable:undefined-global

local awful = require 'awful'

client.connect_signal('request::manage', function (c)
    if c.floating then 
    awful.placement.centered(c, {
        honor_workarea = true,
        honor_padding = true,
        margins = beautiful.useless_gap * 2,
        shape = utilities.mkroundedrect()
        })
    end
        
end)
