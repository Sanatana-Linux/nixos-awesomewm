-- helpers/random_color.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

return function()
    local accents = {
        beautiful.magenta,
        beautiful.yellow,
        beautiful.green,
        beautiful.red,
        beautiful.blue,
    }

    local i = math.random(1, #accents)
    return accents[i]
end
