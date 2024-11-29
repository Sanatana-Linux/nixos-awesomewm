-- helpers/beginsWith.lua

return function(str, pattern)
    return str:find("^" .. pattern) ~= nil
end
