---@diagnostic disable: undefined-global

-- Import required AwesomeWM libraries
local awful = require("awful")
local rclient = require("ruled.client")
local capi = { client = client, tag = tag, mouse = mouse }
local awesome = awesome
require("awful.autofocus")
require("core.client.backdrop")
require("core.client.better_resize")
require("core.client.save_floating_clients")

-- Handle pop up (transient) and fullscreen + maximized clients
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
        awful.placement.no_offscreen(
            c,
            { honor_workarea = true, honor_padding = true }
        )
    end
end)

-- Define client rules when requested
rclient.connect_signal("request::rules", function()
    -- Global rule for all clients
    rclient.append_rule({
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
                --awful.placement.centered(d, { honor_workarea = true })
                awful.placement.no_offscreen(
                    d,
                    { honor_workarea = true, honor_padding = true }
                )
            end,
        },
    })

    -- Enable titlebars for normal and dialog windows
    rclient.append_rule({
        id = "titlebars",
        rule_any = {
            type = { "normal", "dialog" },
        },
        properties = {
            titlebars_enabled = true,
        },
    })

    -- Set default size for mpv windows
    rclient.append_rule({
        rule_any = {
            class = { "mpv" },
        },
        properties = {
            width = 1280,
            height = 720,
        },
    })

    -- Rule for fixed-size Xephyr windows
    rclient.append_rule({
        id = "xephyr_fixed_size",
        rule_any = {
            class = { "xephyr_1", "Xephyr" },
        },
        properties = {
            min_width = 1200,
            max_width = 1200,
            min_height = 800,
            max_height = 800,
            size_hints_honor = true,
            titlebars_enabled = false, -- Enable titlebars
            floating = true, -- Set as floating
            raise = true, -- Raise on focus
            centered = true, -- Center on screen
            screen = awful.screen.preferred, -- Use preferred screen
            placement = function(c)
                --  Center and keep client on screen, honoring workarea and padding
                awful.placement.centered(
                    c,
                    { honor_workarea = true, honor_padding = true }
                )
                awful.placement.no_offscreen(c)
            end,
        },
    })

    -- Floating rules for specific clients
    rclient.append_rule({
        id = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
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
            size_hints_honor = true,
            centered = true, -- Center on screen
            screen = awful.screen.preferred, -- Use preferred screen
            placement = function(c)
                --  Center and keep client on screen, honoring workarea and padding
                awful.placement.centered(
                    c,
                    { honor_workarea = true, honor_padding = true }
                )
                awful.placement.no_offscreen(c)
            end,
        },
    })
end)

-- Focus client on mouse enter (sloppy focus)
capi.client.connect_signal("mouse::enter", function(c)
    c:activate({ context = "mouse_enter", raise = false })
end)

-- Manage new clients
capi.client.connect_signal("manage", function(c)
    -- The default is to make all clients slave clients.
    -- floating windows are an exception.
    if not c.floating then
        awful.client.setslave(c)
    end

    if
        awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position
    then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

local function focus_back()
    local s = awful.screen.focused()
    local c = awful.client.focus.history.get(s, 0)
    if c then
        client.focus = c
        c:raise()
    end
end

capi.client.connect_signal("property::minimized", focus_back)
--+ attach to minimized state

capi.client.connect_signal("unmanage", focus_back)
--+ attach to closed state

capi.tag.connect_signal("property::selected", focus_back)
--|ensure there is always a selected client during tag
--|switching or logins
