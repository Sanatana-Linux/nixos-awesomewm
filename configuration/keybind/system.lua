---@diagnostic disable: undefined-global
local awful = require("awful")
local capi = { awesome = awesome, client = client }
local hotkeys_popup = require("ui.popups.hotkeys_popup")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local day_info_panel = require("ui.popups.day_info_panel").get_default()
local control_panel = require("ui.popups.control_panel").get_default()
local powermenu = require("ui.popups.powermenu").get_default()
local modkey = "Mod4"

awful.keyboard.append_global_keybindings({

    -- -------------------------------------------------------------------------- --
    -- Keybinding Help
    awful.key(
        { modkey },
        "F1",
        hotkeys_popup.show_help,
        { description = "show keybindings table", group = "System" }
    ),

    -- -------------------------------------------------------------------------- --
    -- Reload / Quit Awesome
    awful.key(
        { modkey },
        "r",
        capi.awesome.restart,
        { description = "reload awesome", group = "System" }
    ),

    awful.key(
        { modkey, "Shift" },
        "q",
        capi.awesome.quit,
        { description = "quit awesome", group = "System" }
    ),

    -- -------------------------------------------------------------------------- --
    -- Panel Toggles
    awful.key(
        { modkey },
        "d",
        function()
            day_info_panel:toggle()
        end,
        { description = "toggle day info panel", group = "System" }
    ),

    awful.key(
        { modkey },
        "e",
        function()
            control_panel:toggle()
        end,
        { description = "toggle control panel", group = "System" }
    ),

    awful.key({ modkey }, "x", function()
        powermenu:show()
    end, { description = "show power menu", group = "System" }),

    -- -------------------------------------------------------------------------- --
    -- Client Selection Menu
    awful.key({ modkey }, "Tab", function()
        awful.menu.menu_keys.down = { "Down", "Alt_L" }
        awful.menu.menu_keys.up = { "Up", "Alt_R" }
        local clients = {}
        for _, c in ipairs(client.get()) do
            table.insert(clients, {
                c.name or "Unnamed",
                function()
                    client.focus = c
                    c:raise()
                end,
                c.icon,
            })
        end
        awful.menu({
            items = clients,
            theme = {
                width = dpi(450),
                bg = beautiful.bg_gradient,
                border_color = beautiful.fg .. "99",
                border_width = dpi(1),
            },
        }):show({ keygrabber = true })
    end, { description = "Client Selection Menu", group = "System" }),

    -- -------------------------------------------------------------------------- --
    -- Alt+Tab Keygrabber
    awful.keygrabber({
        keybindings = {
            awful.key({
                modifiers = { "Mod1" },
                key = "Tab",
                on_press = function()
                    awful.client.focus.byidx(1)
                end,
            }),
            awful.key({
                modifiers = { "Mod1", "Shift" },
                key = "Tab",
                on_press = function()
                    awful.client.focus.byidx(-1)
                end,
            }),
        },
        root_keybindings = {},
        stop_key = "Mod1",
        stop_event = "release",
        start_callback = function()
            awesome.emit_signal("window_switcher::turn_on")
        end,
        stop_callback = function()
            if client.focus then
                client.focus:raise()
            end
        end,
        export_keybindings = true,
    }),
})
