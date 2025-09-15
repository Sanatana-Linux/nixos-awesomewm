local beautiful = require("beautiful")
local gshape = require("gears.shape")
local dpi = beautiful.xresources.apply_dpi

local M = {}

function M.rrect(rad)
    return function(cr, w, h)
        gshape.rounded_rect(cr, w, h, dpi(rad))
    end
end

function M.rbar()
    return function(cr, w, h)
        gshape.rounded_bar(cr, w, h)
    end
end

function M.prrect(tl, tr, br, bl, rad)
    return function(cr, w, h)
        gshape.partially_rounded_rect(cr, w, h, tl, tr, br, bl, dpi(rad))
    end
end

function M.circle(rad)
    return function(cr, w, h)
        gshape.circle(cr, w, h, dpi(rad))
    end
end

return M
