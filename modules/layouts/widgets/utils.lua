--- Layout helper utilities.
-- Pure-function module used by `modules.layouts.grid`, `.map`, and
-- `widgets.navigator`. Exposes key-grabber matching, client geometry helpers,
-- table-merge helpers, cairo drawing helpers, and a lazy navigator loader
-- (broken out into its own function to avoid a circular require between
-- this module and `modules.layouts.widgets.navigator`).
-- @module modules.layouts.widgets.utils

-- modules/layouts/widgets/utils.lua
-- Shared utility functions for the custom layouts (grid, map, navigator, common).
-- Provides match_grabber, client geometry, cairo helpers, and navigator service.

local awful = require("awful")
local gcolor = require("gears.color")
local gtable = require("gears.table")
local math = math

local M = {}

-- Ignored modifier keys for match_grabber
local ignored_mod = { "Unknown", "Mod2" }

--- Test if a key event matches a keygrabber binding entry.
-- Mutates `mod` in place to strip the noise modifiers (`Unknown`, `Mod2`).
-- @tparam table rawkey `{{mod1, mod2, ...}, "key", ...}` as in `awful.key`
-- @tparam table mod Modifiers present in the event
-- @tparam string _key Key present in the event (case-insensitive)
-- @treturn boolean
function M.match_grabber(rawkey, mod, _key)
    for i, m in ipairs(mod) do
        if gtable.hasitem(ignored_mod, m) then
            table.remove(mod, i)
            break
        end
    end
    local modcheck = #mod == #rawkey[1]
    for _, v in ipairs(mod) do
        modcheck = modcheck and gtable.hasitem(rawkey[1], v)
    end
    return modcheck and _key:lower() == rawkey[2]:lower()
end

--- Client geometry with border-width correction.
-- Adjusts width/height to account for `c.border_width` (subtracts when
-- setting geometry, adds back when reading).
-- @tparam client c The client
-- @tparam table geometry Geometry table with optional `.width`, `.height`
-- @tparam[opt] boolean is_restore If true, *adds* border (restoring raw geometry)
-- @local
local function size_correction(c, geometry, is_restore)
    local sign = is_restore and -1 or 1
    local bg = sign * 2 * c.border_width
    if geometry.width then
        geometry.width = geometry.width - bg
    end
    if geometry.height then
        geometry.height = geometry.height - bg
    end
end

--- Set or get client geometry with border-width compensation.
-- When setting (g provided): subtracts 2×border_width from width/height.
-- When getting (nil g): returns geometry with border_width added back.
-- @tparam client c The client
-- @tparam[opt] table g Geometry to set (or nil to read)
-- @treturn[1] nil If an invalid geometry was passed
-- @treturn[2] table The effective geometry (with border accounted for)
function M.fullgeometry(c, g)
    local ng
    if g then
        if g.width and g.width <= 1 then
            return ng
        end
        if g.height and g.height <= 1 then
            return ng
        end
        size_correction(c, g, false)
        ng = c:geometry(g)
    else
        ng = c:geometry()
    end
    size_correction(c, ng, true)
    return ng
end

--- Swap two clients if both are valid.
-- @tparam client c1
-- @tparam client c2
function M.client_swap(c1, c2)
    if c1 and c2 and c1.valid and c2.valid then
        c1:swap(c2)
    end
end

--- Recursively merge `t2` into a clone of `t1`. Nested tables are deep-merged;
-- scalar values in `t2` overwrite `t1`. `t1` is not mutated.
-- @tparam table t1
-- @tparam table t2
-- @treturn table New merged table
function M.table_merge(t1, t2)
    local ret = gtable.clone(t1)
    for k, v in pairs(t2) do
        if type(v) == "table" and ret[k] and type(ret[k]) == "table" then
            ret[k] = M.table_merge(ret[k], v)
        else
            ret[k] = v
        end
    end
    return ret
end

--- Walk a dotted path on a table and return the value at the leaf.
-- @tparam table t
-- @tparam string s Dotted path (e.g. `"service.navigator"`)
-- @treturn any|nil The value, or nil if any segment is missing
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

--- Set a Cairo font face, slant, and size on a context.
-- @tparam cairo.Context cr
-- @tparam table style Table with `.font`, `.slant`, `.face`, and `.size` keys
function M.cairo_set_font(cr, style)
    cr:select_font_face(style.font or "Sans", style.slant or 0, style.face or 1)
    cr:set_font_size(style.size or 22)
end

--- Draw centred text at a position on a Cairo context.
-- @tparam cairo.Context cr
-- @tparam table pos `{x, y}` position for the text
-- @tparam string text The text to render
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

--- Lazily load and return the navigator service module.
-- Avoids circular dependency with `modules.layouts` during startup.
-- @treturn table The navigator module (`modules.layouts.widgets.navigator`)
function M.get_navigator()
    if not nav_loaded then
        M.service.navigator = require("modules.layouts.widgets.navigator")
        nav_loaded = true
    end
    return M.service.navigator
end

return M
