local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gcolor = require("gears.color")
local gfs = require("gears.filesystem")
local gtable = require("gears.table")
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
local FG_ALT = beautiful.fg_alt

-- Tooltip helper: attaches an awful.tooltip to one or more widgets
----------------------------------------------------------------------
local function add_tooltip(objects, text)
    if type(objects) ~= "table" then
        objects = { objects }
    end
    awful.tooltip({
        objects = objects,
        text = text,
        delay_show = 0.5,
        margins_leftright = 8,
        margins_topbottom = 4,
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
    })
end

-- Tagbar-style button: matches the taskbar/taglist button appearance
----------------------------------------------------------------------
local function create_tagbar_button(args)
    local btn = wibox.widget({
        widget = wibox.container.background,
        shape = shapes.rrect(6),
        border_width = dpi(1),
        border_color = "transparent",
        bg = beautiful.bg_gradient_button,
        forced_width = dpi(40),
        forced_height = dpi(40),
        {
            widget = wibox.container.place,
            halign = "center",
            valign = "center",
            {
                widget = wibox.container.margin,
                margins = dpi(6),
                {
                    id = args.icon_id,
                    widget = wibox.widget.imagebox,
                    image = args.icon,
                    forced_height = dpi(20),
                    forced_width = dpi(20),
                    resize = true,
                },
            },
        },
    })

    btn:connect_signal("mouse::enter", function(w)
        w:set_bg(beautiful.bg_gradient_recessed)
        w:set_border_color(beautiful.fg .. "66")
    end)
    btn:connect_signal("mouse::leave", function(w)
        w:set_bg(beautiful.bg_gradient_button)
        w:set_border_color("transparent")
    end)

    return btn
end

-- Slider-style container: matches audio_slider / brightness_slider panels
----------------------------------------------------------------------
local function slider_container(content)
    local bg_color = beautiful.bg_alt or beautiful.bg_normal or "#222222"
    return wibox.widget({
        widget = wibox.container.background,
        bg = bg_color .. "aa",
        shape = shapes.rrect(10),
        border_width = dpi(1),
        border_color = beautiful.fg_alt,
        {
            widget = wibox.container.margin,
            margins = {
                left = dpi(20),
                right = dpi(20),
                top = dpi(10),
                bottom = dpi(10),
            },
            content,
        },
    })
end

-- Tagbar action button (full-width, for Connect/Pair/Trust actions)
----------------------------------------------------------------------
local function create_tagbar_action(args)
    local btn = wibox.widget({
        widget = wibox.container.background,
        shape = shapes.rrect(6),
        border_width = dpi(1),
        border_color = "transparent",
        bg = beautiful.bg_gradient_button,
        {
            widget = wibox.container.margin,
            margins = dpi(8),
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(4),
                {
                    id = "label-role",
                    widget = wibox.widget.textbox,
                    align = "center",
                    markup = string.format(
                        "<span foreground='%s'>%s</span>",
                        WHITE,
                        args.text or ""
                    ),
                },
            },
        },
    })

    btn:connect_signal("mouse::enter", function(w)
        w:set_bg(beautiful.bg_gradient_recessed)
        w:set_border_color(beautiful.fg .. "66")
    end)
    btn:connect_signal("mouse::leave", function(w)
        w:set_bg(beautiful.bg_gradient_button)
        w:set_border_color("transparent")
    end)

    return btn
end

local function create_dev_widget(path)
    local dev = adapter:get_device(path)

    -- Action buttons with tagbar style
    local connect_btn = create_tagbar_action({
        text = dev:get_connected() and "Disconnect" or "Connect",
    })
    local pair_btn = create_tagbar_action({
        text = dev:get_paired() and "Unpair" or "Pair",
    })
    local trust_btn = create_tagbar_action({
        text = dev:get_trusted() and "Untrust" or "Trust",
    })

    local inner = wibox.widget({
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(4),
        {
            id = "header",
            widget = wibox.container.background,
            forced_height = dpi(44),
            {
                widget = wibox.container.margin,
                margins = { left = dpi(4), right = dpi(4) },
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
                            visible = dev:get_connected(),
                        },
                        {
                            id = "name",
                            widget = wibox.widget.textbox,
                            markup = string.format(
                                "<span foreground='%s'>%s</span>",
                                WHITE,
                                dev:get_name() or dev:get_address()
                            ),
                        },
                    },
                    nil,
                    {
                        id = "status",
                        widget = wibox.widget.textbox,
                        align = "right",
                        markup = dev:get_percentage()
                                and string.format(
                                    "<span foreground='%s'>%.0f%%</span>",
                                    WHITE,
                                    dev:get_percentage()
                                )
                            or "",
                    },
                },
            },
        },
        {
            id = "buttons",
            widget = wibox.container.background,
            visible = false,
            {
                widget = wibox.container.margin,
                margins = {
                    left = dpi(4),
                    right = dpi(4),
                    top = dpi(6),
                    bottom = dpi(6),
                },
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = beautiful.separator_thickness + dpi(4),
                    spacing_widget = {
                        widget = wibox.container.margin,
                        margins = { top = dpi(4), bottom = dpi(4) },
                        {
                            widget = wibox.widget.separator,
                            orientation = "vertical",
                            color = beautiful.fg_alt,
                        },
                    },
                    connect_btn,
                    pair_btn,
                    trust_btn,
                },
            },
        },
    })

    local ret = slider_container(inner)

    ret.path = path
    ret:set_forced_height(dpi(44))

    local header = inner:get_children_by_id("header")[1]
    local check_icon = inner:get_children_by_id("check-icon")[1]
    local name = inner:get_children_by_id("name")[1]
    local percentage = inner:get_children_by_id("status")[1]
    local buttons = inner:get_children_by_id("buttons")[1]

    local buttons_visible = false
    local function toggle_buttons()
        buttons_visible = not buttons_visible
        ret:set_forced_height(buttons_visible and dpi(94) or dpi(44))
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

    add_tooltip(connect_btn, "Connect or disconnect this device")
    connect_btn:buttons({
        awful.button({}, 1, function()
            if not dev:get_connected() then
                dev:connect()
            else
                dev:disconnect()
            end
        end),
    })
    add_tooltip(pair_btn, "Pair or unpair with this device")
    pair_btn:buttons({
        awful.button({}, 1, function()
            if not dev:get_paired() then
                dev:pair()
            else
                dev:cancel_pairing()
            end
        end),
    })
    add_tooltip(trust_btn, "Trust or untrust this device")
    trust_btn:buttons({
        awful.button({}, 1, function()
            dev:set_trusted(not dev:get_trusted())
        end),
    })

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
        check_icon.visible = cnd and true or false
        name:set_markup(
            string.format("<span foreground='%s'>%s</span>", WHITE, dev_name)
        )
        -- Update connect button text
        connect_btn:get_children_by_id("label-role")[1]:set_markup(
            string.format(
                "<span foreground='%s'>%s</span>",
                WHITE,
                cnd and "Disconnect" or "Connect"
            )
        )
    end)

    dev:connect_signal("property::paired", function(_, prd)
        pair_btn:get_children_by_id("label-role")[1]:set_markup(
            string.format(
                "<span foreground='%s'>%s</span>",
                WHITE,
                prd and "Unpair" or "Pair"
            )
        )
    end)

    dev:connect_signal("property::trusted", function(_, trd)
        trust_btn:get_children_by_id("label-role")[1]:set_markup(
            string.format(
                "<span foreground='%s'>%s</span>",
                WHITE,
                trd and "Untrust" or "Trust"
            )
        )
    end)

    -- Initial state
    local dev_name = dev:get_name() or dev:get_address()
    check_icon.visible = dev:get_connected() or false
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

    return ret
end

local function on_device_added(self, path)
    local devices_layout = self:get_children_by_id("content-layout")[1]
    local wp = self._private
    local dev_widget = create_dev_widget(path)

    -- Remove searching label if present
    if
        #devices_layout.children == 1
        and devices_layout.children[1] == wp.searching_label
    then
        devices_layout:reset()
    elseif
        #devices_layout.children == 1 and not devices_layout.children[1].path
    then
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
    local wp = self._private
    for _, dev_widget in ipairs(devices_layout.children) do
        if dev_widget.path == path then
            devices_layout:remove_widgets(dev_widget)
        end
    end

    if #devices_layout.children == 0 then
        if adapter:get_discovering() then
            devices_layout:add(wp.searching_label)
        else
            devices_layout:add(
                applet_pages.create_empty_state({ icon = ICON_SEARCH })
            )
        end
    end
end

-- Page methods (uses _private for stored references)
----------------------------------------------------------------------
local bluetooth_page = {}

function bluetooth_page:on_discovering(discovering)
    local wp = self._private
    if discovering then
        wp.discover_btn:set_bg(beautiful.bg_urg)
        wp.discover_icon:set_image(
            gcolor.recolor_image(ICON_SEARCH, beautiful.fg_alt)
        )
        -- Show searching indicator if layout is empty or has empty state
        local devices_layout = self:get_children_by_id("content-layout")[1]
        if #devices_layout.children == 0 then
            devices_layout:add(wp.searching_label)
        elseif #devices_layout.children == 1 then
            local first = devices_layout.children[1]
            if not first.path then
                devices_layout:reset()
                devices_layout:add(wp.searching_label)
            end
        end
    else
        wp.discover_btn:set_bg(beautiful.bg_gradient_button)
        wp.discover_icon:set_image(gcolor.recolor_image(ICON_SEARCH, WHITE))
        -- Replace searching label with empty state if still showing
        local devices_layout = self:get_children_by_id("content-layout")[1]
        if
            #devices_layout.children == 1
            and devices_layout.children[1] == wp.searching_label
        then
            devices_layout:reset()
            devices_layout:add(
                applet_pages.create_empty_state({ icon = ICON_SEARCH })
            )
        end
    end
end

function bluetooth_page:on_powered(powered)
    local wp = self._private
    local devices_layout = self:get_children_by_id("content-layout")[1]

    if powered then
        wp.toggle_icon:set_image(
            gcolor.recolor_image(ICON_BLUETOOTH, beautiful.blue)
        )
        devices_layout:reset()
        devices_layout:add(
            applet_pages.create_empty_state({ icon = ICON_SEARCH })
        )

        for _, dev in pairs(adapter:get_devices()) do
            on_device_added(self, dev:get_path())
        end

        adapter:start_discovery()

        -- Sync discovering state after layout is populated
        self:on_discovering(adapter:get_discovering())
    else
        wp.toggle_icon:set_image(gcolor.recolor_image(ICON_BLUETOOTH, FG_ALT))
        devices_layout:reset()
        devices_layout:add(
            applet_pages.create_empty_state({ text = "Bluetooth disabled" })
        )
    end
end

function bluetooth_page:on_blocked(blocked)
    local wp = self._private
    local devices_layout = self:get_children_by_id("content-layout")[1]

    if blocked then
        wp.toggle_icon:set_image(gcolor.recolor_image(ICON_BLUETOOTH, WHITE))
        devices_layout:reset()
        devices_layout:add(applet_pages.create_empty_state({
            text = "Bluetooth is blocked\nClick toggle to unblock",
        }))
    end
end

local function new()
    -- Create bottom bar buttons with tagbar style
    local toggle_btn = create_tagbar_button({
        icon_id = "bottombar-toggle-icon",
        icon = gcolor.recolor_image(ICON_BLUETOOTH, WHITE),
    })
    local discover_btn = create_tagbar_button({
        icon_id = "bottombar-discover-icon",
        icon = gcolor.recolor_image(ICON_SEARCH, WHITE),
    })
    local close_btn = create_tagbar_button({
        icon_id = "bottombar-close-icon",
        icon = gcolor.recolor_image(ICON_BACK, WHITE),
    })

    local ret = applet_pages.create_base_page({
        left_buttons = { toggle_btn, discover_btn },
        right_buttons = { close_btn },
    })

    gtable.crush(ret, bluetooth_page, true)
    local wp = ret._private
    wp.toggle_btn = toggle_btn
    wp.discover_btn = discover_btn
    wp.close_btn = close_btn
    wp.toggle_icon = toggle_btn:get_children_by_id("bottombar-toggle-icon")[1]
    wp.discover_icon =
        discover_btn:get_children_by_id("bottombar-discover-icon")[1]

    -- Searching indicator shown in content area while discovering
    wp.searching_label = wibox.widget({
        widget = wibox.container.place,
        forced_height = dpi(400),
        halign = "center",
        valign = "center",
        {
            widget = wibox.widget.textbox,
            align = "center",
            markup = string.format(
                "<span foreground='%s'>Searching for devices...</span>",
                FG_ALT
            ),
        },
    })

    add_tooltip(toggle_btn, "Toggle Bluetooth on/off")
    toggle_btn:buttons({
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

    add_tooltip(discover_btn, "Search for nearby Bluetooth devices")
    discover_btn:buttons({
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

    add_tooltip(close_btn, "Back to control panel")

    adapter:connect_signal("device-added", function(_, path)
        on_device_added(ret, path)
    end)
    adapter:connect_signal("device-removed", function(_, path)
        on_device_removed(ret, path)
    end)
    adapter:connect_signal("property::discovering", function(_, dsc)
        ret:on_discovering(dsc)
    end)
    adapter:connect_signal("property::powered", function(_, powered)
        ret:on_powered(powered)
    end)
    adapter:connect_signal("property::blocked", function(_, blocked)
        ret:on_blocked(blocked)
    end)

    ret:on_powered(adapter:get_powered())

    return ret
end

return setmetatable({
    new = new,
}, {
    __call = new,
})
