-- @param input - text to be trimmed of whitespace
-- @return input without whitespace
return function(input)
    local result = input:gsub("%s+", "")
    return string.gsub(result, "%s+", "")
end
