-- helpers/read_json.lua

local json = require("mods.json")

return function(DATA)
    local function file_exists(DATA)
        local f = io.open(DATA, "r")
        if f ~= nil then
            io.close(f)
            return true
        else
            return false
        end
    end

    if file_exists(DATA) then
        local f = assert(io.open(DATA, "rb"))
        local lines = f:read("*all")
        f:close()
        local data = json.decode(lines)
        return data
    else
        return {}
    end
end
