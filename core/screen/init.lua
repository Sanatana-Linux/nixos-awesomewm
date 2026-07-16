--- Screen management.
-- Overrides the X11 primary-screen selection so an internal display
-- is preferred over an external HDMI monitor, and applies a small
-- `dpi(3)` padding to every screen's workarea. Re-runs both on
-- `screen::added` and `screen::removed` so hot-plug is handled.
-- @module core.screen

-- Screen management module to override primary screen selection
-- This ensures the internal display is preferred over HDMI

local capi = { screen = screen }
local awful = require("awful")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local screen_module = {}

--- Find the internal (preferred) primary screen.
-- Heuristic: prefer a 1920×1080 screen, else the screen at `(0, 0)`,
-- else fall back to X11's primary.
-- @treturn screen
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
--- Override `screen.primary` to prefer the internal display.
-- Calls `get_preferred_primary()` and sets `screen.primary` if the
-- preferred screen differs from X11's default.
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

-- Set up screen padding for all screens
--- Apply `dpi(3)` padding to every screen's workarea.
-- Creates a consistent gap between windows and screen edges.
function screen_module.setup_screen_padding()
    local padding_size = dpi(3) -- Gap between windows and screen edges

    -- Apply padding to all current screens
    for s in capi.screen do
        s.padding = {
            left = padding_size,
            right = padding_size,
            top = padding_size,
            bottom = padding_size,
        }
    end
end

-- Handle screen changes (hot-plug/unplug)
--- Wire up screen change handling. Called automatically at module load.
function screen_module.setup_screen_handling()
    -- Override primary screen on startup
    screen_module.override_primary()

    -- Set up screen padding for all screens
    screen_module.setup_screen_padding()

    -- Also handle screens being added/removed
    capi.screen.connect_signal("added", function()
        gtimer.delayed_call(function()
            screen_module.override_primary()
            screen_module.setup_screen_padding()
        end)
    end)

    capi.screen.connect_signal("removed", function()
        gtimer.delayed_call(function()
            screen_module.override_primary()
            screen_module.setup_screen_padding()
        end)
    end)
end

-- Initialize screen handling
screen_module.setup_screen_handling()

return screen_module
