local awful = require("awful")
local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local M = {}

local function spawn(cmd)
    awful.spawn.easy_async(cmd, function() end)
end

function M.play()
    awful.spawn(
        "pacat --property=media.role=event "
            .. gfs.get_configuration_dir()
            .. "themes/assets/sounds/notify2.wav"
    )
end

function M.startup()
    awful.spawn(
        "pacat --property=media.role=event "
            .. gfs.get_configuration_dir()
            .. "themes/assets/sounds/startup.wav"
    )
end

return M
