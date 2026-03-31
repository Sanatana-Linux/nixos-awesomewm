local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local gfs = require("gears.filesystem")
local shapes = require("modules.shapes.init")
local dpi = beautiful.xresources.apply_dpi
local applet_pages = require("modules.applet_pages")
local adapter = require("service.bluetooth").get_default()

local ICONS_PATH = gfs.get_configuration_dir()
    .. "ui/popups/control_panel/bluetooth_applet/icons/"
local ICON_BLUETOOTH = ICONS_PATH .. "bluetooth.svg"
local ICON_SEARCH = ICONS_PATH .. "search.svg"
local ICON_BACK = ICONS_PATH .. "arrow-left.svg"
local ICON_CHECK = ICONS_PATH .. "trust.svg"

local WHITE = applet_pages.WHITE

local function create_dev_widget(path)
    local dev = adapter:get_device(path)

    local ret = wibox.widget({
        path = path,
        widget = wibox.container.background,
        forced_height = dpi(40),
        {
            layout = wibox.layout.fixed.vertical,
            {
                id = "header",
                widget = wibox.container.background,
                forced_height = dpi(40),
                shape = shapes.rrect(10),
                border_width = dpi(1),
                border_color = WHITE,
                {
                    widget = wibox.container.margin,
                    margins = { left = dpi(15), right = dpi(15) },
                    {
                        layout = wibox.layout.align.horizontal,
                        {
                            layout = wibox.layout.fixed.horizontal,
                            spacing = dpi(8),
                            {
                                id = "check-icon",
                                widget = wibox.widget.imagebox,
                                image = gcolor.recolor_image(ICON_CHECK, WHITE),
                                forced_height = dpi(14),
                                forced_width = dpi(14),
                                resize = true,
                            },
                            {
                                widget = wibox.container.constraint,
                                width = dpi(200),
                                {
                                    id = "name",
                                    widget = wibox.widget.textbox,
                                },
                            },
                        },
                        nil,
                        {
                            widget = wibox.container.constraint,
                            width = dpi(130),
                            {
                                id = "percentage",
                                widget = wibox.widget.textbox,
                                align = "right",
                            },
                        },
                    },
                },
            },
            {
                id = "buttons",
                widget = wibox.container.background,
                forced_height = dpi(50),
                visible = false,
                {
                    widget = wibox.container.margin,
                    margins = { top = dpi(5) },
                    {
                        layout = wibox.layout.flex.horizontal,
                        spacing = dpi(5),
                        {
                            id = "connect-button",
                            widget = wibox.container.background,
                            shape = shapes.rrect(10),
                            border_width = dpi(1),
                            border_color = WHITE,
                            bg = beautiful.bg_gradient_button,
                            {
                                widget = wibox.container.margin,
                                margins = dpi(8),
                                {
                                    id = "connect-label",
                                    widget = wibox.widget.textbox,
                                    align = "center",
                                },
                            },
                        },
                        {
                            id = "pair-button",
                            widget = wibox.container.background,
                            shape = shapes.rrect(10),
                            border_width = dpi(1),
                            border_color = WHITE,
                            bg = beautiful.bg_gradient_button,
                            {
                                widget = wibox.container.margin,
                                margins = dpi(8),
                                {
                                    id = "pair-label",
                                    widget = wibox.widget.textbox,
                                    align = "center",
                                },
                            },
                        },
                        {
                            id = "trust-button",
                            widget = wibox.container.background,
                            shape = shapes.rrect(10),
                            border_width = dpi(1),
                            border_color = WHITE,
                            bg = beautiful.bg_gradient_button,
                            {
                                widget = wibox.container.margin,
                                margins = dpi(8),
                                {
                                    id = "trust-label",
                                    widget = wibox.widget.textbox,
                                    align = "center",
                                },
                            },
                        },
                    },
                },
            },
        },
    })

    local header = ret:get_children_by_id("header")[1]
    local check_icon = ret:get_children_by_id("check-icon")[1]
    local name = ret:get_children_by_id("name")[1]
    local percentage = ret:get_children_by_id("percentage")[1]
    local buttons = ret:get_children_by_id("buttons")[1]
    local connect_button = ret:get_children_by_id("connect-button")[1]
    local connect_label = ret:get_children_by_id("connect-label")[1]
    local pair_button = ret:get_children_by_id("pair-button")[1]
    local pair_label = ret:get_children_by_id("pair-label")[1]
    local trust_button = ret:get_children_by_id("trust-button")[1]
    local trust_label = ret:get_children_by_id("trust-label")[1]

    local buttons_visible = false
    local function toggle_buttons()
        buttons_visible = not buttons_visible
        ret:set_forced_height(buttons_visible and dpi(80) or dpi(40))
        buttons.visible = buttons_visible
    end

    header:connect_signal("mouse::enter", function(w)
        w:set_bg(beautiful.bg_urg)
    end)
    header:connect_signal("mouse::leave", function(w)
        w:set_bg(nil)
    end)
    header:buttons({
        awful.button({}, 1, function()
            toggle_buttons()
        end),
    })

    local function setup_button(button, action)
        button:connect_signal("mouse::enter", function(w)
            w:set_bg(beautiful.bg_gradient_button_alt)
        end)
        button:connect_signal("mouse::leave", function(w)
            w:set_bg(beautiful.bg_gradient_button)
        end)
        button:buttons({
            awful.button({}, 1, action),
        })
    end

    setup_button(connect_button, function()
        if not dev:get_connected() then
            dev:connect()
        else
            dev:disconnect()
        end
    end)
    setup_button(pair_button, function()
        if not dev:get_paired() then
            dev:pair()
        else
            dev:cancel_pairing()
        end
    end)
    setup_button(trust_button, function()
        dev:set_trusted(not dev:get_trusted())
    end)

    dev:connect_signal("property::percentage", function(_, perc)
        percentage:set_markup(
            perc ~= nil
                    and string.format(
                        "<span foreground='%s'>%.0f%%</span>",
                        WHITE,
                        perc
                    )
                or ""
        )
    end)

    dev:connect_signal("property::connected", function(_, cnd)
        local dev_name = dev:get_name() or dev:get_address()
        if cnd then
            check_icon:set_image(gcolor.recolor_image(ICON_CHECK, WHITE))
            check_icon.visible = true
        else
            check_icon.visible = false
        end
        name:set_markup(
            string.format("<span foreground='%s'>%s</span>", WHITE, dev_name)
        )
        connect_label:set_markup(
            string.format(
                "<span foreground='%s'>%s</span>",
                WHITE,
                cnd and "Disconnect" or "Connect"
            )
        )
    end)

    dev:connect_signal("property::paired", function(_, prd)
        pair_label:set_markup(
            string.format(
                "<span foreground='%s'>%s</span>",
                WHITE,
                prd and "Unpair" or "Pair"
            )
        )
    end)

    dev:connect_signal("property::trusted", function(_, trd)
        trust_label:set_markup(
            string.format(
                "<span foreground='%s'>%s</span>",
                WHITE,
                trd and "Untrust" or "Trust"
            )
        )
    end)

    local dev_name = dev:get_name() or dev:get_address()
    if dev:get_connected() then
        check_icon:set_image(gcolor.recolor_image(ICON_CHECK, WHITE))
        check_icon.visible = true
    else
        check_icon.visible = false
    end
    name:set_markup(
        string.format("<span foreground='%s'>%s</span>", WHITE, dev_name)
    )
    percentage:set_markup(
        dev:get_percentage()
                and string.format(
                    "<span foreground='%s'>%.0f%%</span>",
                    WHITE,
                    dev:get_percentage()
                )
            or ""
    )
    connect_label:set_markup(
        string.format(
            "<span foreground='%s'>%s</span>",
            WHITE,
            dev:get_connected() and "Disconnect" or "Connect"
        )
    )
    pair_label:set_markup(
        string.format(
            "<span foreground='%s'>%s</span>",
            WHITE,
            dev:get_paired() and "Unpair" or "Pair"
        )
    )
    trust_label:set_markup(
        string.format(
            "<span foreground='%s'>%s</span>",
            WHITE,
            dev:get_trusted() and "Untrust" or "Trust"
        )
    )

    return ret
end

local function on_device_added(self, path)
    local devices_layout = self:get_children_by_id("content-layout")[1]
    local dev_widget = create_dev_widget(path)

    if #devices_layout.children == 1 and not devices_layout.children[1].path then
        devices_layout:reset()
    else
        for _, old_dev_widget in ipairs(devices_layout.children) do
            if old_dev_widget.path == path then
                devices_layout:remove_widgets(old_dev_widget)
            end
        end
    end

    local dev = adapter:get_device(path)
    if dev:get_connected() then
        devices_layout:insert(1, dev_widget)
    else
        devices_layout:add(dev_widget)
    end
end

local function on_device_removed(self, path)
    local devices_layout = self:get_children_by_id("content-layout")[1]
    for _, dev_widget in ipairs(devices_layout.children) do
        if dev_widget.path == path then
            devices_layout:remove_widgets(dev_widget)
        end
    end

    if #devices_layout.children == 0 then
        devices_layout:add(wibox.widget({
            widget = wibox.container.place,
            forced_height = dpi(400),
            halign = "center",
            valign = "center",
            {
                widget = wibox.widget.imagebox,
                image = gcolor.recolor_image(ICON_SEARCH, WHITE),
                forced_height = dpi(25),
                forced_width = dpi(25),
                resize = true,
            },
        }))
    end
end

local function on_discovering(self, discovering)
    local bottombar_discover_button =
        self:get_children_by_id("bottombar-discover-button")[1]
    local bottombar_discover_icon =
        self:get_children_by_id("bottombar-discover-icon")[1]

    if discovering then
        bottombar_discover_button:set_bg(beautiful.bg_urg)
        bottombar_discover_icon:set_image(
            gcolor.recolor_image(ICON_SEARCH, beautiful.fg_alt)
        )
    else
        bottombar_discover_button:set_bg(beautiful.bg_gradient_button)
        bottombar_discover_icon:set_image(
            gcolor.recolor_image(ICON_SEARCH, WHITE)
        )
    end
end

local function on_powered(self, powered)
    local devices_layout = self:get_children_by_id("content-layout")[1]
    local bottombar_toggle_icon =
        self:get_children_by_id("bottombar-toggle-icon")[1]

    on_discovering(self, adapter:get_discovering())

    if powered then
        bottombar_toggle_icon:set_image(
            gcolor.recolor_image(ICON_BLUETOOTH, WHITE)
        )
        devices_layout:reset()
        devices_layout:add(wibox.widget({
            widget = wibox.container.place,
            forced_height = dpi(400),
            halign = "center",
            valign = "center",
            {
                widget = wibox.widget.imagebox,
                image = gcolor.recolor_image(ICON_SEARCH, WHITE),
                forced_height = dpi(25),
                forced_width = dpi(25),
                resize = true,
            },
        }))

        for _, dev in pairs(adapter:get_devices()) do
            on_device_added(self, dev:get_path())
        end

        adapter:start_discovery()
    else
        bottombar_toggle_icon:set_image(
            gcolor.recolor_image(ICON_BLUETOOTH, WHITE)
        )
        devices_layout:reset()
        devices_layout:add(wibox.widget({
            widget = wibox.container.place,
            forced_height = dpi(400),
            halign = "center",
            valign = "center",
            {
                widget = wibox.widget.textbox,
                align = "center",
                font = beautiful.font_name .. dpi(12),
                markup = "<span foreground='"
                    .. WHITE
                    .. "'>Bluetooth disabled</span>",
            },
        }))
    end
end

local function on_blocked(self, blocked)
    local devices_layout = self:get_children_by_id("content-layout")[1]
    local bottombar_toggle_icon =
        self:get_children_by_id("bottombar-toggle-icon")[1]

    if blocked then
        bottombar_toggle_icon:set_image(
            gcolor.recolor_image(ICON_BLUETOOTH, WHITE)
        )
        devices_layout:reset()
        devices_layout:add(wibox.widget({
            widget = wibox.container.place,
            forced_height = dpi(400),
            halign = "center",
            valign = "center",
            {
                widget = wibox.widget.textbox,
                align = "center",
                font = beautiful.font_name .. dpi(12),
                markup = "<span foreground='"
                    .. WHITE
                    .. "'>Bluetooth is blocked\nClick toggle to unblock</span>",
            },
        }))
    end
end

local function new()
    local ret = applet_pages.create_base_page({
        left_buttons = {
            applet_pages.create_button({
                id = "bottombar-toggle-button",
                icon_id = "bottombar-toggle-icon",
                icon = gcolor.recolor_image(ICON_BLUETOOTH, WHITE),
            }),
            applet_pages.create_button({
                id = "bottombar-discover-button",
                icon_id = "bottombar-discover-icon",
                icon = gcolor.recolor_image(ICON_SEARCH, WHITE),
            }),
        },
        right_buttons = {
            applet_pages.create_button({
                id = "bottombar-close-button",
                icon_id = "bottombar-close-icon",
                icon = gcolor.recolor_image(ICON_BACK, WHITE),
            }),
        },
    })

    local bottombar_toggle_button =
        ret:get_children_by_id("bottombar-toggle-button")[1]
    local bottombar_discover_button =
        ret:get_children_by_id("bottombar-discover-button")[1]
    local bottombar_close_button =
        ret:get_children_by_id("bottombar-close-button")[1]

    applet_pages.setup_button_effects(bottombar_toggle_button)
    applet_pages.setup_button_effects(bottombar_discover_button)
    applet_pages.setup_button_effects(bottombar_close_button)

    bottombar_toggle_button:buttons({
        awful.button({}, 1, function()
            if adapter:is_blocked() then
                adapter:unblock(function()
                    adapter:set_powered(true)
                end)
            else
                adapter:set_powered(not adapter:get_powered())
            end
        end),
    })

    bottombar_discover_button:buttons({
        awful.button({}, 1, function()
            if adapter:get_powered() then
                if adapter:get_discovering() then
                    adapter:stop_discovery()
                else
                    adapter:start_discovery()
                end
            end
        end),
    })


    adapter:connect_signal("device-added", function(_, path)
        on_device_added(ret, path)
    end)
    adapter:connect_signal("device-removed", function(_, path)
        on_device_removed(ret, path)
    end)
    adapter:connect_signal("property::discovering", function(_, dsc)
        on_discovering(ret, dsc)
    end)
    adapter:connect_signal("property::powered", function(_, powered)
        on_powered(ret, powered)
    end)
    adapter:connect_signal("property::blocked", function(_, blocked)
        on_blocked(ret, blocked)
    end)

    on_powered(ret, adapter:get_powered())

    return ret
end

return setmetatable({
    new = new,
}, {
    __call = new,
})
