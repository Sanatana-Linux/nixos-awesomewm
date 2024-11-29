-- helpers/color_lighten.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

return function(color, amount)
    amount = amount or 26
    local c = {
        r = tonumber("0x" .. color:sub(2, 3)),
        g = tonumber("0x" .. color:sub(4, 5)),
        b = tonumber("0x" .. color:sub(6, 7)),
    }

    c.r = c.r + amount
    c.r = c.r < 0 and 0 or c.r
    c.r = c.r > 255 and 255 or c.r
    c.g = c.g + amount
    c.g = c.g < 0 and 0 or c.g
    c.g = c.g > 255 and 255 or c.g
    c.b = c.b + amount
    c.b = c.b < 0 and 0 or c.b
    c.b = c.b > 255 and 255 or c.b

    return string.format("#%02x%02x%02x", c.r, c.g, c.b)
end
