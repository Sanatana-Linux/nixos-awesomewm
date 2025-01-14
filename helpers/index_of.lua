-- helpers/index_of.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

return function(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end
