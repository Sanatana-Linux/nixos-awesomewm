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
    awful.key({ modkey, "Shift" }, "j", function()
        awful.client.swap.byidx(1)
    end, { description = "swap with next client by index", group = "Layout" }),

    awful.key({ modkey, "Shift" }, "k", function()
        awful.client.swap.byidx(-1)
    end, { description = "swap with previous client by index", group = "Layout" }),

    -- -------------------------------------------------------------------------- --

    -- Jump to urgent client
    awful.key(
        { modkey },
        "u",
        awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "Layout" }
    ),

    -- -------------------------------------------------------------------------- --

    -- MASTER AREA WIDTH CONTROLS --
    -- Mod4 + h: Decrease master area width by 5%
    awful.key({ modkey }, "h", function()
        awful.tag.incmwfact(-0.05)
    end, { description = "decrease master width factor", group = "Layout" }),

    awful.key({ modkey }, "l", function()
        awful.tag.incmwfact(0.05)
    end, { description = "increase master width factor", group = "Layout" }),

    -- -------------------------------------------------------------------------- --

    -- MASTER CLIENT COUNT CONTROLS --
    -- Mod4 + Shift + h: Increase number of windows in master area
    awful.key({ modkey, "Shift" }, "h", function()
        awful.tag.incnmaster(1, nil, true) -- Add one more master client
    end, {
        description = "increase the number of master clients",
        group = "Layout",
    }),
    awful.key({ modkey, "Shift" }, "l", function()
        awful.tag.incnmaster(-1, nil, true)
    end, {
        description = "decrease the number of master clients",
        group = "Layout",
    }),

    -- -------------------------------------------------------------------------- --

    -- COLUMN COUNT CONTROLS --
    -- Increase number of columns in non-master area
    awful.key({ modkey, "Control" }, "h", function()
        awful.tag.incncol(1, nil, true)
    end, { description = "increase the number of columns", group = "Layout" }),

    awful.key({ modkey, "Control" }, "l", function()
        awful.tag.incncol(-1, nil, true)
    end, { description = "decrease the number of columns", group = "Layout" }),

    -- -------------------------------------------------------------------------- --

    -- DIRECTIONAL CLIENT SWAPPING --
    awful.key({ modkey }, "Up", function()
        awful.client.swap.bydirection("up")
    end, { description = "swap client up", group = "Layout" }),

    awful.key({ modkey }, "Down", function()
        awful.client.swap.bydirection("down")
    end, { description = "swap client down", group = "Layout" }),

    awful.key({ modkey }, "Left", function()
        awful.client.swap.bydirection("left")
    end, { description = "swap client left", group = "Layout" }),

    awful.key({ modkey }, "Right", function()
        awful.client.swap.bydirection("right")
    end, { description = "swap client right", group = "Layout" }),

    -- -------------------------------------------------------------------------- --

    -- SET CLIENT AS MASTER --
    awful.key({ modkey, "Control" }, "Return", function()
        if client.focus then
            awful.client.setmaster(client.focus)
        end
    end, { description = "set focused client as master", group = "Layout" }),

    -- -------------------------------------------------------------------------- --

    -- LAYOUT SWITCHING CONTROLS --
    -- Mod4 + Space: Switch to next layout in rotation
    awful.key({ modkey }, "space", function()
        awesome.emit_signal("layout::changed:next")
    end, { description = "select next layout", group = "Layout" }),

    awful.key({ modkey, "Shift" }, "space", function()
        awesome.emit_signal("layout::changed:prev")
    end, { description = "select previous layout", group = "Layout" }),
})
