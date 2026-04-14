---@diagnostic disable: undefined-global
-- Application Switcher
-- Enhanced window switcher with previews and thumbnails
-- Based on https://github.com/troglobit/awesome-switcher

local cairo = require("lgi").cairo
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local anim = require("modules.animations")
local backdrop = require("modules.backdrop")
local modules = require("modules")
local shapes = require("modules.shapes")
local icon_lookup = require("modules.icon-lookup") -- Centralized icon resolution
local capi = {
    screen = screen,
    client = client,
    awesome = awesome,
    mouse = mouse,
}

local switcher = {}

-- Settings
local settings = {
    preview_box = true,
    preview_box_bg = beautiful.backdrop_color or beautiful.bg .. "66", -- More transparent (40% opacity instead of 80%)
    preview_box_border = beautiful.border_color_normal or beautiful.fg .. "88",
    preview_box_fps = 30,
    preview_box_delay = 150,
    preview_box_title_font = {beautiful.font_name or "sans", "normal", "normal"},
    preview_box_title_font_size_factor = 0.8,
    preview_box_title_color = {247, 241, 255, 1}, -- beautiful.fg converted to rgba
    client_opacity = false,
    client_opacity_value_selected = 1,
    client_opacity_value_in_focus = 0.5,
    client_opacity_value = 0.5,
    cycle_raise_client = true
}

-- Module state
local preview_wbox = nil
local preview_live_timer = nil
local preview_widgets = {}
local alt_tab_table = {}
local alt_tab_index = 1
local keygrabber_instance = nil
local hover_timer = nil
local hover_target_index = nil

-- Helper function for counting table length
local function table_length(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- Get list of clients for switching
local function get_clients()
    local clients = {}
    local s = awful.screen.focused()
    local idx = 0
    local c = awful.client.focus.history.get(s, idx)

    -- Get focus history for current tag
    while c do
        table.insert(clients, c)
        idx = idx + 1
        c = awful.client.focus.history.get(s, idx)
    end

    -- Find minimized clients not in focus history
    local t = s.selected_tag
    local all = client.get(s)

    for i = 1, #all do
        local c = all[i]
        local ctags = c:tags()
        
        -- Check if client is on current tag
        local is_current_tag = false
        for j = 1, #ctags do
            if t == ctags[j] then
                is_current_tag = true
                break
            end
        end

        if is_current_tag then
            -- Check if client is already in history
            local add_to_table = true
            for k = 1, #clients do
                if clients[k] == c then
                    add_to_table = false
                    break
                end
            end

            if add_to_table then
                table.insert(clients, c)
            end
        end
    end

    return clients
end

-- Populate the alt-tab table
local function populate_alt_tab_table()
    local clients = get_clients()

    -- Restore old client states if they exist
    if table_length(alt_tab_table) > 0 then
        for ci = 1, #clients do
            for ti = 1, #alt_tab_table do
                if alt_tab_table[ti].client == clients[ci] then
                    alt_tab_table[ti].client.opacity = alt_tab_table[ti].opacity
                    alt_tab_table[ti].client.minimized = alt_tab_table[ti].minimized
                    break
                end
            end
        end
    end

    alt_tab_table = {}
    for i = 1, #clients do
        table.insert(alt_tab_table, {
            client = clients[i],
            minimized = clients[i].minimized,
            opacity = clients[i].opacity
        })
    end
end

-- Check if clients have changed
local function clients_have_changed()
    local clients = get_clients()
    return table_length(clients) ~= table_length(alt_tab_table)
end

-- Create preview text for client
local function create_preview_text(client)
    if client.class then
        return " - " .. client.class
    else
        return " - " .. client.name
    end
end

-- Handle client opacity during switching
local function client_opacity()
    if not settings.client_opacity then
        return
    end

    local opacity = settings.client_opacity_value
    if opacity > 1 then
        opacity = 1
    end
    
    for i, data in pairs(alt_tab_table) do
        data.client.opacity = opacity
    end

    if client.focus == alt_tab_table[alt_tab_index].client then
        local opacity_focus_selected = settings.client_opacity_value_selected + settings.client_opacity_value_in_focus
        if opacity_focus_selected > 1 then
            opacity_focus_selected = 1
        end
        client.focus.opacity = opacity_focus_selected
    else
        local opacity_focus = settings.client_opacity_value_in_focus
        if opacity_focus > 1 then
            opacity_focus = 1
        end
        local opacity_selected = settings.client_opacity_value_selected
        if opacity_selected > 1 then
            opacity_selected = 1
        end

        client.focus.opacity = opacity_focus
        alt_tab_table[alt_tab_index].client.opacity = opacity_selected
    end
end

-- Handle hover auto-selection
local function start_hover_timer(target_index)
    -- Stop existing timer if running
    if hover_timer and hover_timer.started then
        hover_timer:stop()
    end
    
    hover_target_index = target_index
    
    -- Create new timer for 2-second delay
    hover_timer = gears.timer({
        timeout = 2.0, -- 2 seconds
        single_shot = true,
        callback = function()
            if hover_target_index and hover_target_index ~= alt_tab_index then
                cycle(hover_target_index - alt_tab_index)
            end
            hover_timer = nil
            hover_target_index = nil
        end,
        autostart = false
    })
    
    hover_timer:start()
end

local function stop_hover_timer()
    if hover_timer and hover_timer.started then
        hover_timer:stop()
    end
    hover_timer = nil
    hover_target_index = nil
end

-- Update preview display
local function update_preview()
    if clients_have_changed() then
        populate_alt_tab_table()
        switcher.preview()
    end

    for i = 1, #preview_widgets do
        preview_widgets[i]:emit_signal("widget::updated")
    end
end

-- Cycle through clients
local function cycle(dir)
    alt_tab_index = alt_tab_index + dir
    if alt_tab_index > #alt_tab_table then
        alt_tab_index = 1
    elseif alt_tab_index < 1 then
        alt_tab_index = #alt_tab_table
    end

    update_preview()
    alt_tab_table[alt_tab_index].client.minimized = false

    if not settings.preview_box and not settings.client_opacity then
        client.focus = alt_tab_table[alt_tab_index].client
    end

    if settings.client_opacity and preview_wbox and preview_wbox.visible then
        client_opacity()
    end

    if settings.cycle_raise_client then
        alt_tab_table[alt_tab_index].client:raise()
    end
end

-- Create the preview display
function switcher.preview()
    if not settings.preview_box then
        return
    end

    -- Initialize preview box if needed
    if not preview_wbox then
        preview_wbox = wibox({
            width = awful.screen.focused().geometry.width,
            border_width = beautiful.border_width or dpi(3),
            ontop = true,
            visible = false,
            type = "splash",
            screen = awful.screen.focused(),
        })
    end

    -- Apply settings
    preview_wbox.bg = settings.preview_box_bg
    preview_wbox.border_color = settings.preview_box_border

    -- Calculate dimensions
    local n = math.max(7, #alt_tab_table)
    local screen_geom = awful.screen.focused().geometry
    local W = screen_geom.width
    local w = W / n -- widget width
    local h = w * 0.75 -- widget height
    local textbox_height = w * 0.125

    local x = screen_geom.x - preview_wbox.border_width
    local y = screen_geom.y + (screen_geom.height - h - textbox_height) / 2
    preview_wbox:geometry({x = x, y = y, width = W, height = h + textbox_height})

    -- Create left-right layout
    local left_right_tab = {}
    local left_right_tab_to_alt_tab_index = {}
    local n_left, n_right
    
    if #alt_tab_table == 2 then
        n_left = 0
        n_right = 2
    else
        n_left = math.floor(#alt_tab_table / 2)
        n_right = math.ceil(#alt_tab_table / 2)
    end

    for i = 1, n_left do
        table.insert(left_right_tab, alt_tab_table[#alt_tab_table - n_left + i].client)
        table.insert(left_right_tab_to_alt_tab_index, #alt_tab_table - n_left + i)
    end
    for i = 1, n_right do
        table.insert(left_right_tab, alt_tab_table[i].client)
        table.insert(left_right_tab_to_alt_tab_index, i)
    end

    -- Create font surface for measurements
    local surface = cairo.ImageSurface(cairo.Format.RGB24, 20, 20)
    local cr = cairo.Context(surface)
    
    -- Determine font size
    local max_text_width = 0
    local max_text_height = 0
    local max_text = ""
    local big_font = textbox_height / 2
    
    cr:select_font_face(unpack(settings.preview_box_title_font))
    cr:set_font_size(big_font)
    
    for i = 1, #left_right_tab do
        local text = create_preview_text(left_right_tab[i])
        local text_extents = cr:text_extents(text)
        if text_extents.width > max_text_width or text_extents.height > max_text_height then
            max_text_height = text_extents.height
            max_text_width = text_extents.width
            max_text = text
        end
    end

    -- Adjust font size to fit
    while true do
        cr:set_font_size(big_font)
        local text_extents = cr:text_extents(max_text)
        if text_extents.width < w - textbox_height and text_extents.height < textbox_height then
            break
        end
        big_font = big_font - 1
        if big_font <= 1 then break end
    end
    
    local small_font = big_font * settings.preview_box_title_font_size_factor

    preview_widgets = {}

    -- Create widgets for each client
    for i = 1, #left_right_tab do
        preview_widgets[i] = wibox.widget.base.make_widget()
        preview_widgets[i].fit = function(widget, width, height)
            return w, h
        end
        
        local c = left_right_tab[i]
        preview_widgets[i].draw = function(widget, wbox, cr, width, height)
            if width == 0 or height == 0 then
                return
            end

            local alpha = 0.8
            local overlay = 0.6
            local font_size = small_font
            
            if c == alt_tab_table[alt_tab_index].client then
                alpha = 0.9
                overlay = 0
                font_size = big_font
            end

            -- Draw client icon
            -- Get icon using centralized lookup with proper fallback chain
            local icon
            local system_icon_path = icon_lookup.get_client_icon(c)
            
            if system_icon_path and icon_lookup.is_readable(system_icon_path) then
                -- Use system theme icon
                icon = gears.surface.load(system_icon_path)
            elseif c.icon then
                -- Use client-provided icon
                icon = gears.surface(c.icon)
            else
                -- Use fallback icon
                local fallback_path = icon_lookup.get_fallback_icon()
                if icon_lookup.is_readable(fallback_path) then
                    icon = gears.surface.load(fallback_path)
                else
                    -- Create a simple fallback
                    local fallback_surface = cairo.ImageSurface(cairo.Format.ARGB32, 48, 48)
                    local fallback_cr = cairo.Context(fallback_surface)
                    fallback_cr:set_source_rgba(0.5, 0.5, 0.5, 1)
                    fallback_cr:rectangle(4, 4, 40, 40)
                    fallback_cr:fill()
                    icon = fallback_surface
                end
            end

            local iconbox_width = 0.9 * textbox_height
            local iconbox_height = iconbox_width

            -- Prepare text
            cr:select_font_face(unpack(settings.preview_box_title_font))
            cr:set_font_size(font_size)

            local text = create_preview_text(c)
            local text_extents = cr:text_extents(text)
            local text_width = text_extents.width
            local text_height = text_extents.height

            local titlebox_width = text_width + iconbox_width

            -- Draw icon
            local tx = (w - titlebox_width) / 2
            local ty = h
            local sx = iconbox_width / icon.width
            local sy = iconbox_height / icon.height

            cr:save()
            cr:translate(tx, ty)
            cr:scale(sx, sy)
            cr:set_source_surface(icon, 0, 0)
            cr:paint()
            cr:restore()

            -- Draw text
            tx = tx + iconbox_width
            ty = h + (textbox_height + text_height) / 2

            cr:set_source_rgba(unpack(settings.preview_box_title_color))
            cr:move_to(tx, ty)
            cr:show_text(text)

            -- Draw preview
            local cg = c:geometry()
            if cg.width > cg.height then
                sx = alpha * w / cg.width
                sy = math.min(sx, alpha * h / cg.height)
            else
                sy = alpha * h / cg.height
                sx = math.min(sy, alpha * w / cg.width)
            end

            tx = (w - sx * cg.width) / 2
            ty = (h - sy * cg.height) / 2

            local content = gears.surface(c.content)
            if content then
                cr:save()
                cr:translate(tx, ty)
                cr:scale(sx, sy)
                cr:set_source_surface(content, 0, 0)
                cr:paint()
                cr:restore()

                -- Overlay
                cr:set_source_rgba(0, 0, 0, overlay)
                cr:rectangle(tx, ty, sx * cg.width, sy * cg.height)
                cr:fill()
            end
        end

        -- Add mouse handlers for hover auto-selection
        preview_widgets[i]:connect_signal("mouse::enter", function()
            local target_index = left_right_tab_to_alt_tab_index[i]
            if target_index ~= alt_tab_index then
                start_hover_timer(target_index)
            end
        end)
        
        preview_widgets[i]:connect_signal("mouse::leave", function()
            stop_hover_timer()
        end)
        
        -- Immediate selection on click
        preview_widgets[i]:connect_signal("button::press", function(_, _, _, button)
            if button == 1 then -- Left click
                local target_index = left_right_tab_to_alt_tab_index[i]
                if target_index ~= alt_tab_index then
                    stop_hover_timer()
                    cycle(target_index - alt_tab_index)
                end
            end
        end)
    end

    -- Create spacer widgets
    local spacer = wibox.widget.base.make_widget()
    spacer.fit = function(widget, width, height)
        return (W - w * #alt_tab_table) / 2, h + textbox_height
    end
    spacer.draw = function() end

    -- Create layout
    local preview_layout = wibox.layout.fixed.horizontal()
    preview_layout:add(spacer)
    for i = 1, #left_right_tab do
        preview_layout:add(preview_widgets[i])
    end
    preview_layout:add(spacer)

    preview_wbox:setup({
        preview_layout,
        widget = wibox.container.background,
        bg = settings.preview_box_bg,
        shape = shapes.rrect(beautiful.border_radius or dpi(6)),
    })
end

-- Show preview with timer
local function show_preview()
    if not preview_live_timer then
        preview_live_timer = gears.timer({
            timeout = 1 / settings.preview_box_fps,
            callback = update_preview,
            autostart = false
        })
    end
    
    preview_live_timer:start()
    switcher.preview()
    
    if preview_wbox then
        preview_wbox.visible = true
    end
    
    client_opacity()
end

-- Hide the switcher and clean up
local function hide_switcher()
    if preview_wbox then
        preview_wbox.visible = false
    end
    
    if preview_live_timer then
        preview_live_timer:stop()
    end
    
    -- Stop hover timer
    stop_hover_timer()
    
    if keygrabber_instance then
        awful.keygrabber.stop(keygrabber_instance)
        keygrabber_instance = nil
    end

    -- Restore client states
    for i, data in pairs(alt_tab_table) do
        if data.client and data.client.valid then
            data.client.opacity = data.opacity
            if i ~= alt_tab_index then
                data.client.minimized = data.minimized
            end
        end
    end

    -- Focus selected client
    if alt_tab_table[alt_tab_index] and alt_tab_table[alt_tab_index].client.valid then
        local c = alt_tab_table[alt_tab_index].client
        c.minimized = false
        client.focus = c
        c:raise()
    end

    alt_tab_table = {}
    preview_widgets = {}
    collectgarbage("collect")
end

-- Cancel switching and restore original focus
local function cancel_switcher()
    if preview_wbox then
        preview_wbox.visible = false
    end
    
    if preview_live_timer then
        preview_live_timer:stop()
    end
    
    -- Stop hover timer
    stop_hover_timer()
    
    if keygrabber_instance then
        awful.keygrabber.stop(keygrabber_instance)
        keygrabber_instance = nil
    end

    -- Restore all client states
    for i, data in pairs(alt_tab_table) do
        if data.client and data.client.valid then
            data.client.opacity = data.opacity
            data.client.minimized = data.minimized
        end
    end

    alt_tab_table = {}
    preview_widgets = {}
    collectgarbage("collect")
end

-- Main switch function
function switcher.switch(dir, mod_key1, release_key, mod_key2, key_switch)
    populate_alt_tab_table()

    if #alt_tab_table == 0 then
        return
    elseif #alt_tab_table == 1 then
        alt_tab_table[1].client.minimized = false
        alt_tab_table[1].client:raise()
        client.focus = alt_tab_table[1].client
        return
    end

    -- Reset index
    alt_tab_index = 1

    -- Preview delay timer
    local preview_delay = settings.preview_box_delay / 1000
    local preview_delay_timer = gears.timer({
        timeout = preview_delay,
        single_shot = true,
        callback = function()
            show_preview()
        end,
        autostart = false
    })
    preview_delay_timer:start()

    -- Start keygrabber
    keygrabber_instance = awful.keygrabber.run(function(mods, key, event)
        if event == "release" then
            if key:match("Super") or key:match("Alt") or key:match("Control") then
                if preview_delay_timer.started then
                    preview_delay_timer:stop()
                end
                hide_switcher()
            end
            return
        end

        if key == "Escape" then
            if preview_delay_timer.started then
                preview_delay_timer:stop()
            end
            cancel_switcher()
        elseif key == "Return" then
            -- Enter key focuses the current selected window and closes switcher
            if preview_delay_timer.started then
                preview_delay_timer:stop()
            end
            hide_switcher()
        elseif key == key_switch then
            local shift_held = false
            for _, m in ipairs(mods) do
                if m == "Shift" then
                    shift_held = true
                    break
                end
            end
            
            if shift_held then
                cycle(-1)
            else
                cycle(1)
            end
        end
    end)

    -- Initial cycle
    cycle(dir)
end

-- Enable the window switcher
local function enable()
    awesome.connect_signal("window_switcher::turn_on", function()
        switcher.switch(1, "Mod1", "Alt", "Shift", "Tab")
    end)
end

return {
    enable = enable,
    switch = switcher.switch,
    settings = settings,
}