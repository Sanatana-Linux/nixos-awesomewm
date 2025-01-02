---@diagnostic disable: different-requires
-- helpers/color_darken.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

return function(color, amount)
    amount = amount or 26
    return helpers.color_lighten(color, -amount)
end
