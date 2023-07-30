--    _____                            __
--   |     |_.---.-.--.--.-----.--.--.|  |_
--   |       |  _  |  |  |  _  |  |  ||   _|
--   |_______|___._|___  |_____|_____||____|
--                 |_____|
--   +---------------------------------------------------------------+
--    NOTE: need to use regular lua local require calls for the libraries here because this is called earlier than they are
--
local awful = require("awful")
local empathy = require("modules.layouts.empathy")
local stack = require("modules.layouts.stack")
local center = require("modules.layouts.center")
local thrizen = require("modules.layouts.thrizen")
local horizon = require("modules.layouts.horizon")
local equalarea = require("modules.layouts.equalarea")
local deck = require("modules.layouts.deck")
local cascade = require("modules.layouts.cascade")
local beautiful = require("beautiful")
local tag = tag
local dpi = beautiful.xresources.apply_dpi
-- ------------------------------------------------- --
-- NOTE: define the default layouts, including the custom ones called above. Order determines the order they are flipped through by keybinding and widgets
--
tag.connect_signal("request::default_layouts", function(s)
  awful.layout.append_default_layouts({
    stack,
    cascade,
    cascade.tile,
    empathy,
    center,
    thrizen,
    horizon,
    equalarea,
    deck,
    awful.layout.suit.max,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.spiral,
    awful.layout.suit.corner.ne,
    awful.layout.suit.fair,
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    --    awful.layout.suit.magnifier,
    --    awful.layout.suit.fair.horizontal,
    --    awful.layout.suit.tile.left,
    --    awful.layout.suit.tile.right,
    --    awful.layout.suit.tile.bottom,
    --  awful.layout.suit.tile.top,
    --  awful.layout.suit.fair.horizontal,
    --  awful.layout.suit.max.fullscreen,
    --  awful.layout.suit.corner.nw,
    --  awful.layout.suit.corner.sw,
    --  awful.layout.suit.corner.se,
  })
end)
