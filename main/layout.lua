local awful = require("awful")
local center = require("misc.layouts.center")
local thrizen = require("misc.layouts.thrizen")
local horizon = require("misc.layouts.horizon")
local equalarea = require("misc.layouts.equalarea")
local deck = require("misc.layouts.deck")
local mstab = require("misc.layouts.mstab")
local treetile = require("misc.layouts.treetile")

local cascade = require("misc.layouts.cascade")
local beautiful = require("beautiful")
local tag = tag

tag.connect_signal("request::default_layouts", function(s)
    awful.layout.append_default_layouts({

        mstab,
        treetile,
        cascade.tile,
        deck, -- while similar to cascade, this one has different padding and margin settings that nakes having both useful to a variable degree
        cascade,
        center,
        thrizen,
        horizon,
        equalarea,
        --	awful.layout.suit.max,
        -- awful.layout.suit.spiral.dwindle,
        -- awful.layout.suit.spiral,
        -- awful.layout.suit.corner.ne,
        -- awful.layout.suit.fair,
        -- awful.layout.suit.tile,
        awful.layout.suit.floating,
        --  awful.layout.suit.magnifier,
        --  awful.layout.suit.fair.horizontal,
        --  awful.layout.suit.tile.left,
        --  awful.layout.suit.tile.right,
        --  awful.layout.suit.tile.bottom,
        --  awful.layout.suit.tile.top,
        --  awful.layout.suit.fair.horizontal,
        --  awful.layout.suit.max.fullscreen,
        --  awful.layout.suit.corner.nw,
        --  awful.layout.suit.corner.sw,
        --  awful.layout.suit.corner.se,
    })
end)

client.connect_signal("mouse::enter", function(c)
    c:activate({ context = "mouse_enter", raise = false })
end)

client.connect_signal("manage", function(c)
    if awesome.startup then
        awful.client.setslave(c)

    end
end)
