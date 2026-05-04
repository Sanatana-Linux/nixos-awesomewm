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

function M.squircle(rad, inset)
    inset = inset or 5
    return function(cr, w, h)
        local r = dpi(rad)
        local i = dpi(inset)
        local ri = math.max(r - i, 0)
        cr:move_to(i + ri, 0)
        cr:line_to(w - i - ri, 0)
        cr:arc(w - i - ri, ri, ri, -math.pi / 2, 0)
        cr:line_to(w - i, h - i - ri)
        cr:arc(w - i - ri, h - i - ri, ri, 0, math.pi / 2)
        cr:line_to(i + ri, h - i)
        cr:arc(i + ri, h - i - ri, ri, math.pi / 2, math.pi)
        cr:line_to(i, i + ri)
        cr:arc(i + ri, ri, ri, math.pi, 3 * math.pi / 2)
        cr:close_path()
    end
end

return M
