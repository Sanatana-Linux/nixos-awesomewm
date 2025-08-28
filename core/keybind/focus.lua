---@diagnostic disable: undefined-global
local awful = require("awful")                                       -- AwesomeWM utility library

local capi = { awesome = awesome, client = client, screen = screen } -- Shorthand for core objects

local modkey = "Mod4"                                                -- Set modkey (usually the Super/Windows key)

-- Append global keybindings for focusing clients and screens
awful.keyboard.append_global_keybindings({
    -- Focus next client by index
    awful.key({ modkey }, "j", function()
        awful.client.focus.byidx(1)
    end, { description = "focus next by index", group = "Focus" }),

    -- Focus previous client by index
    awful.key({ modkey }, "k", function()
        awful.client.focus.byidx(-1)
    end, { description = "focus previous by index", group = "Focus" }),

    -- Go back to the previously focused client
    awful.key({ modkey }, "Tab", function()
        awful.client.focus.history.previous()
        if capi.client.focus then
            capi.client.focus:raise() -- Raise the client to the top
        end
    end, { description = "go back", group = "Focus" }),

    -- Alt+Tab: Cycle through clients (fallback if window switcher fails)
    awful.key({ "Mod1" }, "Tab", function()
        awful.client.focus.byidx(1)
        if capi.client.focus then
            capi.client.focus:raise()
        end
    end, { description = "cycle through clients", group = "Focus" }),

    -- Alt+Shift+Tab: Cycle through clients in reverse
    awful.key({ "Mod1", "Shift" }, "Tab", function()
        awful.client.focus.byidx(-1)
        if capi.client.focus then
            capi.client.focus:raise()
        end
    end, { description = "cycle through clients (reverse)", group = "Focus" }),

    -- Focus the next screen
    awful.key({ modkey, "Control" }, "j", function()
        awful.screen.focus_relative(1)
    end, { description = "focus the next screen", group = "Focus" }),

    -- Focus the previous screen
    awful.key({ modkey, "Control" }, "k", function()
        awful.screen.focus_relative(-1)
    end, { description = "focus the previous screen", group = "Focus" }),

    -- Restore the most recently minimized client (client control, but global binding)
    awful.key({ modkey, "Control" }, "n", function()
        local c = awful.client.restore()
        -- Focus and raise the restored client if it exists
        if c then
            c:activate({ raise = true, context = "key.unminimize" })
        end
    end, { description = "restore minimized", group = "Client" }),

})
