local cairo = require("lgi").cairo
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local shapes = require("modules.shapes")

local window_switcher_first_client
local window_switcher_minimized_clients = {}
local window_switcher_grabber
local window_switcher_box = nil

local function get_num_clients()
    local minimized_clients_in_tag = 0
    local matcher = function(c)
        return awful.rules.match(c, {
            minimized = true,
            skip_taskbar = false,
            hidden = false,
            first_tag = awful.screen.focused().selected_tag,
        })
    end
    for c in awful.client.iterate(matcher) do
        minimized_clients_in_tag = minimized_clients_in_tag + 1
    end
    return minimized_clients_in_tag + #awful.screen.focused().clients
end

local function window_switcher_hide(cancel_focus)
    if not window_switcher_box then
        return
    end

    if cancel_focus and window_switcher_first_client and window_switcher_first_client.valid then
        client.focus = window_switcher_first_client
        window_switcher_first_client:raise()
    elseif client.focus then
        local window_switcher_last_client = client.focus
        awful.client.focus.history.add(window_switcher_last_client)

        if window_switcher_first_client and window_switcher_first_client.valid then
            window_switcher_first_client:raise()
            window_switcher_last_client:raise()
        end
    end

    for _, c in pairs(window_switcher_minimized_clients) do
        if c and c.valid and not (client.focus and client.focus == c) then
            c.minimized = true
        end
    end

    window_switcher_minimized_clients = {}
    awful.client.focus.history.enable_tracking()
    awful.keygrabber.stop(window_switcher_grabber)
    window_switcher_box.visible = false
    window_switcher_box.widget = nil
    collectgarbage("collect")
end

local function draw_widget(mouse_keys)
    local tasklist_widget = awful.widget.tasklist({
        screen = awful.screen.focused(),
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = mouse_keys,
        style = {
            font = beautiful.font,
            fg_normal = beautiful.fg,
            fg_focus = beautiful.ac,
            bg_normal = beautiful.bg_alt .. "55",
            bg_focus = beautiful.fg .. "22",
            border_color_normal = beautiful.border_color_normal,
            border_color_focus = beautiful.fg .. "88",
            border_width = dpi(1),
            shape = shapes.rrect(beautiful.border_radius or dpi(10)),
        },
        layout = {
            layout = wibox.layout.flex.horizontal,
            max_widget_size = dpi(300),
            spacing = dpi(10),
        },
        widget_template = {
            widget = wibox.container.background,
            id = "bg_role",
            forced_width = dpi(450),
            create_callback = function(self, c, _, _)
                local content = gears.surface(c.content)
                if content then
                    local cr = cairo.Context(content)
                    local x, y, w, h = cr:clip_extents()
                    local img = cairo.ImageSurface.create(
                        cairo.Format.ARGB32,
                        w - x,
                        h - y
                    )
                    cr = cairo.Context(img)
                    cr:set_source_surface(content, 0, 0)
                    cr.operator = cairo.Operator.SOURCE
                    cr:paint()
                    self:get_children_by_id("thumbnail")[1].image = gears.surface.load(img)
                end
            end,
            {
                {
                    {
                        {
                            horizontal_fit_policy = "auto",
                            vertical_fit_policy = "auto",
                            id = "thumbnail",
                            clip_shape = shapes.rrect(beautiful.border_radius or dpi(10)),
                            widget = wibox.widget.imagebox,
                        },
                        margins = dpi(0),
                        widget = wibox.container.margin,
                    },
                    halign = "center",
                    valign = "center",
                    widget = wibox.container.place,
                },
                {
                    {
                        widget = awful.widget.clienticon,
                    },
                    forced_width = dpi(30),
                    valign = "center",
                    widget = wibox.container.place,
                },
                {
                    forced_width = dpi(200),
                    valign = "center",
                    id = "text_role",
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.align.horizontal,
            },
            layout = wibox.layout.flex.vertical,
            left = dpi(20),
            right = dpi(20),
            top = dpi(20),
            widget = wibox.container.margin,
        },
    })

    return wibox.widget({
        {
            tasklist_widget,
            margins = dpi(300),
            widget = wibox.container.margin,
        },
        halign = "center",
        content_fill_horizontal = true,
        widget = wibox.container.place,
    })
end

local function enable(opts)
    opts = opts or {}
    local hide_window_switcher_key = opts.hide_window_switcher_key or "Escape"
    local select_client_key = opts.select_client_key or 1
    local minimize_key = opts.minimize_key or "n"
    local unminimize_key = opts.unminimize_key or "N"
    local kill_client_key = opts.kill_client_key or "q"
    local cycle_key = opts.cycle_key or "Tab"
    local previous_key = opts.previous_key or "Left"
    local next_key = opts.next_key or "Right"
    local vim_previous_key = opts.vim_previous_key or "h"
    local vim_next_key = opts.vim_next_key or "l"
    local scroll_previous_key = opts.scroll_previous_key or 4
    local scroll_next_key = opts.scroll_next_key or 5

    window_switcher_box = wibox({
        bg = beautiful.bg .. "cc",
        visible = false,
        ontop = true,
        type = "splash",
        screen = awful.screen.focused(),
        widget = {
            {
                draw_widget(),
                margins = dpi(10),
                widget = wibox.container.margin,
            },
            shape_border_width = beautiful.border_width or dpi(1),
            shape_border_color = beautiful.border_color_normal,
            bg = beautiful.bg .. "cc",
            shape = shapes.rrect(beautiful.border_radius or dpi(10)),
            widget = wibox.container.background,
        },
    })

    awful.placement.maximize(window_switcher_box)

    local mouse_keys = gears.table.join(
        awful.button({
            modifiers = { "Any" },
            button = select_client_key,
            on_press = function(c)
                client.focus = c
            end,
        }),
        awful.button({
            modifiers = { "Any" },
            button = scroll_previous_key,
            on_press = function()
                awful.client.focus.byidx(-1)
            end,
        }),
        awful.button({
            modifiers = { "Any" },
            button = scroll_next_key,
            on_press = function()
                awful.client.focus.byidx(1)
            end,
        })
    )

local keyboard_keys = {
    [hide_window_switcher_key] = function()
        window_switcher_hide(true)
    end,
    ["Return"] = function()
        window_switcher_hide(false)
    end,
    ["Control_L"] = function()
        window_switcher_hide(true)
    end,
    ["Control_R"] = function()
        window_switcher_hide(true)
    end,
    [minimize_key] = function()
        if client.focus then
            client.focus.minimized = true
        end
    end,
    [unminimize_key] = function()
        if awful.client.restore() then
            client.focus = awful.client.restore()
        end
    end,
    [kill_client_key] = function()
        if client.focus then
            client.focus:kill()
        end
    end,
[cycle_key] = function()
    awful.client.focus.byidx(1)
    if client.focus then
        client.focus:raise()
    end
    window_switcher_box.widget = draw_widget(mouse_keys)
end,
[previous_key] = function()
    awful.client.focus.byidx(1)
    if client.focus then
        client.focus:raise()
    end
    window_switcher_box.widget = draw_widget(mouse_keys)
end,
[next_key] = function()
    awful.client.focus.byidx(-1)
    if client.focus then
        client.focus:raise()
    end
    window_switcher_box.widget = draw_widget(mouse_keys)
end,
[vim_previous_key] = function()
    awful.client.focus.byidx(1)
    if client.focus then
        client.focus:raise()
    end
    window_switcher_box.widget = draw_widget(mouse_keys)
end,
[vim_next_key] = function()
    awful.client.focus.byidx(-1)
    if client.focus then
        client.focus:raise()
    end
    window_switcher_box.widget = draw_widget(mouse_keys)
end,
}

    window_switcher_box:connect_signal("property::width", function()
        if window_switcher_box.visible and get_num_clients() == 0 then
            window_switcher_hide()
        end
    end)

    window_switcher_box:connect_signal("property::height", function()
        if window_switcher_box.visible and get_num_clients() == 0 then
            window_switcher_hide()
        end
    end)

    awesome.connect_signal("window_switcher::turn_on", function()
        local number_of_clients = get_num_clients()
        if number_of_clients == 0 then
            return
        end

        window_switcher_first_client = client.focus
        awful.client.focus.history.disable_tracking()
        awful.client.focus.history.previous()

        local clients = awful.screen.focused().selected_tag:clients()
        for _, c in pairs(clients) do
            if c.minimized then
                table.insert(window_switcher_minimized_clients, c)
                c.minimized = false
                c:lower()
            end
        end

window_switcher_grabber = awful.keygrabber.run(function(mods, key, event)
    if event == "release" then
        if key:match("Super") or key:match("Alt") or key:match("Control") then
            window_switcher_hide()
        end
        return
    end

    if key == cycle_key then
        local shift_held = false
        for _, m in ipairs(mods) do
            if m == "Shift" then
                shift_held = true
                break
            end
        end
        if shift_held then
            awful.client.focus.byidx(-1)
        else
            awful.client.focus.byidx(1)
        end
        if client.focus then
            client.focus:raise()
        end
        window_switcher_box.widget = draw_widget(mouse_keys)
    elseif keyboard_keys[key] then
        keyboard_keys[key]()
    end
end)

        window_switcher_box.widget = draw_widget(mouse_keys)
        window_switcher_box.visible = true
    end)
end

return {
    enable = enable,
}
