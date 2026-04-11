local lgi = require("lgi")
local Gio = lgi.Gio
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
local gcolor = require("gears.color")
local lua_escape = require("lib").lua_escape
local is_supported = require("lib").is_supported
local table_to_file = require("lib").table_to_file
local capi = { screen = screen }
local powermenu = require("ui.popups.powermenu").get_default()
local menubar = require("menubar")
local crop_surface = require("modules.crop_surface")
local launcher = {}
local shapes = require("modules.shapes.init")
local backdrop = require("modules.backdrop")

local lock_icon_path = gfs.get_configuration_dir() .. "ui/popups/launcher/icons/lock-line.svg"
local power_icon_path = gfs.get_configuration_dir() .. "ui/popups/launcher/icons/shut-down-line.svg"

local function launch_app(app)
    if not app then
        return
    end

    -- Safely get desktop app info to check terminal requirement
    local term_needed = false
    if Gio.DesktopAppInfo then
        local status, desktop_app_info = pcall(function()
            return Gio.DesktopAppInfo.new(app:get_id())
        end)

        if status and desktop_app_info then
            local term_status, terminal_string = pcall(function()
                return desktop_app_info:get_string("Terminal")
            end)
            if term_status and terminal_string == "true" then
                term_needed = true
            end
        end
    end

    local term_status, term = pcall(function()
        return Gio.AppInfo.get_default_for_uri_scheme("terminal")
    end)
    if not term_status then
        term = nil
    end

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
                -- Safely get icon name from desktop info
                local icon_name = "application-x-executable"
                local icon = nil

                -- Try to get icon directly from app object
                local icon_status, icon_result = pcall(function()
                    return app:get_icon()
                end)

                if icon_status and icon_result then
                    icon = icon_result
                end

                -- If we have a GIcon object, try to get icon names from it
                if icon then
                    local names_status, names = pcall(function()
                        return icon:get_names()
                    end)
                    if names_status and names and names[1] then
                        icon_name = names[1]
                    elseif names_status and names == nil then
                        -- ThemedIcon might return nil for get_names, use tostring
                        local str_status, icon_str = pcall(function()
                            return tostring(icon)
                        end)
                        if str_status and icon_str then
                            icon_name = icon_str
                        end
                    end
                end

                -- Fallback: try to get icon from desktop entry file
                if
                    icon_name == "application-x-executable"
                    and Gio.DesktopAppInfo
                then
                    local desktop_status, desktop_info = pcall(function()
                        return Gio.DesktopAppInfo.new(app:get_id())
                    end)
                    if desktop_status and desktop_info then
                        local icon_str_status, icon_str = pcall(function()
                            return desktop_info:get_string("Icon")
                        end)
                        if icon_str_status and icon_str and icon_str ~= "" then
                            icon_name = icon_str
                        end
                    end
                end

                local icon_path = menubar.utils.lookup_icon(icon_name)
                    or menubar.utils.lookup_icon("application-x-executable")
                    or gfs.get_configuration_dir() .. "themes/yerba_buena/icons/desktop/fallback_icon.svg"

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
                                                font = beautiful.font_name
                                                    .. dpi(9),
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

    -- Show backdrop first
    backdrop.show(self)

    wp.shown = true

    -- Safely get all applications
    local status, apps = pcall(function()
        return Gio.AppInfo.get_all()
    end)
    wp.unfiltered = (status and apps) or {}
    wp.filtered = filter_apps(wp.unfiltered, "")
    wp.start_index, wp.select_index = 1, 1

    -- Reset text input
    local text_input = self.widget:get_children_by_id("text-input")[1]
    text_input:set_input("")
    text_input:set_cursor_index(1)

    self:update_entries()

    self.opacity = 0
    self.visible = true
    self:emit_signal("widget::layout_changed") -- Force layout update to get geometry

    -- Ensure placement happens before animation
    if self.placement then
        self.placement(self)
    end

    -- Focus text input immediately after becoming visible
    local text_input = self.widget:get_children_by_id("text-input")[1]
    text_input:focus()

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
            -- Animation complete
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
            backdrop.hide() -- Hide backdrop when popup hides
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
                                        forced_width = dpi(50),
                                        forced_height = dpi(50),
                                        fg_normal = beautiful.fg,
                                        bg_hover = beautiful.bg_gradient_button_alt,
                                        shape = shapes.rrect(10),
                                        child_widget = {
                                            widget = wibox.container.margin,
                                            margins = dpi(10),
                                            {
                                                widget = wibox.widget.imagebox,
                                                image = gcolor.recolor_image(
                                                    lock_icon_path,
                                                    beautiful.fg
                                                ),
                                                resize = true,
                                            },
                                        },
                                    }),
                                },

                                {
                                    id = "powermenu-button",
                                    widget = modules.hover_button({
                                        forced_width = dpi(50),
                                        forced_height = dpi(50),
                                        fg_normal = beautiful.red,
                                        bg_hover = "linear:0,0:0,32:0,"
                                            .. beautiful.red
                                            .. ":1,"
                                            .. "#b61442",
                                        shape = shapes.rrect(10),
icon_source = power_icon_path,
                icon_normal_color = beautiful.red,
                icon_hover_color = beautiful.bg,
                                        child_widget = {
                                            widget = wibox.container.margin,
                                            margins = dpi(10),
                                            {
                                                widget = wibox.widget.imagebox,
                                                image = gcolor.recolor_image(
                                                    power_icon_path,
                                                    beautiful.red
                                                ),
                                                resize = true,
                                            },
                                        },
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
                                    layout = wibox.layout.stack,
                                    {
                                        image = crop_surface(
                                            3.42,
                                            gears.surface.load_uncached(
                                                beautiful.wallpaper
                                            )
                                        ),
                                        opacity = 0.9,
                                        forced_height = dpi(140),
                                        clip_shape = shapes.rrect(10),
                                        forced_width = dpi(480),
                                        widget = wibox.widget.imagebox,
                                    },
                                    {
                                        widget = wibox.container.place,
                                        halign = "center",
                                        valign = "center",
                                        {
                                            widget = wibox.container.background,
                                            forced_width = dpi(300),
                                            shape = shapes.rrect(8),
                                            bg = beautiful.bg .. "cc",
                                            {
                                                widget = wibox.container.margin,
                                                margins = dpi(20),
                                                {
                                                    id = "text-input",
                                                    widget = modules.text_input({
                                                        placeholder = "Search...",
                                                        background = "transparent",
                                                        cursor_bg = beautiful.bg,
                                                        cursor_fg = beautiful.fg,
                                                        placeholder_fg = beautiful.fg_alt,
                                                        font = beautiful.font_name .. "14",
                                                    }),
                                                },
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
            awful.spawn("/home/tlh/.config/awesome/bin/glitchlock.sh")
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
        -- Text is already cleared in show() method
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
        elseif key == "Escape" then
            ret:hide()
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
