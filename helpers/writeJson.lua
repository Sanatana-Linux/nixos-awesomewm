-- helpers/writeJson.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi
local cairo = require("lgi").cairo
local gmatrix = require("gears.matrix")
local json = require("mods.json")
local wibox = require("wibox")

return function(PATH, DATA)
    local w = assert(io.open(PATH, "w"))
    w:write(json.encode(DATA, nil, {
        pretty = true,
        indent = "	",
        align_keys = false,
        array_newline = true,
    }))
    w:close()
end
