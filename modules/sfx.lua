-- This Lua module contains simple functions for playing sounds at startup and notifications

local awful = require("awful") -- Import the 'awful' module
local gfs = require("gears.filesystem") -- Import the 'gears.filesystem' module

local M = {} -- Create a table to store the functions

--- Play a sound notification using pacat
function M.play()
  awful.spawn(
    "pacat --property=media.role=event "
      .. gfs.get_configuration_dir()
      .. "themes/assets/sounds/confirm1.wav"
  )
end

--- Play a startup sound notification using pacat
function M.startup()
  awful.spawn(
    "pacat --property=media.role=event "
      .. gfs.get_configuration_dir()
      .. "themes/assets/sounds/notify0.wav"
  )
end

return M -- Return the table containing the functions
