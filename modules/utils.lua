-- modules/utils.lua
-- Shared utility functions for the custom layouts (grid, map, navigator, common).
-- Provides match_grabber, client geometry, cairo helpers, and navigator service.

local awful = require("awful")
local gcolor = require("gears.color")
local math = math

local M = {}

-- Ignored modifier keys for match_grabber
local ignored_mod = { "Unknown", "Mod2" }

-- Key matching for keygrabbers
function M.match_grabber(rawkey, mod, _key)
    for i, m in ipairs(mod) do
        if awful.util.table.hasitem(ignored_mod, m) then
            table.remove(mod, i)
            break
        end
    end
    local modcheck = #mod == #rawkey[1]
    for _, v in ipairs(mod) do
        modcheck = modcheck and awful.util.table.hasitem(rawkey[1], v)
    end
    return modcheck and _key:lower() == rawkey[2]:lower()
end

-- Client geometry with border-width correction
local function size_correction(c, geometry, is_restore)
    local sign = is_restore and -1 or 1
    local bg = sign * 2 * c.border_width
    if geometry.width  then geometry.width  = geometry.width  - bg end
    if geometry.height then geometry.height = geometry.height - bg end
end

function M.fullgeometry(c, g)
    local ng
    if g then
        if g.width  and g.width  <= 1 then return ng end
        if g.height and g.height <= 1 then return ng end
        size_correction(c, g, false)
        ng = c:geometry(g)
    else
        ng = c:geometry()
    end
    size_correction(c, ng, true)
    return ng
end

function M.client_swap(c1, c2)
    if c1 and c2 and c1.valid and c2.valid then
        c1:swap(c2)
    end
end

-- Table utilities
function M.table_merge(t1, t2)
    local ret = awful.util.table.clone(t1)
    for k, v in pairs(t2) do
        if type(v) == "table" and ret[k] and type(ret[k]) == "table" then
            ret[k] = M.table_merge(ret[k], v)
        else
            ret[k] = v
        end
    end
    return ret
end

function M.table_check(t, s)
    local v = t
    for key in string.gmatch(s, "([^%.]+)(%.?)") do
        if v[key] then
            v = v[key]
        else
            return nil
        end
    end
    return v
end

-- Cairo text rendering
function M.cairo_set_font(cr, style)
    cr:select_font_face(style.font or "Sans", style.slant or 0, style.face or 1)
    cr:set_font_size(style.size or 22)
end

function M.cairo_textcentre(cr, pos, text)
    local extents = cr:text_extents(text or "")
    local x = pos[1] - extents.width / 2 - extents.x_bearing
    local y = pos[2] - extents.height / 2 - extents.y_bearing
    cr:move_to(x, y)
    cr:show_text(text or "")
end

-- Navigator service (lazy-loaded to avoid circular dep with modules.layouts)
M.service = {}
M.service.navigator = nil
local nav_loaded = false

function M.get_navigator()
    if not nav_loaded then
        M.service.navigator = require("modules.layouts.navigator")
        nav_loaded = true
    end
    return M.service.navigator
end

return M
