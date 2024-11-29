-- helpers/prect.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

return function(tl, tr, br, bl, radius)
    radius = radius or dpi(4)
    return function(cr, width, height)
        gears.shape.partially_rounded_rect(
            cr,
            width,
            height,
            tl,
            tr,
            br,
            bl,
            radius
        )
    end
end
