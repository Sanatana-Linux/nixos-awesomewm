-- helpers/rrect.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

return function(radius)
    radius = radius or dpi(4)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end
