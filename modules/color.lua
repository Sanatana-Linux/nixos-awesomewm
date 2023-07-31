--disclaimer I have no idea what any of the math does
local function rgb_to_hsl(obj)
    local r = obj.r or obj[1]
    local g = obj.g or obj[2]
    local b = obj.b or obj[3]

    local R, G, B = r / 255, g / 255, b / 255
    local max, min = math.max(R, G, B), math.min(R, G, B)
    local l, s, h

    -- Get luminance
    l = (max + min) / 2

    -- short circuit saturation and hue if it's grey to prevent divide by 0
    if max == min then
        s = 0
        h = obj.h or obj[4] or 0
        return 0, 0, l
    end

    -- Get saturation
    if l <= 0.5 then
        s = (max - min) / (max + min)
    else
        s = (max - min) / (2 - max - min)
    end

    -- Get hue
    if max == R then
        h = (G - B) / (max - min) * 60
    elseif max == G then
        h = (2.0 + (B - R) / (max - min)) * 60
    else
        h = (4.0 + (R - G) / (max - min)) * 60
    end

    -- Make sure it goes around if it's negative (hue is a circle)
    if h ~= 360 then
        h = h % 360
    end

    return h, s, l
end

--no clue about any of this either
local function hsl_to_rgb(obj)
    local h = obj.h or obj[1]
    local s = obj.s or obj[2]
    local l = obj.l or obj[3]

    local temp1, temp2, temp_r, temp_g, temp_b, temp_h

    -- Set the temp variables
    if l <= 0.5 then
        temp1 = l * (s + 1)
    else
        temp1 = l + s - l * s
    end

    temp2 = l * 2 - temp1

    temp_h = h / 360

    temp_r = temp_h + 1 / 3
    temp_g = temp_h
    temp_b = temp_h - 1 / 3

    -- Make sure it's between 0 and 1
    if temp_r ~= 1 then
        temp_r = temp_r % 1
    end
    if temp_g ~= 1 then
        temp_g = temp_g % 1
    end
    if temp_b ~= 1 then
        temp_b = temp_b % 1
    end

    local rgb = {}

    -- Bunch of tests
    -- Once again I haven't the foggiest what any of this does
    for _, v in pairs({ { temp_r, "r" }, { temp_g, "g" }, { temp_b, "b" } }) do
        if v[1] * 6 < 1 then
            rgb[v[2]] = temp2 + (temp1 - temp2) * v[1] * 6
        elseif v[1] * 2 < 1 then
            rgb[v[2]] = temp1
        elseif v[1] * 3 < 2 then
            rgb[v[2]] = temp2 + (temp1 - temp2) * (2 / 3 - v[1]) * 6
        else
            rgb[v[2]] = temp2
        end
    end

    return round(rgb.r * 255), round(rgb.g * 255), round(rgb.b * 255)
end

--check if table contains item
local function contains(obj, value)
    for _, v in pairs(obj) do
        if v == value then
            return true
        end
    end
    return false
end

-- Useful public methods
local function hex_to_rgba(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)),
        tonumber("0x" .. hex:sub(3, 4)),
        tonumber("0x" .. hex:sub(5, 6)),
        --if alpha exists in hex, return it
        #hex == 8 and tonumber("0x" .. hex:sub(7, 8)) or nil
end

local function rgba_to_hex(obj)
    local r = obj.r or obj[1]
    local g = obj.g or obj[2]
    local b = obj.b or obj[3]
    local a = obj.a or 1
    local h = (obj.hashtag or obj[4]) and "#" or ""
    return h
        .. string.format(
            "%02x%02x%02x",
            math.floor(r),
            math.floor(g),
            math.floor(b)
        )
        --this part only shows the alpha channel if it's not 1
        .. (a ~= 1 and string.format("%02x", math.floor(a * 255)) or "")
end
--constants for clarity
local ANY = { "r", "g", "b", "h", "s", "l", "hex", "a" }
local ANYSUBHEX = { "r", "g", "b", "h", "s", "l", "a" }
local RGB = { "r", "g", "b" }
local HSL = { "h", "s", "l" }
local HEX = { "hex" }

--create a color object
local function color(args)
    -- The object that will be returned
    local obj = { _props = {} }

    -- Default properties here
    obj._props.r = args.r or 0
    obj._props.g = args.g or 0
    obj._props.b = args.b or 0
    obj._props.h = args.h or 0
    obj._props.s = args.s or 0
    obj._props.l = args.l or 0
    obj._props.a = args.a or 1
    obj._props.hex = args.hex and args.hex:gsub("#", "") or "000000"

    obj._props.small_rgb = args.small_rgb or false

    -- Default actual normal properties
    obj.hashtag = args.hashtag or true
    obj.disable_hsl = args.disable_hsl or false

    -- Set access to any
    obj._access = ANY

    --temporary values
    --alpha since it can be nil and don't wanna overwrite,
    --hex_no_alpha just as a placeholder in _alphaize_hex
    local alpha, hex_no_alpha

    -- Methods and stuff
    function obj:_hex_to_rgba()
        obj._props.r, obj._props.g, obj._props.b, alpha =
            hex_to_rgba(obj._props.hex)
        if alpha then
            self._props.a = alpha
        end
        if obj._props.small_rgb then
            obj._props.r = math.floor(obj._props.r / 255)
            obj._props.g = math.floor(obj._props.g / 255)
            obj._props.b = math.floor(obj._props.b / 255)
        end
    end

    function obj:_rgba_to_hex()
        obj._props.hex = rgba_to_hex(obj._props)
    end

    function obj:_rgb_to_hsl()
        obj._props.h, obj._props.s, obj._props.l = rgb_to_hsl(obj._props)
    end

    function obj:_hsl_to_rgb()
        obj._props.r, obj._props.g, obj._props.b = hsl_to_rgb(obj._props)
    end

    function obj:_alphaize_hex()
        hex_no_alpha = #obj._props.hex == 6 and obj._props.hex
            or obj._props.hex:sub(1, 6)
        obj._props.hex = hex_no_alpha
            .. (
                obj._props.a ~= 1
                    and string.format("%02x", math.floor(obj._props.a * 255))
                or ""
            )
    end

    function obj:set_no_update(key, value)
        obj._props[key] = value
    end

    -- Initially set other values
    if obj._props.r ~= 0 or obj._props.g ~= 0 or obj._props.b ~= 0 then
        obj:_rgba_to_hex()
        if not obj.disable_hsl then
            obj:_rgb_to_hsl()
        end
    elseif obj._props.hex ~= "000000" then
        obj:_hex_to_rgba()
        if not obj.disable_hsl then
            obj:_rgb_to_hsl()
        end
    elseif obj._props.h ~= 0 or obj._props.s ~= 0 or obj._props.l ~= 0 then
        obj:_hsl_to_rgb()
        obj:_rgba_to_hex()
    end --otherwise it's just black and everything is correct already

    -- Set up the metatable
    local mt = getmetatable(obj) or {}

    -- Check if it's already in _props to return it
    mt.__index = function(self, key)
        if self._props[key] then
            -- Check if to just return nil for hsl
            if obj.disable_hsl and contains(HSL, key) then
                return self._props[key]
            end

            -- Check if something in ANY isn't currently accessible
            if not contains(obj._access, key) and contains(ANY, key) then
                if obj._access == RGB then
                    self:_rgba_to_hex()
                    if not obj.disable_hsl then
                        obj:_rgb_to_hsl()
                    end
                elseif obj._access == HEX then
                    self:_rgba_to_hex()
                    if not obj.disable_hsl then
                        obj:_rgb_to_hsl()
                    end
                elseif obj._access == HSL then
                    self:_hsl_to_rgb()
                    self:_rgba_to_hex()
                elseif obj._access == ANYSUBHEX then
                    self:_alphaize_hex()
                end

                -- Reset accessibleness
                obj._access = ANY
            end

            -- Check for hashtaginess
            if obj.hashtag and key == "hex" then
                return "#" .. self._props.hex
            end

            return self._props[key]
        else
            return rawget(self, key)
        end
    end

    mt.__newindex = function(self, key, value)
        if self._props[key] ~= nil then
            -- Set what values are currently accessible
            if utils.contains(RGB, key) then
                obj._access = RGB
            elseif utils.contains(HSL, key) and not obj.disable_hsl then
                obj._access = HSL
            elseif key == "hex" then
                obj._access = HEX
            elseif key == "a" then
                obj._access = ANYSUBHEX

            -- If it's not any of those and is small_rgb then update the rgb values
            elseif key == "small_rgb" and value ~= obj._props.small_rgb then
                if obj._props.small_rgb then
                    obj._props.r = obj._props.r / 255
                    obj._props.g = obj._props.g / 255
                    obj._props.b = obj._props.b / 255
                else
                    obj._props.r = math.floor(obj._props.r * 255)
                    obj._props.g = math.floor(obj._props.g * 255)
                    obj._props.b = math.floor(obj._props.b * 255)
                end
            end

            -- Set the new value
            self._props[key] = value

        -- If it's not part of _props just normally set it
        else
            rawset(self, key, value)
        end
    end

    -- performs an operation on the color and returns the new color
    local function operate(new, operator)
        local newcolor = color({ r = obj.r, g = obj.g, b = obj.b })
        local key = new:match("%a+")
        if operator == "+" then
            newcolor[key] = newcolor[key] + new:match("-?[%d\\.]+")
        elseif operator == "-" then
            newcolor[key] = newcolor[key] - new:match("-?[%d\\.]+")
        end
        return newcolor
    end

    mt.__add = function(_, new)
        return operate(new, "+")
    end
    mt.__sub = function(_, new)
        return operate(new, "-")
    end

    setmetatable(obj, mt)
    return obj
end

return color
