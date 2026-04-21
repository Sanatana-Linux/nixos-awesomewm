-- Backdrop component for popup windows
-- Creates a semi-transparent overlay that picom will blur

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local backdrop = {}

-- Backdrop instance tracking (per screen)
local backdrop_wiboxes = {}
local backdrop_visible = false
local associated_popup = nil

-- Configuration
local backdrop_color = beautiful.backdrop_color or "#00000080"

-- Create backdrop wibox for a specific screen
local function create_backdrop_for_screen(s)
    if backdrop_wiboxes[s] then
        return backdrop_wiboxes[s]
    end

    local geometry = s.geometry

    -- Create the backdrop wibox
    -- The name "awesome-backdrop" allows picom to target this window for blur
    -- Using type "utility" instead of "dock" so picom will apply blur
    local bw = wibox({
        visible = false,
        ontop = true,
        type = "utility",
        bg = backdrop_color,
        input_passthrough = false,
        screen = s,
        width = geometry.width,
        height = geometry.height,
        x = geometry.x,
        y = geometry.y,
        name = "awesome-backdrop",
    })

    backdrop_wiboxes[s] = bw
    return bw
end

-- Show backdrop for a popup
function backdrop.show(popup, options)
    options = options or {}

    if backdrop_visible and associated_popup == popup then
        return
    end

    backdrop.hide()

    -- Create backdrop for all screens
    for s in screen do
        create_backdrop_for_screen(s)
        backdrop_wiboxes[s].visible = true
    end

    associated_popup = popup
    backdrop_visible = true
end

-- Hide backdrop
function backdrop.hide()
    if not backdrop_visible then
        return
    end

    backdrop_visible = false
    associated_popup = nil

    for s, bw in pairs(backdrop_wiboxes) do
        if bw then
            bw.visible = false
        end
    end
end

-- Check if backdrop is visible
function backdrop.is_visible()
    return backdrop_visible
end

-- Get the associated popup
function backdrop.get_popup()
    return associated_popup
end

-- Update backdrop properties
function backdrop.update_properties(properties)
    if properties.color then
        backdrop_color = properties.color
    end

    -- Update bg color on all backdrop wiboxes
    for s, bw in pairs(backdrop_wiboxes) do
        if bw then
            bw.bg = backdrop_color
        end
    end
end

-- Clean up backdrop
function backdrop.cleanup()
    for s, bw in pairs(backdrop_wiboxes) do
        if bw then
            bw.visible = false
            backdrop_wiboxes[s] = nil
        end
    end
    backdrop_visible = false
    associated_popup = nil
end

return backdrop
