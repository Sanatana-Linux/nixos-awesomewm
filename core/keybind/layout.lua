---@diagnostic disable: undefined-global
-- Import AwesomeWM's core functionality library
local awful = require("awful")
local layouts_osd = require("ui.popups.on_screen_display.layouts").get_default()
-- Capture global APIs for awesome, client, and screen management
local capi = { awesome = awesome, client = client, screen = screen }
-- Define modifier key (Super/Windows key)
local modkey = "Mod4"

-- Register global keybindings for layout and client management
awful.keyboard.append_global_keybindings({
    -- -------------------------------------------------------------------------- --
    -- CLIENT SWAPPING KEYBINDINGS --
    -- Swap current client with next client in stack
    awful.key({ modkey, "Shift" }, "j", function()
        awful.client.swap.byidx(1) -- Move current window down in client stack
    end, { description = "swap with next client by index", group = "client" }),

    -- Swap current client with previous client in stack
    awful.key({ modkey, "Shift" }, "k", function()
        awful.client.swap.byidx(-1) -- Move current window up in client stack
    end, { description = "swap with previous client by index", group = "client" }),

    -- -------------------------------------------------------------------------- --

    -- Jump to urgent client (window requesting attention)
    awful.key({ modkey }, "u", awful.client.urgent.jumpto, -- Built-in function to focus urgent window
        { description = "jump to urgent client", group = "client" }),

    -- -------------------------------------------------------------------------- --

    -- MASTER AREA WIDTH CONTROLS --
    -- Mod4 + h: Decrease master area width by 5%
    awful.key({ modkey }, "h", function()
        awful.tag.incmwfact(-0.05) -- Shrink master window area
    end, { description = "decrease master width factor", group = "layout" }),

    -- Mod4 + l: Increase master area width by 5%
    awful.key({ modkey }, "l", function()
        awful.tag.incmwfact(0.05) -- Expand master window area
    end, { description = "increase master width factor", group = "layout" }),

    -- -------------------------------------------------------------------------- --

    -- MASTER CLIENT COUNT CONTROLS --
    -- Mod4 + Shift + h: Increase number of windows in master area
    awful.key({ modkey, "Shift" }, "h", function()
        awful.tag.incnmaster(1, nil, true) -- Add one more master client
    end, {
        description = "increase the number of master clients",
        group = "layout",
    }),
    -- Mod4 + Shift + l: Decrease number of windows in master area
    awful.key({ modkey, "Shift" }, "l", function()
        awful.tag.incnmaster(-1, nil, true) -- Remove one master client
    end, {
        description = "decrease the number of master clients",
        group = "layout",
    }),

    -- -------------------------------------------------------------------------- --

    -- COLUMN COUNT CONTROLS --
    -- Increase number of columns in non-master area
    awful.key({ modkey, "Control" }, "h", function()
        awful.tag.incncol(1, nil, true) -- Add one more column for stacked clients
    end, { description = "increase the number of columns", group = "layout" }),

    --  Decrease number of columns in non-master area
    awful.key({ modkey, "Control" }, "l", function()
        awful.tag.incncol(-1, nil, true) -- Remove one column for stacked clients
    end, { description = "decrease the number of columns", group = "layout" }),

    -- -------------------------------------------------------------------------- --

    -- LAYOUT SWITCHING CONTROLS --
    -- Mod4 + Space: Switch to next layout in rotation
    awful.key({ modkey }, "space", function()
        awesome.emit_signal("layout::changed:next")
    end, { description = "select next layout", group = "layout" }),

    -- Mod4 + Shift + Space: Switch to previous layout in rotation
    awful.key({ modkey, "Shift" }, "space", function()
        awesome.emit_signal("layout::changed:prev")
    end, { description = "select previous layout", group = "layout" }),
})
