-- Load modules for their side-effects first

-- Initialize the library table
local lib = {}

-- Attach other libraries to the 'lib' table for a unified interface
lib.inspect = require("lib.inspect")
lib.json = require("lib.json")
lib.dbus_proxy = require("lib.dbus_proxy")

-- Utility function to create pango markup
function lib.create_markup(text, args)
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
function lib.lua_escape(str)
    return str:gsub("[%[%]%(%)%.%-%+%?%*%^%$%%]", "%%%1")
end

-- Checks if two tables have any common values
function lib.has_common(t1, t2)
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
function lib.remove_nonindex(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            table.remove(tbl, i)
        end
    end
end

-- Checks if a file exists
function lib.file_exists(file)
    local f = io.open(file, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

-- Checks if a file extension is in a list of supported formats
function lib.is_supported(file, formats)
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
function lib.table_to_file(tbl, file)
    if not file or not tbl then
        return
    end
    local inspected = assert(lib.inspect(tbl, { indent = "\t" }))
    local wfile = assert(io.open(file, "w"))
    wfile:write("return " .. inspected)
    wfile:close()
end

return lib

