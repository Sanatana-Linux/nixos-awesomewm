-- helpers/readJson.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

return function(DATA)
    if helpers.file_exists(DATA) then
        local f = assert(io.open(DATA, "rb"))
        local lines = f:read("*all")
        f:close()
        local data = json.decode(lines)
        return data
    else
        return {}
    end
end
