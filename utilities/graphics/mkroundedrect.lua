local gears = require("gears")

local beautiful = require("beautiful")

local dpi = beautiful.xresources.apply_dpi

-- create a rounded rect using a custom radius
return function(radius)
    radius = radius or dpi(7)
    return function(cr, w, h)
        return gears.shape.rounded_rect(cr, w, h, radius)
    end
end
