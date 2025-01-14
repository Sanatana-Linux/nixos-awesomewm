-- helpers/click_key.lua
local awful = require("awful")

return function(c, key)
    awful.spawn.with_shell(
        "xdotool type --window " .. tostring(c.window) .. " '" .. key .. "'"
    )
end
