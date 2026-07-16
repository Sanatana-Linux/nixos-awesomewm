---@diagnostic disable: undefined-global
--- Custom-layout keybinding descriptions.
-- Layouts `modules.layouts.grid` and `modules.layouts.map` register their own
-- internal keygrabber handlers for navigate/move/resize operations. This file
-- passes the descriptive metadata (modifiers, key, description, group) to
-- `ui.popups.hotkeys_popup` so the F1 help panel surfaces them. It does not
-- itself call `awful.keyboard.append_*`.
-- @module configuration.keybind.layout_custom

-- Register custom layout keybinding descriptions with the hotkeys popup.
-- These keys aren't global — they're layout-internal keygrabber handlers
-- for grid and map layouts. Descriptions are registered so they appear
-- in the F1 help under their respective groups.

local hotkeys_popup = require("ui.popups.hotkeys_popup")
local layouts = require("modules.layouts")
local grid = layouts.grid
local map = layouts.map

--- Build hotkeys popup data from `awful.key` format entries.
-- Groups entries by their `info.group` field and returns them structured
-- as `{ [group_name] = { { modifiers = {...}, keys = {key = desc} } } }`.
-- @tparam table entries Array of `{{mods}, key, func, {description=..., group=...}}`
-- @treturn table Grouped hotkeys data for the popup
-- @local
local function build_hotkeys(entries)
    -- Returns entries grouped by their internal group name
    local groups = {}
    for _, entry in ipairs(entries) do
        local mods = entry[1] or {}
        local key = entry[2]
        local info = entry[4]
        if info and info.description then
            local gn = info.group or "General"
            if not groups[gn] then
                groups[gn] = {}
            end
            -- Find matching modifier block or create one
            local block
            for _, b in ipairs(groups[gn]) do
                local match = #b.modifiers == #mods
                if match then
                    for i, m in ipairs(mods) do
                        if b.modifiers[i] ~= m then
                            match = false
                            break
                        end
                    end
                end
                if match then
                    block = b
                    break
                end
            end
            if not block then
                block = { modifiers = mods, keys = {} }
                table.insert(groups[gn], block)
            end
            block.keys[key] = info.description
        end
    end
    return groups
end

-- Grid: Movement + Resize groups
-- These are used by the grid keygrabber when navigating grid layout
if grid.keys and grid.keys.move then
    local grid_groups = build_hotkeys(grid.keys.move)
    local grid_resize = build_hotkeys(grid.keys.resize)
    for g, b in pairs(grid_resize) do
        if not grid_groups[g] then
            grid_groups[g] = {}
        end
        for _, v in ipairs(b) do
            table.insert(grid_groups[g], v)
        end
    end
    hotkeys_popup.add_hotkeys(grid_groups)
end

-- Map: Layout + Resize groups
-- Used by the map keygrabber when navigating usermap layout
if map.keys and map.keys.layout then
    local map_groups = build_hotkeys(map.keys.layout)
    local map_resize = build_hotkeys(map.keys.resize)
    for g, b in pairs(map_resize) do
        if not map_groups[g] then
            map_groups[g] = {}
        end
        for _, v in ipairs(b) do
            table.insert(map_groups[g], v)
        end
    end
    hotkeys_popup.add_hotkeys(map_groups)
end

-- Navigator: Common keys active in layout navigation mode (Mod4+F2)
-- These are always available regardless of which layout is active
local common = require("modules.layouts.widgets.common")
local nav_groups = {}
if common.keys.base then
    local base = build_hotkeys(common.keys.base)
    for g, b in pairs(base) do
        if not nav_groups[g] then
            nav_groups[g] = {}
        end
        for _, v in ipairs(b) do
            table.insert(nav_groups[g], v)
        end
    end
end
if common.keys.swap then
    local swap = build_hotkeys(common.keys.swap)
    for g, b in pairs(swap) do
        if not nav_groups[g] then
            nav_groups[g] = {}
        end
        for _, v in ipairs(b) do
            table.insert(nav_groups[g], v)
        end
    end
end
if common.keys.tile then
    local tile = build_hotkeys(common.keys.tile)
    for g, b in pairs(tile) do
        if not nav_groups[g] then
            nav_groups[g] = {}
        end
        for _, v in ipairs(b) do
            table.insert(nav_groups[g], v)
        end
    end
end
if next(nav_groups) then
    hotkeys_popup.add_hotkeys(nav_groups)
end
