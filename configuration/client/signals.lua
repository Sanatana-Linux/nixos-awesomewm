---@diagnostic disable: undefined-global
local awful = require("awful")
local beautiful = require("beautiful")
local shapes = require("modules.shapes")
local dpi = beautiful.xresources.apply_dpi
local capi = { client = client, tag = tag, mouse = mouse }
local awesome = awesome

require("awful.autofocus")

local function center_and_keep_on_screen(c, opts)
    local default_opts = { honor_workarea = true, honor_padding = true }
    local placement_opts = opts or default_opts

    awful.placement.centered(c, placement_opts)

    local offscreen_opts = {}
    if opts then
        offscreen_opts.honor_workarea = opts.honor_workarea
        offscreen_opts.honor_padding = opts.honor_padding
    else
        offscreen_opts = default_opts
    end

    awful.placement.no_offscreen(c, offscreen_opts)
end

capi.client.connect_signal("request::manage", function(c)
    if c.fullscreen then
        c:geometry(c.screen.geometry)
    elseif c.maximized then
        local workarea = c.screen.workarea
        c:geometry({
            x = workarea.x + dpi(3),
            y = workarea.y + dpi(3),
            width = workarea.width - dpi(6),
            height = workarea.height - dpi(6),
        })
    elseif c.transient_for and not c.disallow_autocenter then
        awful.placement.centered(c, { parent = c.transient_for })
        awful.placement.no_offscreen(c)
    end
end)

local function activate_under_pointer()
    local c = capi.mouse.current_client
    if c then
        c:activate({ context = "mouse_enter", raise = false })
    end
end

local gears = require("gears")

local window_switcher_active = false
awesome.connect_signal("window_switcher::turn_on", function()
    window_switcher_active = true
end)
awesome.connect_signal("window_switcher::turn_off", function()
    window_switcher_active = false
end)

local function activate_under_pointer()
    if window_switcher_active then return end
    local c = capi.mouse.current_client
    if c then
        c:activate({ context = "mouse_enter", raise = false })
    end
end

local focus_timer = gears.timer({
    autostart = true,
    timeout = 0.2,
    single_shot = true,
    callback = activate_under_pointer,
})

local function start_focus_timer()
    focus_timer:start()
end

capi.client.connect_signal("mouse::enter", activate_under_pointer)
capi.tag.connect_signal("property::selected", start_focus_timer)
capi.client.connect_signal("request::unmanage", start_focus_timer)
capi.client.connect_signal("property::tags", function(c)
    if not c.floating then
        start_focus_timer()
    end
end)

capi.client.connect_signal("manage", function(c)
    if not c.floating then
        awful.client.setslave(c)
    end
    if
        awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position
    then
        awful.placement.no_offscreen(c)
    end
end)

local function focus_back()
    local s = awful.screen.focused()
    local c = awful.client.focus.history.get(s, 0)
    if c and c.valid then
        -- Move mouse to last focused client instead of raising it
        local geo = c:geometry()
        capi.mouse.coords({
            x = geo.x + geo.width / 2,
            y = geo.y + geo.height / 2,
        })
        c:activate({ context = "key.unminimize", raise = false })
    end
end

capi.client.connect_signal("property::minimized", focus_back)
capi.client.connect_signal("unmanage", focus_back)
capi.tag.connect_signal("property::selected", focus_back)

local function update_client_shape(c)
    if c.maximized or c.fullscreen then
        c.shape = nil
    else
        c.shape = shapes.rrect(dpi(12))
    end
end

capi.client.connect_signal("manage", update_client_shape)
capi.client.connect_signal("property::maximized", function(c)
    update_client_shape(c)
    if c.maximized then
        local workarea = c.screen.workarea
        c:geometry({
            x = workarea.x + dpi(3),
            y = workarea.y + dpi(3),
            width = workarea.width - dpi(6),
            height = workarea.height - dpi(6),
        })
    end
end)
capi.client.connect_signal("property::fullscreen", update_client_shape)
capi.client.connect_signal("property::geometry", function(c)
    gears.timer.delayed_call(function()
        if c.valid then
            update_client_shape(c)
        end
    end)
end)

local type_opacity = {
    tooltip = 1.0,
    dock = 1.0,
    popup_menu = 0.95,
    dropdown_menu = 0.9,
    normal = 0.95,
}

local class_opacity = {
    i3lock = 1.0,
    Dunst = 0.6,
    awesome = 0.95,
}

local class_focused_opacity = {
    kitty = 0.85,
}

local class_unfocused_opacity = {
    kitty = 0.80,
}

local function apply_opacity(c)
    if c.type == "desktop" then
        return
    end

    local type_val = type_opacity[c.type]
    if type_val then
        c.opacity = type_val
        if c.type == "dock" then
            c.shape = nil
        end
        return
    end

    local class_val = class_opacity[c.class]
    if class_val then
        c.opacity = class_val
        return
    end

    local focused_val = class_focused_opacity[c.class]
    local unfocused_val = class_unfocused_opacity[c.class]
    if focused_val then
        c.opacity = c.focused and focused_val or unfocused_val
        return
    end

    c.opacity = c.focused and (beautiful.active_opacity or 1.0)
        or (beautiful.inactive_opacity or 0.90)
end

capi.client.connect_signal("manage", apply_opacity)
capi.client.connect_signal("focus", apply_opacity)
capi.client.connect_signal("unfocus", apply_opacity)

return {
    center_and_keep_on_screen = center_and_keep_on_screen,
}
