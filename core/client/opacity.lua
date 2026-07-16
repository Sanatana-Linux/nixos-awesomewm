--- Client opacity rules.
-- Data-driven opacity values keyed by client type, class, and
-- focus state, with a fallback chain to theme defaults.
-- @module core.client.opacity

local beautiful = require("beautiful")

--- Opacity values keyed by client type (e.g., normal=0.95, dock=1.0).
-- @tfield number normal
-- @tfield number tooltip
-- @tfield number dock
-- @tfield number popup_menu
-- @tfield number dropdown_menu
local type_opacity = {
    tooltip = 1.0,
    dock = 1.0,
    popup_menu = 0.95,
    dropdown_menu = 0.9,
    normal = 0.95,
}

--- Opacity values keyed by client class (named apps).
local class_opacity = {
    i3lock = 1.0,
    Dunst = 0.6,
    awesome = 0.95,
}

--- Opacity values for the focused client table (class → value).
local class_focused_opacity = {
    kitty = 0.85,
}

--- Opacity values for the unfocused client table (class → value).
local class_unfocused_opacity = {
    kitty = 0.80,
}

--- Apply opacity to a client based on type/class/focus state.
-- Lookup chain: `type_opacity` → `class_opacity` →
-- `class_focused_opacity` → theme defaults.
-- @tparam client c
local function apply_opacity(c)
    if c.type == "desktop" then
        return
    end

    local type_val = type_opacity[c.type]
    if type_val then
        c.opacity = type_val
        if c.type == "dock" then
            c.shape = nil
        end
        return
    end

    local class_val = class_opacity[c.class]
    if class_val then
        c.opacity = class_val
        return
    end

    local focused_val = class_focused_opacity[c.class]
    local unfocused_val = class_unfocused_opacity[c.class]
    if focused_val then
        c.opacity = c.focused and focused_val or unfocused_val
        return
    end

    c.opacity = c.focused and (beautiful.active_opacity or 1.0)
        or (beautiful.inactive_opacity or 0.90)
end

return {
    apply_opacity = apply_opacity,
}
