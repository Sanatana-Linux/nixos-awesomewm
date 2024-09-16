local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")

return function(tl, tr, br, bl, radius)
    radius = radius or dpi(4)
    return function(cr, width, height)
        gears.shape.partially_rounded_rect(
            cr,
            width,
            height,
            tl,
            tr,
            br,
            bl,
            radius
        )
    end
end
