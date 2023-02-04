--  _____                            __
-- |     |_.---.-.--.--.-----.--.--.|  |_
-- |       |  _  |  |  |  _  |  |  ||   _|
-- |_______|___._|___  |_____|_____||____|
--               |_____|
-- ------------------------------------------------- --
-- NOTE: need to use regular lua local require calls for the libraries here
-- because this is called earlier than they are
--
local awful = require('awful')
local empathy = require('configuration.layout.layouts.empathy')
local stack = require('configuration.layout.layouts.stack')
local centermaster = require('configuration.layout.layouts.centermaster')
local thrizen = require('configuration.layout.layouts.thrizen')
local horizon = require('configuration.layout.layouts.horizon')
local equalarea = require('configuration.layout.layouts.equalarea')
local deck = require('configuration.layout.layouts.deck')
local beautiful = require('beautiful')
local tag = tag
local dpi = beautiful.xresources.apply_dpi
-- ------------------------------------------------- --
-- NOTE: define the default layouts, incliding the custom ones called above
--
tag.connect_signal(
    'request::default_layouts',
    function(s)
        awful.layout.append_default_layouts(
            {
                stack,
                empathy,
                centermaster,
                thrizen,
                horizon,
                equalarea,
                deck,
                awful.layout.suit.max,
                awful.layout.suit.spiral.dwindle,
                awful.layout.suit.corner.ne,
                awful.layout.suit.fair,
                awful.layout.suit.tile,
                awful.layout.suit.floating
                --awful.layout.suit.magnifier,
                --awful.layout.suit.fair.horizontal
                --awful.layout.suit.tile.left,
                --awful.layout.suit.tile.bottom,
                --awful.layout.suit.tile.top,
                --awful.layout.suit.fair.horizontal,
                --awful.layout.suit.max.fullscreen,
                --awful.layout.suit.corner.nw
                --awful.layout.suit.corner.sw,
                --awful.layout.suit.corner.se,
            }
        )
    end
)

