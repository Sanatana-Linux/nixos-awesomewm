---@diagnostic disable: undefined-global
--- Keybinding aggregator.
-- Loads every `bindings.*` module in order. Each file registers
-- its keybindings via `awful.keyboard.append_global_keybindings` (or
-- `append_client_keybindings`, depending on scope). The aggregator exists so
-- `rc.lua` only needs to `require("bindings")` once.
-- @module bindings

-- Import required libraries
local lgi = require("lgi")
local Gio = lgi.Gio -- GIO library for system operations
local awful = require("awful") -- AwesomeWM's core functionality library
local capi = { awesome = awesome, client = client } -- Capture global awesome and client APIs

-- Define the modifier key for keybindings (Mod4 is typically the Super/Windows key)
local modkey = "Mod4"

-- Enable edge snapping for mouse operations (windows snap to screen edges)
awful.mouse.snap.edge_enabled = true

--- Load and initialize all keybinding modules.
-- @local
local function set_keybindings()
    require("bindings.system") -- AwesomeWM system keybindings
    require("bindings.launcher") -- App and terminal launching
    require("bindings.hardware") -- Hardware control keybindings (volume, brightness, etc.)
    require("bindings.window") -- Window/client management keybindings
    require("bindings.focus") -- Window focus navigation keybindings
    require("bindings.layout") -- Layout switching and management keybindings
    require("bindings.mouse") -- Mouse button and gesture bindings
    require("bindings.tags") -- Tag/workspace management keybindings
end

-- Initialize all keybindings by calling the setup function
set_keybindings()
