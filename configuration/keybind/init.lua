---@diagnostic disable: undefined-global
-- Import required libraries
local lgi = require("lgi")
local Gio = lgi.Gio -- GIO library for system operations
local awful = require("awful") -- AwesomeWM's core functionality library
local capi = { awesome = awesome, client = client } -- Capture global awesome and client APIs

-- Import the default menu component
local menu = require("ui.popups.menu").get_default()

-- Define the modifier key for keybindings (Mod4 is typically the Super/Windows key)
local modkey = "Mod4"

-- Enable edge snapping for mouse operations (windows snap to screen edges)
awful.mouse.snap.edge_enabled = true

-- Function to load and initialize all keybinding modules
local function set_keybindings()
    require("configuration.keybind.system") -- AwesomeWM system keybindings
    require("configuration.keybind.launcher") -- App and terminal launching
    require("configuration.keybind.hardware") -- Hardware control keybindings (volume, brightness, etc.)
    require("configuration.keybind.window") -- Window/client management keybindings
    require("configuration.keybind.focus") -- Window focus navigation keybindings
    require("configuration.keybind.layout") -- Layout switching and management keybindings
    require("configuration.keybind.mouse") -- Mouse button and gesture bindings
    require("configuration.keybind.tags") -- Tag/workspace management keybindings
end

-- Initialize all keybindings by calling the setup function
set_keybindings()
