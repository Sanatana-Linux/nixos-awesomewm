--[[
    backdrop

    Provides a semi-transparent backdrop wibox for AwesomeWM popups.
    The backdrop is initialized for the primary screen and can be shown/hidden
    behind popup wiboxes to create a modal effect.

    Exports:
      show(popup_wibox): Shows the backdrop below the given popup wibox.
      hide(): Hides the backdrop.
]]

local wibox = require("wibox")
local beautiful = require("beautiful")
local capi = { screen = screen }
local gears = require("gears")

--- Stores the backdrop wibox instance.
local backdrop_wibox = nil

--- Create a backdrop widget with gradient effect
local function create_backdrop_widget()
    return {
        widget = wibox.container.background,
        bg = beautiful.bg and (beautiful.bg .. "88") or "#00000088",
    }
end

--- Initializes the backdrop wibox for the primary screen.
--  Ensures only one instance is created.
local function _initialize_backdrop()
    if backdrop_wibox then
        return
    end -- Already initialized

    if capi.screen.primary and capi.screen.primary.geometry then
        local success, new_wibox = pcall(wibox, {
            x = capi.screen.primary.geometry.x,
            y = capi.screen.primary.geometry.y,
            width = capi.screen.primary.geometry.width,
            height = capi.screen.primary.geometry.height,
            bg = "#00000000", -- Transparent
            type = "splash",
            input_passthrough = true,
            visible = false,
        })

        if success and new_wibox then
            backdrop_wibox = new_wibox
            
            -- Set up the backdrop widget
            backdrop_wibox:setup(create_backdrop_widget())
            
            -- Update backdrop geometry when screen geometry changes
            capi.screen.primary:connect_signal("property::geometry", function(s)
                if backdrop_wibox then
                    backdrop_wibox.x = s.geometry.x
                    backdrop_wibox.y = s.geometry.y
                    backdrop_wibox.width = s.geometry.width
                    backdrop_wibox.height = s.geometry.height
                end
            end)
        end
    end
end

-- Attempt to initialize the backdrop after a short delay to ensure screen is ready
gears.timer.delayed_call(function()
    _initialize_backdrop()
end)

--- Shows the backdrop below the given popup wibox.
-- @param popup_wibox The wibox to place the backdrop below.
local function show_backdrop(popup_wibox)
    if not backdrop_wibox then
        _initialize_backdrop()
    end

    if backdrop_wibox then
        backdrop_wibox.visible = true
        -- Place the backdrop below the calling popup
        if popup_wibox and popup_wibox.drawable then
            backdrop_wibox.below = popup_wibox.drawable
        end
    end
end

--- Hides the backdrop and clears its 'below' property.
local function hide_backdrop()
    if backdrop_wibox then
        backdrop_wibox.visible = false
        backdrop_wibox.below = nil -- Clear the 'below' property
    end
end

return {
    show = show_backdrop,
    hide = hide_backdrop,
}
