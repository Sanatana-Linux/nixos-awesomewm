return function(t, v)
    for _, value in ipairs(t) do
        if value == v then
            return true
        end
    end

    return false
end
