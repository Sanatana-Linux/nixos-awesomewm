---@diagnostic disable: undefined-global
--            __ __
-- .--.--.--.|__|  |--.---.-.----.
-- |  |  |  ||  |  _  |  _  |   _|
-- |________||__|_____|___._|__|
-- -------------------------------------------------------------------------- --

local searchbar = require("ui.bar.widgets.searchbox")
local network = require("ui.bar.actions-icons.network")
local volume = require("ui.bar.actions-icons.volume")
local get_screenshot_icon = require("ui.bar.actions-icons.screenshot")
-- local get_notification_icon = require("ui.bar.actions-icons.notifications")
local battery_widget = require("ui.bar.widgets.battery")
local launcher = require("ui.launcher")
require("ui.bar.widgets.calendar")
require("ui.bar.widgets.tray")
require("ui.popups.network")
require("ui.popups.notification_center")

-- -------------------------------------------------------------------------- --
-- assign to each screen
screen.connect_signal("request::desktop_decoration", function(s)
    -- -------------------------------------------------------------------------- --
    --                                    tags                                    --
    -- -------------------------------------------------------------------------- --
    --
    awful.tag({ "1", "2", "3", "4", "5", "6" }, s, awful.layout.layouts[1])
    local get_tags = require("ui.bar.widgets.tags")
    local taglist = get_tags(s)

    -- -------------------------------------------------------------------------- --
    --                                  launcher                                  --
    -- -------------------------------------------------------------------------- --
    --
    local launcher = utilities.widgets.mkbtn({
        image = beautiful.launcher_icon,
        screen = s,
        forced_height = dpi(28),
        forced_width = dpi(28),
        bg = beautiful.widget_back,
        halign = "center",
        valign = "center",
        widget = wibox.widget.imagebox,
    }, beautiful.widget_back, beautiful.widget_back_focus)

    local launcher_tooltip = utilities.widgets.make_popup_tooltip(
        "Left Click to Search Applications; Right Click for Notifications",
        function(d)
            return awful.placement.bottom_left(d, {
                margins = {
                    bottom = beautiful.bar_height + beautiful.useless_gap * 2,
                    left = beautiful.useless_gap * 2,
                },
            })
        end
    )

    launcher_tooltip.attach_to_object(launcher)

    launcher:add_button(awful.button({}, 1, function()
        launcher_tooltip.hide()
        awesome.emit_signal("toggle::launcher")
        if launcher.launcherdisplay.visible == true then
            awful.keyboard.emulate_key_combination({}, "Escape")
        end
    end))
    launcher:add_button(awful.button({}, 3, function()
        launcher_tooltip.hide()
        no_toggle(s)
    end))

    -- -------------------------------------------------------------------------- --
    --                                   systray                                  --
    -- -------------------------------------------------------------------------- --
    --
    local tray_dispatcher = wibox.widget({
        image = beautiful.tray_chevron_up,
        forced_height = dpi(15),
        forced_width = dpi(15),
        valign = "center",
        halign = "center",
        widget = wibox.widget.imagebox,
    })

    local tray_dispatcher_tooltip = utilities.widgets.make_popup_tooltip(
        "Press to toggle the systray panel",
        function(d)
            return awful.placement.bottom_right(d, {
                margins = {
                    bottom = beautiful.bar_height + beautiful.useless_gap * 2,
                    right = beautiful.useless_gap * 33,
                },
            })
        end
    )

    tray_dispatcher:add_button(awful.button({}, 1, function()
        awesome.emit_signal("tray::toggle")
        tray_dispatcher_tooltip.hide()

        if s.tray.popup.visible then
            tray_dispatcher.image = beautiful.tray_chevron_down
        else
            tray_dispatcher.image = beautiful.tray_chevron_up
        end
    end))

    tray_dispatcher_tooltip.attach_to_object(tray_dispatcher)
    -- -------------------------------------------------------------------------- --
    --                               action buttons                               --
    -- -------------------------------------------------------------------------- --
    -- make screenshot action icon global to edit it in anothers contexts.
    s.myscreenshot_action_icon = get_screenshot_icon(s)
    local actions_icons_container = utilities.widgets.mkbtn({
        {
            network,
            volume,
            s.myscreenshot_action_icon,
            spacing = dpi(4),
            layout = wibox.layout.fixed.horizontal,
        },
        left = dpi(5),
        right = dpi(5),
        widget = wibox.container.margin,
    }, beautiful.widget_back, beautiful.widget_back_focus)

    -- -------------------------------------------------------------------------- --
    --                                    clock                                   --
    -- -------------------------------------------------------------------------- --
    local clock_formats = { hour = "%H:%M", day = "%d/%m/%Y" }

    local clock = wibox.widget({
        format = clock_formats.hour,
        font = beautiful.title_font,
        widget = wibox.widget.textclock,
    })

    local date = wibox.widget({
        {
            {
                widget = wibox.container.margin,
                left = dpi(15),
                right = dpi(15),
                clock,
            },
            fg = beautiful.fg_normal,
            bg = beautiful.widget_back,
            border_width = 0.75,
            border_color = beautiful.grey,
            widget = wibox.container.background,
            shape = utilities.widgets.mkroundedrect(),
        },
        left = dpi(3),
        right = dpi(3),
        widget = wibox.container.margin,
    })

    date:connect_signal("mouse::enter", function()
        awesome.emit_signal("calendar::visibility", true)
    end)

    date:connect_signal("mouse::leave", function()
        awesome.emit_signal("calendar::visibility", false)
    end)

    date:add_button(awful.button({}, 1, function()
        clock.format = clock.format == clock_formats.hour and clock_formats.day
            or clock_formats.hour
    end))
    -- -------------------------------------------------------------------------- --
    --                                 layout box                                 --
    -- -------------------------------------------------------------------------- --
    --
    local base_layoutbox = awful.widget.layoutbox({
        screen = s,
        halign = "center",
        valign = "center",
    })

    -- remove built-in tooltip.
    base_layoutbox._layoutbox_tooltip:remove_from_object(base_layoutbox)

    -- create button container
    local layoutbox = utilities.widgets.mkbtn({
        widget = wibox.container.margin,
        left = dpi(5),
        right = dpi(5),
        base_layoutbox,
    }, beautiful.widget_back, beautiful.widget_back_focus)

    -- capitalize the layout name for consistency
    local function layoutname()
        return "Layout: "
            .. utilities.textual.capitalize(awful.layout.get(s).name)
    end

    -- make custom tooltip for the whole button
    local layoutbox_tooltip = utilities.widgets.make_popup_tooltip(
        layoutname(),
        function(d)
            return awful.placement.bottom_right(d, {
                margins = {
                    bottom = beautiful.bar_height + beautiful.useless_gap * 2,
                    right = beautiful.useless_gap * 2,
                },
            })
        end
    )

    layoutbox_tooltip.attach_to_object(layoutbox)

    -- updates tooltip content
    local update_content = function()
        layoutbox_tooltip.widget.text = layoutname()
        naughty.notification({
            title = "Layout Changed",
            text = "The current tag has had the client layout changed to the "
                .. layoutbox_tooltip.widget.text
                .. " layout.",
            image = gfs.get_configuration_dir()
                .. "themes/icons/svg/awesome.png",
        })
    end

    tag.connect_signal("property::layout", update_content)
    tag.connect_signal("property::selected", update_content)

    -- layoutbox buttons
    utilities.widgets.add_buttons(layoutbox, {
        awful.button({}, 1, function()
            awesome.emit_signal("layout::changed:next")
        end),
        awful.button({}, 3, function()
            awesome.emit_signal("layout::changed:prev")
        end),
    })

    -- -------------------------------------------------------------------------- --
    --                               widget templates                              --
    -- -------------------------------------------------------------------------- --
    --
    local function mkcontainer(template)
        return wibox.widget({
            template,
            left = dpi(8),
            right = dpi(8),
            top = dpi(6),
            bottom = dpi(6),
            widget = wibox.container.margin,
        })
    end

    s.mywibox = awful.wibar({
        honor_workarea = false,
        honor_padding = false,
        type = "dock",
        position = "bottom",
        stretch = false,
        visible = false,
        ontop = true,
        opacity = 0.9,
        screen = s,
        bg = beautiful.bg_darkest .. "66",
        width = s.geometry.width,
        height = beautiful.bar_height,
        shape = gears.shape.rectangle,
    })
    -- -------------------------------------------------------------------------- --
    --                                    setup                                   --

    s.mywibox:setup({
        {
            layout = wibox.layout.align.horizontal,
            {
                {
                    mkcontainer({
                        launcher,

                        spacing = dpi(12),
                        layout = wibox.layout.fixed.horizontal,
                    }),
                    widget = wibox.container.margin,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            nil,
            {
                mkcontainer({
                    {
                        tray_dispatcher,
                        right = dpi(8),
                        widget = wibox.container.margin,
                    },
                    battery_widget,
                    actions_icons_container,
                    date,
                    layoutbox,
                    spacing = dpi(8),
                    layout = wibox.layout.fixed.horizontal,
                }),
                layout = wibox.layout.fixed.horizontal,
            },
        },
        {
            mkcontainer({ taglist, layout = wibox.layout.fixed.horizontal }),
            halign = "center",
            widget = wibox.widget.margin,
            layout = wibox.container.place,
        },
        layout = wibox.layout.stack,
    })
    s.mywibox:struts({ left = 0, right = 0, bottom = 0, top = 0 })

    -- -------------------------------------------------------------------------- --
    --
    -- NOTE  toggle function to make it disappear
    --
    function bar_toggle()
        if s.mywibox.visible == false then
            awful.screen.connect_for_each_screen(function()
                s.mywibox.visible = true
                s.mywibox.status = true
                s.activation_zone.visible = false
            end)
        elseif s.mywibox.visible == true then
            awful.screen.connect_for_each_screen(function()
                s.mywibox.visible = false
                s.mywibox.status = false
                s.activation_zone.visible = true
            end)
        end
    end

    local hidden_y = awful.screen.focused().geometry.height
    -- ------------------------------------------------- --
    -- NOTE  setting its height
    --
    local visible_y = awful.screen.focused().geometry.height - s.mywibox.height
    -- ------------------------------------------------- --

    -- NOTE defining the anotation
    local animation = rubato.timed({
        intro = 0.3,
        outro = 0.2,
        duration = 0.6,
        pos = hidden_y,
        rate = 80,
        easing = rubato.quadratic,
        subscribed = function(pos)
            s.mywibox.y = pos
        end,
    })

    -- ------------------------------------------------- --
    -- ------------ auto hide functionality ------------ --
    --  NOTE  timer to close the bar
    --
    s.detect = gears.timer({
        timeout = 3,
        single_shot = true,

        callback = function()
            animation.target = hidden_y
            s.disable_wibar:start()
            awesome.emit_signal("bar:false")
        end,
    })

    s.disable_wibar = gears.timer({
        autostart = true,
        timeout = 0.6,
        callback = function()
            s.mywibox.visible = false
            s.mywibox.status = false
            s.activation_zone.visible = true
            s.detect:stop()
            s.disable_wibar:stop()
        end,
    })

    -- ------------------------------------------------- --
    --  NOTE  shows the bar open
    --
    s.enable_wibox = function()
        s.mywibox.visible = true
        s.activation_zone.visible = false
        animation.target = visible_y
        awesome.emit_signal("bar:true")
        s.detect:start()
    end
    -- ------------------------------------------------- --
    --  NOTE  if the bar is not present, this is
    --
    s.activation_zone = awful.wibar({
        x = s.mywibox.x,
        y = s.geometry.height - dpi(1),
        position = "bottom",
        opacity = 0.0,
        width = s.mywibox.width,
        height = dpi(1),
        screen = s,
        input_passthrough = false,
        visible = true,
        ontop = true,
        type = "dock",
    })
    s.activation_zone:struts({ left = 0, right = 0, bottom = 0, top = 0 })

    -- ------------------------------------------------- --
    --  NOTE  when mouse moves to this bar, the other opens
    --
    s.activation_zone:connect_signal("mouse::enter", function()
        s.enable_wibox()
    end)
    -- ------------------------------------------------- --
    --  NOTE this keeps the bar open so long is the mouse is within its boundaries so the other can be hidden
    --
    s.mywibox:connect_signal("mouse::enter", function()
        s.detect:stop()
    end)
    -- ------------------------------------------------- --
    --  NOTE this keeps the bar open so long is the mouse is within its boundaries so the other can be hidden
    --
    s.mywibox:connect_signal("button::press", function()
        s.enable_wibox()
    end)
    -- ------------------------------------------------- --
    --  NOTE this keeps the bar open so long is the mouse is within its boundaries so the other can be hidden
    --
    s.mywibox:connect_signal("button::release", function()
        s.enable_wibox()
    end)
    -- ------------------------------------------------- --
    --  NOTE signals to begin timer when mouse leaves
    --
    s.mywibox:connect_signal("mouse::leave", function()
        s.detect:start()
    end)
    awesome.connect_signal("bar::toggle", function()
        bar_toggle()
        s.enable_wibox()
    end)
end)
