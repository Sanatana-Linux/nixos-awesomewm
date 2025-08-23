local Gio = require("lgi").require("Gio")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local gtable = require("gears.table")
local gfs = require("gears.filesystem")
local gsurface = require("gears.surface")
local modules = require("modules")
local anim = require("modules.animations")
local text_icons = beautiful.text_icons
local dpi = beautiful.xresources.apply_dpi
local lua_escape = require("lib").lua_escape
local is_supported = require("lib").is_supported
local table_to_file = require("lib").table_to_file
local capi = { screen = screen }
local powermenu = require("ui.popups.powermenu").get_default()
local menubar = require("menubar")
local crop_surface = require("modules.crop_surface")
local lockscreen = require("ui.lockscreen")
local launcher = {}
local shapes = require("modules.shapes.init")
local backdrop = require("modules.backdrop")

local function launch_app(app)
    if not app then
        return
    end
    local desktop_app_info = Gio.DesktopAppInfo.new(Gio.AppInfo.get_id(app))
    local term_needed = Gio.DesktopAppInfo.get_string(
        desktop_app_info,
        "Terminal"
    ) == "true" and true or false
    local term = Gio.AppInfo.get_default_for_uri_scheme("terminal")

    awful.spawn(
        term_needed
                and term
                and string.format(
                    "%s -e %s",
                    term:get_executable(),
                    app:get_executable()
                )
            or string.match(app:get_executable(), "^env") and string.gsub(
                app:get_commandline(),
                "%%%a",
                ""
            )
            or app:get_executable()
    )
end

local function filter_apps(apps, query)
    query = lua_escape(query)
    local filtered = {}
    local filtered_any = {}

    for _, app in ipairs(apps) do
        if app:should_show() then
            local name_match = string.lower(
                string.sub(app:get_name(), 1, string.len(query))
            ) == string.lower(query)
            local name_match_any =
                string.match(string.lower(app:get_name()), string.lower(query))
            local exec_match_any = string.match(
                string.lower(app:get_executable()),
                string.lower(query)
            )

            if name_match then
                table.insert(filtered, app)
            elseif name_match_any or exec_match_any then
                table.insert(filtered_any, app)
            end
        end
    end

    table.sort(filtered, function(a, b)
        return string.lower(a:get_name()) < string.lower(b:get_name())
    end)

    table.sort(filtered_any, function(a, b)
        return string.lower(a:get_name()) < string.lower(b:get_name())
    end)

    for i = 1, #filtered_any do
        filtered[#filtered + 1] = filtered_any[i]
    end

    return filtered
end

function launcher:next()
    local wp = self._private
    if #wp.filtered > 1 and wp.select_index ~= #wp.filtered then
        wp.select_index = wp.select_index + 1
        if wp.select_index > wp.start_index + wp.rows - 1 then
            wp.start_index = wp.start_index + 1
        end
    else
        wp.select_index = 1
        wp.start_index = 1
    end
end

function launcher:back()
    local wp = self._private
    if #wp.filtered > 1 and wp.select_index ~= 1 then
        wp.select_index = wp.select_index - 1
        if wp.select_index < wp.start_index then
            wp.start_index = wp.start_index - 1
        end
    else
        wp.select_index = #wp.filtered
        if #wp.filtered < wp.rows then
            wp.start_index = 1
        else
            wp.start_index = #wp.filtered - wp.rows + 1
        end
    end
end

function launcher:update_entries()
    local wp = self._private
    local entries_container =
        self.widget:get_children_by_id("entries-container")[1]
    entries_container:reset()

    if #wp.filtered > 0 then
        for i, app in ipairs(wp.filtered) do
            if i >= wp.start_index and i <= wp.start_index + wp.rows - 1 then
                local desktop_info = Gio.DesktopAppInfo.new(app:get_id())
                local icon_name = desktop_info
                        and desktop_info:get_string("Icon")
                    or app:get_name()

                local icon_path = menubar.utils.lookup_icon(icon_name)
                    or menubar.utils.lookup_icon("application-x-executable")

                local entry_widget = wibox.widget({
                    widget = wibox.container.background,
                    forced_height = dpi(60),
                    shape = shapes.rrect(10),
                    {
                        widget = wibox.container.margin,
                        margins = { left = dpi(25), right = dpi(25) },
                        {
                            layout = wibox.layout.align.horizontal,
                            expand = "none",
                            {
                                layout = wibox.layout.fixed.horizontal,
                                spacing = dpi(15),
                                {
                                    widget = wibox.container.place,
                                    valign = "center",
                                    halign = "center",
                                    {
                                        widget = wibox.widget.imagebox,
                                        image = icon_path,
                                        resize = true,
                                        forced_width = dpi(32),
                                        forced_height = dpi(32),
                                    },
                                },
                                {
                                    layout = wibox.layout.fixed.vertical,
                                    {
                                        widget = wibox.container.margin,
                                        top = dpi(15),
                                        nil,
                                    },
                                    {
                                        widget = wibox.container.constraint,
                                        strategy = "max",
                                        height = 25,
                                        {
                                            widget = wibox.widget.textbox,
                                            markup = app:get_name(),
                                        },
                                    },
                                    app:get_description()
                                        and {
                                            widget = wibox.container.constraint,
                                            strategy = "max",
                                            height = 25,
                                            {
                                                widget = wibox.widget.textbox,
                                                font = beautiful.font_h0,
                                                markup = app:get_description(),
                                            },
                                        },
                                },
                            },
                        },
                    },
                })

                entry_widget:buttons({
                    awful.button({}, 1, function()
                        if wp.select_index == i then
                            launch_app(app)
                            self:hide()
                        else
                            wp.select_index = i
                            self:update_entries()
                        end
                    end),
                })

                if i == wp.select_index then
                    entry_widget:set_bg(beautiful.bg_urg)
                    entry_widget:set_fg(beautiful.fg)
                else
                    entry_widget:connect_signal("mouse::enter", function(w)
                        w:set_bg(beautiful.bg_urg)
                    end)

                    entry_widget:connect_signal("mouse::leave", function(w)
                        w:set_bg(nil)
                    end)
                end

                entries_container:add(entry_widget)
            end
        end
    else
        entries_container:add(wibox.widget({
            widget = wibox.container.background,
            forced_height = dpi(200),
            fg = beautiful.fg_alt,
            {
                widget = wibox.widget.textbox,
                font = beautiful.font_name .. "24",
                align = "center",
                markup = "No match found",
            },
        }))
    end
end

function launcher:show()
    local wp = self._private
    if wp.shown then
        return
    end
    wp.shown = true

    backdrop.show(self)

    wp.unfiltered = Gio.AppInfo.get_all()
    wp.filtered = filter_apps(wp.unfiltered, "")
    wp.start_index, wp.select_index = 1, 1
    self:update_entries()
    self.widget:get_children_by_id("text-input")[1]:focus()

    self.opacity = 0
    self.visible = true
    self:emit_signal("widget::layout_changed") -- Force layout update to get geometry

    local final_y = self.y
    local start_y = final_y + dpi(20)
    self.y = start_y

    anim.animate({
        start = 0,
        target = 1,
        duration = 0.3,
        easing = anim.easing.quadratic,
        update = function(progress)
            self.opacity = progress
            self.y = start_y + (final_y - start_y) * progress
        end,
        complete = function()
            self:emit_signal("property::shown", wp.shown)
        end,
    })
end

function launcher:hide()
    local wp = self._private
    if not wp.shown then
        return
    end
    wp.shown = false

    backdrop.hide()

    wp.unfiltered = {}
    wp.filtered = {}
    wp.select_index, wp.select_index = 1, 1
    self.widget:get_children_by_id("text-input")[1]:unfocus()

    local start_y = self.y
    local final_y = start_y + dpi(20)

    anim.animate({
        start = 1,
        target = 0,
        duration = 0.3,
        easing = anim.easing.quadratic,
        update = function(progress)
            self.opacity = progress
            self.y = final_y - (final_y - start_y) * progress
        end,
        complete = function()
            self.visible = false
            self:emit_signal("property::shown", wp.shown)
        end,
    })
end

function launcher:toggle()
    if not self.visible then
        self:show()
    else
        self:hide()
    end
end

local function new()
    local ret = awful.popup({
        ontop = true,
        visible = false,
        screen = capi.screen.primary,
        bg = "#00000000",
        placement = function(d)
            awful.placement.bottom_left(d, {
                honor_workarea = true,
                margins = beautiful.useless_gap,
            })
        end,
        widget = {
            widget = wibox.container.background,
            bg = beautiful.bg .. "cc",
            border_width = beautiful.border_width,
            border_color = beautiful.border_color_normal,
            shape = shapes.rrect(18),
            {
                widget = wibox.container.margin,
                margins = dpi(10),
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(6),
                    fill_space = true,
                    {
                        widget = wibox.container.background,
                        forced_width = dpi(50),
                        bg = beautiful.bg_alt .. "99",
                        border_width = beautiful.border_width,
                        border_color = beautiful.border_color_normal,

                        shape = shapes.rrect(10),
                        {
                            layout = wibox.layout.align.vertical,
                            nil,
                            {
                                layout = wibox.layout.fixed.vertical,
                                spacing = beautiful.separator_thickness
                                    + dpi(2),
                                spacing_widget = {
                                    widget = wibox.container.margin,
                                    margins = {
                                        left = dpi(8),
                                        right = dpi(8),
                                    },
                                    {
                                        widget = wibox.widget.separator,
                                        orientation = "horizontal",
                                    },
                                },
                            },
                            {
                                {
                                    id = "lock-button",
                                    widget = modules.hover_button({
                                        label = text_icons.lock_on,
                                        forced_width = dpi(50),
                                        forced_height = dpi(50),
                                        fg_normal = beautiful.fg,
                                        bg_hover = beautiful.bg_gradient_button_alt,
                                        shape = shapes.rrect(10),
                                    }),
                                },

                                {
                                    id = "powermenu-button",
                                    widget = modules.hover_button({
                                        label = text_icons.poweroff,
                                        forced_width = dpi(50),
                                        forced_height = dpi(50),
                                        fg_normal = beautiful.red,
                                        bg_hover = "linear:0,0:0,32:0,"
                                            .. beautiful.red
                                            .. ":1,"
                                            .. "#b61442",
                                        shape = shapes.rrect(10),
                                    }),
                                },
                                layout = wibox.layout.fixed.vertical,
                                spacing = dpi(12),
                            },
                        },
                    },
                    {
                        layout = wibox.layout.fixed.vertical,
                        spacing = dpi(3),
                        {
                            layout = wibox.layout.fixed.vertical,
                            {
                                layout = wibox.layout.stack,
                                border_width = beautiful.border_width,
                                border_color = beautiful.border_color_normal,

                                {
                                    image = crop_surface(
                                        3.42,
                                        gears.surface.load_uncached(
                                            beautiful.wallpaper
                                        )
                                    ),
                                    opacity = 0.75,
                                    forced_height = dpi(140),
                                    clip_shape = shapes.rrect(10),
                                    forced_width = dpi(440),
                                    widget = wibox.widget.imagebox,
                                },

                                {
                                    widget = wibox.container.margin,
                                    forced_width = 1,
                                    forced_height = dpi(50),
                                    margins = {
                                        left = dpi(10),
                                        right = dpi(10),
                                    },
                                    {
                                        widget = wibox.container.place,
                                        halign = "left",
                                        valign = "center",
                                        {
                                            widget = wibox.container.constraint,
                                            strategy = "max",
                                            height = dpi(25),
                                            {
                                                id = "text-input",
                                                widget = modules.text_input({
                                                    placeholder = "Search...",
                                                    cursor_bg = beautiful.fg,
                                                    cursor_fg = beautiful.bg,
                                                    placeholder_fg = beautiful.fg_alt,
                                                }),
                                            },
                                        },
                                    },
                                },
                            },
                            {
                                widget = wibox.container.background,
                                forced_width = 1,
                                forced_height = beautiful.separator_thickness,
                                {
                                    widget = wibox.widget.separator,
                                    orientation = "horizontal",
                                },
                            },
                        },
                        {
                            id = "entries-container",
                            layout = wibox.layout.fixed.vertical,
                            spacing = dpi(3),
                            forced_width = dpi(300),
                        },
                    },
                },
            },
        },
    })

    gtable.crush(ret, launcher, true)
    local wp = ret._private

    wp.rows = 6

    local powermenu_button =
        ret.widget:get_children_by_id("powermenu-button")[1]
    powermenu_button:buttons({
        awful.button({}, 1, function()
            powermenu:show()
        end),
    })

    local lock_button = ret.widget:get_children_by_id("lock-button")[1]
    lock_button:buttons({
        awful.button({}, 1, function()
            awful.spawn("bin/glitchlock.sh")
        end),
    })

    local entries_container =
        ret.widget:get_children_by_id("entries-container")[1]
    entries_container:set_forced_height(
        dpi(60) * wp.rows + dpi(3) * (wp.rows - 1)
    )

    entries_container:buttons({
        awful.button({}, 4, function()
            ret:back()
            ret:update_entries()
        end),
        awful.button({}, 5, function()
            ret:next()
            ret:update_entries()
        end),
    })

    local text_input = ret.widget:get_children_by_id("text-input")[1]
    text_input:on_focused(function()
        text_input:set_input("")
        text_input:set_cursor_index(1)
    end)

    text_input:on_unfocused(function()
        ret:hide()
    end)

    text_input:on_input_changed(function(_, input)
        wp.filtered = filter_apps(wp.unfiltered, input)
        wp.start_index, wp.select_index = 1, 1
        ret:update_entries()
    end)

    text_input:on_executed(function()
        local app = wp.filtered[wp.select_index]
        if app then
            launch_app(app)
        end
    end)

    text_input:on_key_pressed(function(_, _, key)
        if key == "Down" then
            ret:next()
            ret:update_entries()
        elseif key == "Up" then
            ret:back()
            ret:update_entries()
        end
    end)

    return ret
end

local instance = nil
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
