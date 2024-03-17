local gears = require("gears")

local shape = {} -- Create a local table to store shape functions

-- Function to create a rounded rectangle shape
function shape.rounded_rect(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

-- Function to create a partially rounded rectangle shape
function shape.partially_rounded_rect(radius, tl, tr, br, bl)
    return function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, tl, tr, br, bl, radius)
    end
end

return shape -- Return the table containing shape functions