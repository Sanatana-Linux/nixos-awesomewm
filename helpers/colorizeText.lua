-- helpers/colorizeText.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

return function(txt, fg)
    if fg == "" then
        fg = "#ffffff"
    end

    return "<span foreground='" .. fg .. "'>" .. txt .. "</span>"
end
