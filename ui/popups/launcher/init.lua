--- Application launcher popup.
-- Search-driven popup with keyboard navigation. Reads the user's desktop
-- apps at show time and caches them for fast subsequent filtering. Apps
-- designated as Terminal=true in their .desktop file get spawned inside
-- kitty. Backs Mod4+Shift+Return (launcher.lua keybinding).
--
-- App discovery and filtering live in apps.lua; launch history tracking
-- lives in history.lua. The powermenu dependency is decoupled via the
-- "launcher::power-clicked" signal — wire it from ui/init.lua.
-- @module ui.popups.launcher

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local gtimer = require("gears.timer")
local gtable = require("gears.table")
local gfs = require("gears.filesystem")
local gsurface = require("gears.surface")
local gcolor = require("gears.color")
local color_alpha = require("lib.util").color_alpha
local lua_escape = require("lib.util").lua_escape
local modules = require("modules")
local anim = require("modules.infra.animations")
local dpi = beautiful.xresources.apply_dpi
local capi = { screen = screen }
local apps = require("ui.popups.launcher.apps")
local history = require("ui.popups.launcher.history")
local icon_lookup = require("modules.icon_lookup")
local crop_surface = require("modules.style.crop_surface")
local click_to_hide = require("modules.infra.click_to_hide")
local shapes = require("modules.style.shapes.init")

local launcher = {}

local lock_icon_path = gfs.get_configuration_dir()
    .. "ui/popups/launcher/icons/lock-line.svg"
local power_icon_path = gfs.get_configuration_dir()
    .. "ui/popups/launcher/icons/shut-down-line-fg.svg"
local power_icon_black_path = gfs.get_configuration_dir()
    .. "ui/popups/launcher/icons/shut-down-line-black.svg"

--- Move selection to the next entry. Wraps to the top and resets the
-- scroll offset when pressing Down at the last entry.
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

--- Move selection to the previous entry. Wraps to the bottom at the top.
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

--- Rebuild the entries container widget from the current wp.filtered
-- list. Called after any change to the filtered set (text input, scroll,
-- selection).
function launcher:update_entries()
    local wp = self._private
    local entries_container =
        self.widget:get_children_by_id("entries-container")[1]
    entries_container:reset()

    if #wp.filtered > 0 then
        for i, app in ipairs(wp.filtered) do
            if i >= wp.start_index and i <= wp.start_index + wp.rows - 1 then
                -- Use placeholder icon initially for fast rendering
                local placeholder_icon = icon_lookup.get_fallback_icon()

                -- Create imagebox widget that we can update later
                local icon_widget = wibox.widget({
                    widget = wibox.widget.imagebox,
                    image = placeholder_icon,
                    resize = true,
                    forced_width = dpi(32),
                    forced_height = dpi(32),
                })

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
                                    icon_widget,
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
                                                    markup = '<span size="smaller">'
                                                        .. lua_escape(
                                                            app:get_description()
                                                        )
                                                        .. "</span>",
                                                },
                                            }
                                        or nil,
                                },
                            },
                        },
                    },
                })

                -- Set selection background
                if i == wp.select_index then
                    entry_widget.bg = beautiful.blue .. "55"
                end

                -- Add click handler with history recording
                entry_widget:connect_signal(
                    "button::press",
                    function(_, _, _, button)
                        if button == 1 then
                            history.record_launch(app:get_id())
                            apps.launch(app)
                            self:hide()
                        end
                    end
                )

                entries_container:add(entry_widget)

                -- Load real icon asynchronously after widget is added
                gtimer.delayed_call(function()
                    local icon_path = icon_lookup.get_app_icon(app)
                    if icon_path and icon_path ~= "" then
                        icon_widget.image = icon_path
                    end
                end)
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

--- Show the launcher. Idempotent. Resets the visible entry list to the
-- pre-filtered unfiltered apps and clears the search input before
-- starting the keyboard grabber and rebuilding the entry widget tree.
function launcher:show()
    local wp = self._private
    if wp.shown then
        return
    end

    wp.shown = true

    -- Reset to show all apps (lightweight filtering)
    wp.filtered = apps.filter(wp.unfiltered, "", history.make_sort_fn())
    wp.start_index, wp.select_index = 1, 1

    -- Reset text input (lightweight)
    local text_input = self.widget:get_children_by_id("text-input")[1]
    text_input:set_input("")
    text_input:set_cursor_index(1)

    -- Update entries with pre-loaded data (much faster now)
    self:update_entries()

    self.opacity = 0
    self.visible = true

    gtimer.delayed_call(function()
        -- Ensure placement happens before animation
        if self.placement then
            self.placement(self)
        end

        gtimer.delayed_call(function()
            self:emit_signal("widget::layout_changed")

            -- Focus text input immediately after becoming visible
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
                    self:emit_signal("property::shown", wp.shown)
                end,
            })
        end)
    end)
end

--- Hide the launcher. Releases the keygrabber.
function launcher:hide()
    local wp = self._private
    if not wp.shown then
        return
    end
    wp.shown = false

    wp.filtered = {}
    wp.start_index, wp.select_index = 1, 1
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

--- Toggle launcher visibility. Backs the Mod4+Shift+Return keybinding.
function launcher:toggle()
    if not self.visible then
        self:show()
    else
        self:hide()
    end
end

--- Construct the launcher popup (used internally by get_default).
-- Builds the full widget tree: sidebar with lock + powermenu buttons,
-- search field, entries container, and signal wiring for
-- keypress / text-input / scroll / click-outside.
-- @treturn table A launcher instance with show/hide/toggle/next/back
local function new()
    local ret = awful.popup({
        ontop = true,
        visible = false,
        screen = capi.screen.primary,
        bg = "#00000000",
        name = "awesome-popup",
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
                        id = "sidebar-strip",
                        border_width = dpi(1),
                        border_color = beautiful.fg .. "33",
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
                                widget = wibox.container.margin,
                                left = dpi(4),
                                right = dpi(4),
                                bottom = dpi(4),
                                {
                                    {
                                        id = "lock-button",
                                        widget = wibox.container.background,
                                        shape = gears.shape.rounded_rect,
                                        forced_width = dpi(40),
                                        forced_height = dpi(40),
                                        border_width = dpi(1),
                                        border_color = beautiful.fg .. "00",
                                        bg = beautiful.bg_gradient_button,
                                        {
                                            widget = wibox.container.place,
                                            halign = "center",
                                            valign = "center",
                                            {
                                                widget = wibox.widget.imagebox,
                                                image = gcolor.recolor_image(
                                                    lock_icon_path,
                                                    beautiful.fg
                                                ),
                                                resize = true,
                                                forced_width = dpi(22),
                                                forced_height = dpi(22),
                                            },
                                        },
                                    },
                                    {
                                        id = "powermenu-button",
                                        widget = wibox.container.background,
                                        shape = gears.shape.rounded_rect,
                                        forced_width = dpi(40),
                                        forced_height = dpi(40),
                                        border_width = dpi(1),
                                        border_color = beautiful.fg .. "00",
                                        bg = beautiful.bg_gradient_button,
                                        {
                                            widget = wibox.container.place,
                                            halign = "center",
                                            valign = "center",
                                            {
                                                id = "power-icon",
                                                widget = wibox.widget.imagebox,
                                                image = power_icon_path,
                                                resize = true,
                                                forced_width = dpi(22),
                                                forced_height = dpi(22),
                                            },
                                        },
                                    },
                                    layout = wibox.layout.fixed.vertical,
                                    spacing = dpi(12),
                                },
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
                                                beautiful.wallpaper_unbranded
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
                                                        font = beautiful.font_name
                                                            .. "14",
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

    local sidebar_strip = ret.widget:get_children_by_id("sidebar-strip")[1]
    sidebar_strip.bg = "linear:0,0:50,0:0,"
        .. beautiful.bg_alt
        .. "aa:0.35,"
        .. beautiful.bg
        .. "77:0.5,"
        .. beautiful.bg
        .. "aa:0.65,"
        .. beautiful.bg
        .. "77:1,"
        .. beautiful.bg_alt
        .. "aa"

    wp.rows = 6

    -- Pre-load apps at initialization to avoid heavy operations during show
    wp.unfiltered = apps.get_all()
    wp.filtered = {}
    wp.start_index, wp.select_index = 1, 1

    -- Powermenu button: emit a custom signal instead of requiring powermenu
    -- directly. Wire this from ui/init.lua.
    local powermenu_button =
        ret.widget:get_children_by_id("powermenu-button")[1]
    local power_icon_widget = ret.widget:get_children_by_id("power-icon")[1]
    powermenu_button:buttons({
        awful.button({}, 1, function()
            ret:emit_signal("launcher::power-clicked")
        end),
    })
    powermenu_button:connect_signal("mouse::enter", function(w)
        w.bg = beautiful.red
        w.border_color = color_alpha(beautiful.fg, "66")
        if power_icon_widget then
            power_icon_widget.image = power_icon_black_path
        end
    end)
    powermenu_button:connect_signal("mouse::leave", function(w)
        w.bg = beautiful.bg_gradient_button
        w.border_color = beautiful.fg .. "00"
        if power_icon_widget then
            power_icon_widget.image = power_icon_path
        end
    end)

    local lock_button = ret.widget:get_children_by_id("lock-button")[1]
    lock_button:buttons({
        awful.button({}, 1, function()
            awesome.emit_signal("lockscreen::visible", true)
        end),
    })
    lock_button:connect_signal("mouse::enter", function(w)
        w.bg = beautiful.bg_gradient_button_alt
        w.border_color = color_alpha(beautiful.fg, "66")
    end)
    lock_button:connect_signal("mouse::leave", function(w)
        w.bg = beautiful.bg_gradient_button
        w.border_color = beautiful.fg .. "00"
    end)

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
        wp.filtered = apps.filter(wp.unfiltered, input, history.make_sort_fn())
        wp.start_index, wp.select_index = 1, 1
        ret:update_entries()
    end)

    text_input:on_executed(function()
        local app = wp.filtered[wp.select_index]
        if app then
            history.record_launch(app:get_id())
            apps.launch(app)
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

    click_to_hide.popup(ret, function()
        ret:hide()
    end, { outside_only = true, exclusive = true })

    return ret
end

--- Singleton accessor: returns (and lazily constructs) the launcher.
-- @treturn table Cached launcher instance (same object on every call)
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
