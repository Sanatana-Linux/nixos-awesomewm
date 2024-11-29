-- helpers/placeWidget.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

return function(widget)
    if beautiful.barDir == "left" then
        awful.placement.bottom_left(
            widget,
            { honor_workarea = true, margins = beautiful.useless_gap * 2 }
        )
    elseif beautiful.barDir == "right" then
        awful.placement.bottom_right(
            widget,
            { honor_workarea = true, margins = beautiful.useless_gap * 2 }
        )
    elseif beautiful.barDir == "bottom" then
        awful.placement.bottom(
            widget,
            { honor_workarea = true, margins = beautiful.useless_gap * 2 }
        )
    elseif beautiful.barDir == "top" then
        awful.placement.top(
            widget,
            { honor_workarea = true, margins = beautiful.useless_gap * 2 }
        )
    end
end
