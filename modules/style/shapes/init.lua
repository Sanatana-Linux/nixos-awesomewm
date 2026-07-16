--- Shape factory library.
-- Pure-function module that returns shape closures for use in widget `shape`
-- properties. Every factory wraps the radius argument with `dpi()` so shapes
-- scale with the screen's X resources setting. No singleton, no signals.
-- @module modules.shapes

local beautiful = require("beautiful")
local gshape = require("gears.shape")
local dpi = beautiful.xresources.apply_dpi

local M = {}

--- Build a rounded-rectangle shape closure.
-- @tparam number rad Corner radius (DPI-scaled)
-- @treturn function Shape closure `(cr, w, h) -> nil`
function M.rrect(rad)
    return function(cr, w, h)
        gshape.rounded_rect(cr, w, h, dpi(rad))
    end
end

--- Rounded-bar shape (rounded only on the horizontal axis) closure.
-- @treturn function Shape closure `(cr, w, h) -> nil`
function M.rbar()
    return function(cr, w, h)
        gshape.rounded_bar(cr, w, h)
    end
end

--- Per-corner rounded-rectangle shape closure (different radius per corner).
-- @tparam number tl Top-left corner radius
-- @tparam number tr Top-right corner radius
-- @tparam number br Bottom-right corner radius
-- @tparam number bl Bottom-left corner radius
-- @tparam number rad Uniform corner radius (DPI-scaled)
-- @treturn function Shape closure `(cr, w, h) -> nil`
function M.prrect(tl, tr, br, bl, rad)
    return function(cr, w, h)
        gshape.partially_rounded_rect(cr, w, h, tl, tr, br, bl, dpi(rad))
    end
end

--- Circle shape closure (inscribed in the smaller of `w` and `h`).
-- @tparam number rad Circle radius (DPI-scaled)
-- @treturn function Shape closure `(cr, w, h) -> nil`
function M.circle(rad)
    return function(cr, w, h)
        gshape.circle(cr, w, h, dpi(rad))
    end
end

--- Squircle (rounded square with explicit straight-edge inset) shape closure.
-- @tparam number rad Corner radius (DPI-scaled)
-- @tparam[opt=5] number inset Pixel inset of the straight edge
-- @treturn function Shape closure `(cr, w, h) -> nil`
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
