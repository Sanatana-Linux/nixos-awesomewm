-- helpers/add_tables.lua

return function(a, b)
    local result = {}
    for _, v in pairs(a) do
        table.insert(result, v)
    end
    for _, v in pairs(b) do
        table.insert(result, v)
    end
    return result
end
