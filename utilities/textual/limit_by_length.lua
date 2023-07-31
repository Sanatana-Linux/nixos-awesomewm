-- @param str string
-- @param max_length number - maximum length of string
-- @param use_pango bool

local beautiful = require("beautiful")
local get_colorized_markup = require("utilities.textual.get_colorized_markup")
-- limit a string by a length and put ... at the final if the
-- `max_length` is exceded `str`
return function(str, max_length, use_pango)
    local sufix = ""
    local toput = "..."

    if #str > max_length - #toput then
        str = string.sub(str, 1, max_length - 3)
        sufix = toput
    end

    if use_pango and sufix == toput then
        sufix = get_colorized_markup(sufix, beautiful.light_black)
    end

    return str .. sufix
end
