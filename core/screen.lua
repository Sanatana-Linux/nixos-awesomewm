-- Screen management module to override primary screen selection
-- This ensures the internal display is preferred over HDMI

local capi = { screen = screen }
local awful = require("awful")
local gtimer = require("gears.timer")

local screen_module = {}

-- Function to detect preferred primary screen
-- Prefers internal displays over external HDMI displays
function screen_module.get_preferred_primary()
    local screens = capi.screen
    local preferred_screen = nil

    -- Try to find an internal display first
    for s in screens do
        -- If we have multiple screens, try to identify internal one
        if #screens > 1 then
            -- Internal displays often have different resolutions/positions
            -- You might need to customize this logic for your specific setup
            if s.geometry.width == 1920 and s.geometry.height == 1080 then
                -- Example: prefer 1920x1080 over other resolutions
                preferred_screen = s
                break
            elseif s.geometry.x == 0 and s.geometry.y == 0 then
                -- Screen at position 0,0 is often the primary/internal
                preferred_screen = s
                break
            end
        else
            -- Only one screen, use it
            preferred_screen = s
            break
        end
    end

    -- Fallback to X11's primary screen if no preference found
    return preferred_screen or capi.screen.primary
end

-- Override the primary screen
function screen_module.override_primary()
    local preferred = screen_module.get_preferred_primary()
    if preferred and preferred ~= capi.screen.primary then
        -- Set our preferred screen as primary
        capi.screen.primary = preferred
        io.stderr:write(
            string.format(
                "[SCREEN] Overriding primary screen to screen %d\n",
                preferred.index
            )
        )
    end
end

-- Handle screen changes (hot-plug/unplug)
function screen_module.setup_screen_handling()
    -- Override primary screen on startup
    screen_module.override_primary()

    -- Also handle screens being added/removed
    capi.screen.connect_signal("added", function()
        gtimer.delayed_call(function()
            screen_module.override_primary()
        end)
    end)

    capi.screen.connect_signal("removed", function()
        gtimer.delayed_call(function()
            screen_module.override_primary()
        end)
    end)
end

-- Initialize screen handling
screen_module.setup_screen_handling()

return screen_module
