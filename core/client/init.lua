---@diagnostic disable: undefined-global

-- Import required AwesomeWM libraries
local awful = require("awful")
local rclient = require("ruled.client")
local capi = { client = client }
local awesome = awesome 
require("awful.autofocus")

-- Handle client management requests
capi.client.connect_signal("request::manage", function(c)
    -- If the client is fullscreen, set its geometry to the screen's geometry
    if c.fullscreen then
        c:geometry(c.screen.geometry)
    -- If maximized, set geometry to the screen's workarea
    elseif c.maximized then
        c:geometry(c.screen.workarea)
    -- If the client is transient (e.g., a dialog), center it on its parent
    elseif c.transient_for then
        awful.placement.centered(c, { parent = c.transient_for })
        awful.placement.no_offscreen(c)
    end
end)

-- Define client rules when requested
rclient.connect_signal("request::rules", function()
    -- Global rule for all clients
    rclient.append_rule {
        id = "global",
        rule = {},
        properties = {
            titlebars_enabled = true,
            screen = awful.screen.preferred, -- Place on preferred screen
            focus = awful.client.focus.filter, -- Use default focus filter
            raise = true, -- Raise client on focus
            size_hints_honor = false, -- Ignore size hints
            placement = function(d)
                -- Center and keep client on screen
                awful.placement.centered(d, { honor_workarea = true })
                awful.placement.no_offscreen(d)
            end
        }
    }

    -- Enable titlebars for normal and dialog windows
    rclient.append_rule {
        id = "titlebars",
        rule_any = {
            type = { "normal", "dialog" }
        },
        properties = {
            titlebars_enabled = true
        }
    }

    -- Set default size for mpv windows
    rclient.append_rule {
        rule_any = {
            class = { "mpv" }
        },
        properties = {
            width = 1280,
            height = 720
        }
    }

    -- Floating rules for specific clients
    rclient.append_rule({
        id = "floating",
        rule_any = {
            instance = { "copyq", "pinentry", "Xephyr" },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "Sxiv",
                "Tor Browser",
                "Vlc",
                "xtightvncviewer",
                "nvidia-settings",
                "ark",
                "org.gnome.FileRoller",
                "xephyr_1",
                "Xephyr",
            },
            name = {
                "Event Tester", -- xev.
            },
            role = {
                "AlarmWindow", -- thunderbird's calendar.
                "ConfigManager", -- thunderbird's about:config.
                "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
            },
        },
        properties = {
            titlebars_enabled = true, -- Enable titlebars
            floating = true, -- Set as floating
            raise = true, -- Raise on focus
            centered = true, -- Center on screen
            screen = awful.screen.preferred, -- Use preferred screen
            placement = function(c)
                -- Center and keep client on screen, honoring workarea and padding
                awful.placement.centered(c, {honor_workarea = true, honor_padding = true})
                awful.placement.no_offscreen(c)
            end
        },
    })
end)

-- Focus client on mouse enter (sloppy focus)
capi.client.connect_signal("mouse::enter", function(c)
    c:activate({ context = "mouse_enter", raise = false })
end)

-- Manage new clients
capi.client.connect_signal("manage", function(c)
    if awesome.startup then
        awful.client.setslave(c) -- Set as slave during startup
    end
    if
        awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position
    then
        -- Place client on screen within the padding and workarea if not user/program positioned
        awful.placement.no_offscreen(c, {
            honor_workarea = true,
            honor_padding = true,
        })
    else
        awful.client.setslave(c) -- Set as slave otherwise

        -- Ensure client is on screen
        awful.placement.no_offscreen(c, {
            honor_workarea = true,
            honor_padding = true,
        })
    end
end)