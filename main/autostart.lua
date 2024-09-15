local awful = require("awful")

-- Compositor
awful.spawn.with_shell("picom --config $HOME/.config/picom/picom.conf &")
-- Global theming 
awful.spawn.with_shell("xrdb -merge ~/.Xresources &")
-- Screen Lock
awful.spawn.with_shell("xss-lock lock &")
-- Make sure cache file is a-ok
awful.spawn.with_shell("mkdir -p ~/.cache/awesome/json")

