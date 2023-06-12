-- colorize a text using pango markup

local beautiful = require("beautiful")

local dpi = beautiful.xresources.apply_dpi
return function(content, fg)
    fg = fg or beautiful.lessgrey
    content = content or ""

    return '<span foreground="' .. fg .. '">' .. content .. "</span>"
end
