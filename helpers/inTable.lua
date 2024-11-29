-- helpers/inTable.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

return function(t, v)
    for _, value in ipairs(t) do
        if value == v then
            return true
        end
    end

    return false
end
