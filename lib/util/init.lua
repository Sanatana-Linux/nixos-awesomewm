--- Hand-rolled utility functions extracted from `lib/init.lua`.
-- These were previously attached directly to the `lib` table but are
-- now in their own module for a cleaner separation of vendored vs
-- hand-rolled code.
-- @module lib.util

local inspect = require("lib.inspect")

local util = {}

-- Utility function to create pango markup
--- Wrap a text string in a `<span>` with the given pango attribute set.
-- Only attributes present in `args` are emitted (so absent fields don't
-- pollute the output). Supports `font`, `size`, `style`, `weight`,
-- `stretch`, `font_scale`, `underline`, `overline`, `strikethrough`,
-- `alpha`, `fg`, `bg`.
-- @tparam string text The text to wrap
-- @tparam[opt] table args Pango attribute table
-- @treturn string `<span ...>text</span>`
function util.create_markup(text, args)
    args = args or {}
    local font = args.font and "font='" .. args.font .. "' " or ""
    local size = args.size and "size='" .. args.size .. "' " or ""
    local style = args.style and "style='" .. args.style .. "' " or ""
    local weight = args.weight and "weight='" .. args.weight .. "' " or ""
    local stretch = args.stretch and "stretch='" .. args.stretch .. "' " or ""
    local font_scale = args.font_scale
            and "font_scale='" .. args.font_scale .. "' "
        or ""
    local underline = args.underline and "underline='" .. args.underline .. "' "
        or ""
    local overline = args.overline and "overline='" .. args.overline .. "' "
        or ""
    local strikethrough = args.strikethrough
            and "strikethrough='" .. args.strikethrough .. "' "
        or ""
    local alpha = args.alpha and "alpha='" .. args.alpha .. "' " or ""
    local fg = args.fg and "foreground='" .. args.fg .. "' " or ""
    local bg = args.bg and "background='" .. args.bg .. "'" or ""
    return "<span "
        .. font
        .. size
        .. style
        .. weight
        .. stretch
        .. font_scale
        .. underline
        .. overline
        .. strikethrough
        .. alpha
        .. fg
        .. bg
        .. ">"
        .. text
        .. "</span>"
end

-- Escapes Lua's magic characters in a string
--- Escape Lua-pattern magic characters in `str` so it can be used as a
-- literal pattern with `string.match` / `string.gsub`. Escapes `[]().-+?*^$%`.
-- @tparam string str
-- @treturn string Pattern-safe version of `str`
function util.lua_escape(str)
    return str:gsub("[%[%]%(%)%.%-%+%?%*%^%$%%]", "%%%1")
end

-- Checks if two tables have any common values
--- Return the list of values that appear in both tables, or nil if none.
-- @tparam table t1
-- @tparam table t2
-- @treturn table|nil Common values, or nil if the intersection is empty
function util.has_common(t1, t2)
    local common = {}
    for _, v1 in pairs(t1) do
        for _, v2 in pairs(t2) do
            if v1 == v2 then
                table.insert(common, v1)
            end
        end
    end
    return #common > 0 and common or nil
end

-- Removes a value from an array-like table
--- In-place removal of all occurrences of `val` from a sequence table.
-- Mutates `tbl`. Uses `table.remove` so elements after the match shift down.
-- @tparam table tbl Sequence table (mutated)
-- @param val Value to remove
-- @treturn nil
function util.remove_nonindex(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            table.remove(tbl, i)
        end
    end
end

-- Checks if a file exists
--- @tparam string file
-- @treturn boolean true if `file` can be opened for reading
function util.file_exists(file)
    local f = io.open(file, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

-- Checks if a file extension is in a list of supported formats
--- Match a file path's extension against a list of `format` strings.
-- Anchored to the end of the path so "foo.png" matches `png` but
-- "foopng" does not.
-- @tparam string file Path to check
-- @tparam table formats Array of format names (e.g. `{"png", "jpg"}`)
-- @treturn boolean
function util.is_supported(file, formats)
    local supported = false
    for _, format in ipairs(formats) do
        if file:match("/.+%." .. format .. "$") then
            supported = true
            break
        end
    end
    return supported
end

-- Writes a Lua table to a file in a readable format
--- Serialize a Lua table to `file` as a valid `return <value>` Lua chunk.
-- Useful for persisting a table to disk and re-loading with `dofile`.
-- Silently no-ops on bad arguments.
-- @tparam table tbl The table to serialize
-- @tparam string file Absolute path to the output file
function util.table_to_file(tbl, file)
    if not file or not tbl then
        return
    end
    local inspected = assert(inspect(tbl, { indent = "\t" }))
    local wfile = assert(io.open(file, "w"))
    wfile:write("return " .. inspected)
    wfile:close()
end

--- DPI-aware scaling helper.
-- Lazy-requires `beautiful.xresources.apply_dpi` — safe to require
-- this module before `beautiful` is fully loaded.
-- @tparam integer|number x Pixel value at 96 DPI
-- @treturn integer Scaled pixel value for the current X screen
function util.dpi(x)
    return require("beautiful").xresources.apply_dpi(x)
end

--- Apply hex alpha (00..FF) to a color string.
-- The input must be exactly 6 hex digits (with or without leading `#`);
-- the resulting output is always 8 hex digits.
-- @tparam string color Hex color (`#RRGGBB` or `RRGGBB`)
-- @tparam string alpha Two-hex-digit alpha string ("00".."FF")
-- @treturn string Combined "#RRGGBBAA" color
function util.color_alpha(color, alpha)
    local base = color:gsub("^#", "")
    return "#" .. base .. alpha
end

--- Resolve a path under ~/.config/awesome through $HOME.
-- Avoids hardcoded paths in UI code.
-- @tparam string ... Relative path components
-- @treturn string Absolute path
function util.config_path(...)
    return (os.getenv("HOME") or "")
        .. "/.config/awesome/"
        .. table.concat({ ... }, "/")
end

--- Time a function call and log the milliseconds if over a threshold.
-- @tparam number threshold_ms Calls slower than this are logged (default 16ms)
-- @tparam function fn Function to time
-- @treturn function Wrapped function
-- @treturn number Last elapsed ms (for inspection)
function util.timed(threshold_ms, fn)
    threshold_ms = threshold_ms or 16
    local last_ms = 0
    return setmetatable({}, {
        __call = function(_, ...)
            local t0 = os.clock() * 1000
            local r = { fn(...) }
            local t1 = os.clock() * 1000
            last_ms = t1 - t0
            if last_ms >= threshold_ms then
                local info = debug.getinfo(fn, "Sl")
                print(
                    string.format(
                        "[lib.util.timed] %s:%d took %.2fms",
                        info.short_src or "?",
                        info.currentline or -1,
                        last_ms
                    )
                )
            end
            return unpack(r)
        end,
    }),
        function()
            return last_ms
        end
end

return util
