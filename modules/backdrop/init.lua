-- Backdrop component for popup windows
-- Creates a semi-transparent overlay that can blur the background and handle clicks

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local backdrop = {}

-- Backdrop instance tracking
local backdrop_wibox = nil
local backdrop_visible = false
local associated_popup = nil

-- Configuration
local backdrop_color = beautiful.backdrop_color or "#000000" -- Semi-transparent black
local backdrop_opacity = beautiful.backdrop_opacity or 0.2

-- Create the backdrop wibox if it doesn't exist
local function create_backdrop()
    if backdrop_wibox then
        return backdrop_wibox
    end

    backdrop_wibox = wibox({
        visible = false,
        ontop = true, -- Above regular windows
        type = "dock", -- Dock type for background overlay
        bg = backdrop_color,
        opacity = backdrop_opacity,
        input_passthrough = false, -- Allow clicks to be captured
    })

    -- Set backdrop to cover entire screen
    local function update_geometry()
        local s = awful.screen.focused()
        if s then
            backdrop_wibox.x = s.geometry.x
            backdrop_wibox.y = s.geometry.y
            backdrop_wibox.width = s.geometry.width
            backdrop_wibox.height = s.geometry.height
        end
    end

    -- Update geometry when screen changes
    screen.connect_signal("property::geometry", update_geometry)
    update_geometry()

    -- Add blur property for picom targeting (wrapped in pcall to handle unsupported xproperties)
    local success, err = pcall(function()
        backdrop_wibox:set_xproperty("AWESOME_BACKDROP", "true")
    end)
    if not success then
        -- Fallback: set a different property or skip entirely
        -- This allows the backdrop to work even if xproperties aren't supported
        print(
            "Warning: Could not set AWESOME_BACKDROP xproperty: "
                .. tostring(err)
        )
    end

    return backdrop_wibox
end

-- Show backdrop for a popup
function backdrop.show(popup, options)
    options = options or {}

    if backdrop_visible and associated_popup == popup then
        return -- Already shown for this popup
    end

    -- Hide any existing backdrop
    backdrop.hide()

    -- Create backdrop if needed
    create_backdrop()

    -- Associate with popup
    associated_popup = popup
    backdrop_visible = true

    -- Show backdrop
    backdrop_wibox.visible = true

    -- Handle clicks on backdrop to hide popup
    if not backdrop_wibox._click_handler then
        backdrop_wibox._click_handler = function()
            if associated_popup and associated_popup.hide then
                associated_popup:hide()
            elseif associated_popup then
                associated_popup.visible = false
            end
        end

        backdrop_wibox:buttons(
            gears.table.join(
                awful.button({}, 1, backdrop_wibox._click_handler),
                awful.button({}, 2, backdrop_wibox._click_handler),
                awful.button({}, 3, backdrop_wibox._click_handler)
            )
        )
    end

    -- Connect to popup hide signal to auto-hide backdrop
    if popup and not popup._backdrop_connected then
        popup:connect_signal("property::visible", function(p)
            if not p.visible and associated_popup == p then
                backdrop.hide()
            end
        end)
        popup._backdrop_connected = true
    end
end

-- Hide backdrop
function backdrop.hide()
    if not backdrop_visible then
        return
    end

    backdrop_visible = false
    associated_popup = nil

    if backdrop_wibox then
        backdrop_wibox.visible = false
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
    if not backdrop_wibox then
        return
    end

    if properties.color then
        backdrop_wibox.bg = properties.color
    end

    if properties.opacity then
        backdrop_wibox.opacity = properties.opacity
    end
end

-- Clean up backdrop
function backdrop.cleanup()
    if backdrop_wibox then
        backdrop_wibox.visible = false
        backdrop_wibox = nil
    end
    backdrop_visible = false
    associated_popup = nil
end

return backdrop
