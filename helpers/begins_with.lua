-- helpers/begins_with.lua

return function(str, pattern)
    return str:find("^" .. pattern) ~= nil
end
