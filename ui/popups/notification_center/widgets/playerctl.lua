local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gfs = require("gears.filesystem")
local gcl = require("gears.color")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local pctl = require("lgi").require("Playerctl")
local cairo = require("lgi").cairo

local maticons = gfs.get_configuration_dir() .. "/themes/assets/icons/svg/"
--slighty janky statekeeping if widget is currently shown, so that
--the progressbar does not have to update when it is not seen
local currently_updating = false

local widget = wibox.widget({
    id = "list",
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(5),
})

--signals for said statekeeping
widget:connect_signal("start_updating", function()
    currently_updating = true
end)

widget:connect_signal("stop_updating", function()
    currently_updating = false
end)

-- local function show_icon()
--     require "ui.bar.bar".pctl_active()
-- end
-- local function hide_icon()
--     require "ui.bar.bar".pctl_inactive()
-- end

--basewidth 440 (qs 450 - 2\*5 margin)
local inactive_color, active_color = beautiful.dark_grey, beautiful.fg_normal
local titlefont, artistfont, margin, basewidth =
    beautiful.font_name .. " 12", beautiful.font .. " 10", dpi(5), dpi(430)
local insideheight = beautiful.get_font_height(titlefont)
    + 3 * margin
    + beautiful.get_font_height(artistfont)
local height = beautiful.get_font_height(titlefont)
    + insideheight
    + 6 * margin
    + dpi(20)

local template = {
    widget = wibox.container.background,
    bg = beautiful.dark_grey,
    shape = utilities.widgets.mkroundedrect(),
    {
        layout = wibox.layout.stack,
        {
            widget = wibox.container.place,
            halign = "right",
            {
                id = "album_art",
                widget = wibox.widget.imagebox,
                forced_height = height,
            },
        },
        {
            widget = wibox.container.margin,
            bottom = dpi(5),
            {
                widget = wibox.layout.fixed.vertical,
                spacing = margin,
                {
                    widget = wibox.container.margin,
                    margins = { top = margin, left = margin, right = margin },
                    {
                        widget = wibox.container.place,
                        halign = "left",
                        {
                            widget = wibox.container.background,
                            shape = utilities.widgets.mkroundedrect(),
                            bg = beautiful.bg_normal,
                            fg = beautiful.fg_focus,
                            {
                                widget = wibox.container.margin,
                                margins = margin,
                                {
                                    id = "playername",
                                    text = "no playername set",
                                    widget = wibox.widget.textbox,
                                    font = titlefont,
                                },
                            },
                        },
                    },
                },
                {
                    layout = wibox.layout.fixed.horizontal,
                    forced_height = insideheight,
                    {
                        widget = wibox.container.place,
                        content_fill_horizontal = true,
                        forced_width = basewidth - insideheight - margin,
                        halign = "left",
                        {
                            widget = wibox.container.margin,
                            margins = {
                                left = 2 * margin,
                                bottom = margin,
                                right = margin,
                            },
                            {
                                layout = wibox.layout.fixed.vertical,
                                spacing = margin,
                                {
                                    id = "title",
                                    markup = "nothing playing",
                                    widget = wibox.widget.textbox,
                                    font = titlefont,
                                    ellipsize = "end",
                                    forced_height = beautiful.get_font_height(
                                        titlefont
                                    ),
                                },
                                {
                                    id = "artist",
                                    markup = "nothing playing",
                                    widget = wibox.widget.textbox,
                                    font = artistfont,
                                    ellipsize = "end",
                                    forced_height = beautiful.get_font_height(
                                        artistfont
                                    ),
                                },
                            },
                        },
                    },
                    {
                        widget = wibox.container.place,
                        halign = "right",
                        valign = "center",
                        {
                            widget = wibox.container.margin,
                            margins = {
                                left = dpi(7),
                                right = dpi(7),
                                bottom = dpi(7),
                            },
                            {
                                id = "playpause_bg",
                                widget = wibox.container.background,
                                bg = beautiful.grey,
                                shape = utilities.widgets.mkroundedrect(),
                                {
                                    widget = wibox.container.margin,
                                    margins = dpi(5),
                                    {
                                        id = "playpause",
                                        image = gcl.recolor_image(
                                            maticons .. "play.svg",
                                            beautiful.bg_normal
                                        ),
                                        widget = wibox.widget.imagebox,
                                    },
                                },
                            },
                        },
                    },
                },
                {
                    widget = wibox.container.constraint,
                    height = dpi(20),
                    {
                        widget = wibox.container.margin,
                        margins = { left = 2 * margin, right = 2 * margin },
                        {
                            layout = wibox.layout.fixed.horizontal,
                            spacing = 4 * margin,
                            {
                                id = "prev",
                                image = gcl.recolor_image(
                                    maticons .. "previous.svg",
                                    beautiful.fg_normal
                                ),
                                widget = wibox.widget.imagebox,
                            },
                            {
                                widget = wibox.container.place,
                                valign = "center",
                                {
                                    id = "progress",
                                    widget = wibox.widget.progressbar,
                                    forced_height = dpi(5),
                                    max_value = 100,
                                    forced_width = basewidth
                                        - 22 * margin
                                        - dpi(80),
                                    border_width = 0,
                                    color = beautiful.fg_normal,
                                    background_color = inactive_color,
                                    shape = gears.shape.rounded_bar,
                                },
                            },
                            {
                                id = "next",
                                image = gcl.recolor_image(
                                    maticons .. "next.svg",
                                    beautiful.fg_normal
                                ),
                                widget = wibox.widget.imagebox,
                            },
                            {
                                id = "shuffle",
                                image = gcl.recolor_image(
                                    maticons .. "shuffle.svg",
                                    inactive_color
                                ),
                                widget = wibox.widget.imagebox,
                            },
                            {
                                id = "repeat",
                                image = gcl.recolor_image(
                                    maticons .. "repeat.svg",
                                    inactive_color
                                ),
                                widget = wibox.widget.imagebox,
                            },
                        },
                    },
                },
            },
        },
    },
}

local function func_on_click(w, on_press)
    w:add_button(awful.button({
        modifiers = {},
        button = 1,
        on_press = on_press,
    }))
    utilities.visual.pointer_on_focus(w)
end

local hex_to_char = function(x)
    return string.char(tonumber(x, 16))
end

local unescape = function(url)
    return url:gsub("%%(%x%x)", hex_to_char)
end

local function image_with_gradient(image, ratio)
    local in_surf = gears.surface.load_uncached(image)
    local surf = utilities.visual.crop_surface(ratio, in_surf)

    local cr = cairo.Context(surf)
    local w, h = gears.surface.get_size(surf)
    cr:rectangle(0, 0, w, h)

    local pat_h = cairo.Pattern.create_linear(0, 0, w, 0)
    pat_h:add_color_stop_rgba(0, gears.color.parse_color(beautiful.dark_grey))
    pat_h:add_color_stop_rgba(0.2, gears.color.parse_color(beautiful.dark_grey))
    pat_h:add_color_stop_rgba(
        0.6,
        gears.color.parse_color(beautiful.dark_grey .. "BB")
    )
    pat_h:add_color_stop_rgba(
        0.8,
        gears.color.parse_color(beautiful.dark_grey .. "99")
    )
    pat_h:add_color_stop_rgba(
        1,
        gears.color.parse_color(beautiful.dark_grey .. "88")
    )
    cr:set_source(pat_h)
    cr:fill()

    return surf
end

-- estimated value based on widget proportions
local ratio = basewidth / height
-- one line but nice in case i want to change the look
local function set_bg_with_gradient(player_widget, path)
    local editpath = path .. "_cropgrad"

    if not gears.filesystem.file_readable(editpath) then
        local img = image_with_gradient(path, ratio)
        img:write_to_png(editpath)
    end

    --player_widget.bgimage = editpath
    player_widget:get_children_by_id("album_art")[1].image = editpath
end

local function update_widget_meta(w, meta, player)
    local val = meta.value

    local title = val["xesam:title"]
    if title then
        title = gears.string.xml_escape(title)
    else
        title = "no title metadata"
    end

    local artists, artist_string = val["xesam:artist"], "no artist metadata"
    if artists then
        artist_string = artists[1]
        for i = 2, #artists do
            artist_string = artist_string .. ", " .. artists[i]
        end
        artist_string = gears.string.xml_escape(artist_string)
    end

    local length = val["mpris:length"]
    if length then
        w:get_children_by_id("progress")[1].max_value =
            math.floor(length / 1000000)
    end

    w:get_children_by_id("title")[1]:set_markup_silently(title)
    w:get_children_by_id("artist")[1]:set_markup_silently(artist_string)

    local art = val["mpris:artUrl"]
    -- if the image is available from local storage
    if art then
        if string.match(art, "file://") then
            local path = string.sub(art, 7, string.len(art))
            path = unescape(path)
            if gears.filesystem.file_readable(path) then
                set_bg_with_gradient(w, path)
            end
        elseif player.player_name == "spotify" then
            -- using the permalink name of the image as identifier
            local filename = art:match("([%d%a]+)/?$")
            local path = gears.filesystem.get_cache_dir() .. filename
            if gears.filesystem.file_readable(path) then
                set_bg_with_gradient(w, path)
            else
                awful.spawn.easy_async(
                    "curl -L -s " .. art .. " -o " .. path,
                    function(_, _, _, code)
                        -- check if download was successful
                        if code == 0 then
                            set_bg_with_gradient(w, path)
                        end
                    end
                )
            end
        end
    end
end

local function widget_from_player(player)
    local w = wibox.widget(template)
    if w == nil then
        error("couldnt construct widget for " .. player.name)
        return nil
    end

    local function update_pos()
        --naughty.notification({message = "updating..."})
        local pos = math.floor(player.position / 1000000)
        w:get_children_by_id("progress")[1].value = pos
    end

    local progresstimer = gears.timer({
        timeout = 1,
        callback = update_pos,
    })

    local function progresstimer_run()
        if progresstimer.started then
            progresstimer:again()
        else
            progresstimer:start()
        end
    end
    ----
    -- signal connect
    ----
    player.on_pause = function(_, _)
        w:get_children_by_id("playpause")[1]:set_image(
            gcl.recolor_image(maticons .. "play.svg", beautiful.bg_normal)
        )
        w:get_children_by_id("playpause_bg")[1].bg = beautiful.grey
        progresstimer:stop()
    end

    player.on_play = function(_, _)
        w:get_children_by_id("playpause")[1]:set_image(
            gcl.recolor_image(maticons .. "pause.svg", beautiful.bg_normal)
        )
        w:get_children_by_id("playpause_bg")[1].bg = beautiful.blue
        progresstimer_run()
    end

    player.on_metadata = function(_, meta, _)
        update_widget_meta(w, meta, player)
    end

    player.on_shuffle = function(_, shuffle, _)
        w:get_children_by_id("shuffle")[1]:set_image(
            gcl.recolor_image(
                maticons .. "shuffle.svg",
                shuffle and active_color or inactive_color
            )
        )
    end

    player.on_loop_status = function(_, status, _)
        w:get_children_by_id("repeat")[1]:set_image(
            gcl.recolor_image(
                maticons .. "repeat.svg",
                status == "NONE" and inactive_color or active_color
            )
        )
    end

    func_on_click(w:get_children_by_id("prev")[1], function()
        player:previous()
    end)
    func_on_click(w:get_children_by_id("playpause_bg")[1], function()
        player:play_pause()
    end)
    func_on_click(w:get_children_by_id("next")[1], function()
        player:next()
    end)
    func_on_click(w:get_children_by_id("shuffle")[1], function()
        player:set_shuffle(not player.shuffle)
    end)
    func_on_click(w:get_children_by_id("repeat")[1], function()
        player:set_loop_status(
            player.loop_status == "NONE" and "PLAYLIST" or "NONE"
        )
    end)

    widget:connect_signal("start_updating", function()
        if player.playback_status == "PLAYING" then
            progresstimer_run()
        end
    end)
    widget:connect_signal("stop_updating", function()
        progresstimer:stop()
    end)
    ----
    -- deconstruct
    ----
    player.on_exit = function(_, _)
        widget:remove_widgets(w)
        w = nil
        if #widget:get_children() == 0 then
            hide_icon()
        end
    end

    ----
    -- initial updates
    ----
    w:get_children_by_id("playpause")[1]:set_image(
        gcl.recolor_image(
            maticons
                .. (
                    player.playback_status == "PLAYING" and "pause.svg"
                    or "play.svg"
                ),
            beautiful.bg_normal
        )
    )
    w:get_children_by_id("repeat")[1]:set_image(
        gcl.recolor_image(
            maticons .. "repeat.svg",
            player.loop_status == "NONE" and inactive_color or active_color
        )
    )
    w:get_children_by_id("shuffle")[1]:set_image(
        gcl.recolor_image(
            maticons .. "shuffle.svg",
            player.shuffle and active_color or inactive_color
        )
    )
    if player.playback_status == "PLAYING" then
        w:get_children_by_id("playpause_bg")[1].bg = beautiful.blue
        if currently_updating then
            progresstimer:run()
        end
    else
        update_pos()
    end
    --gsub makes first letter uppercase, looks better Imo
    w:get_children_by_id("playername")[1].text =
        player.player_name:gsub("^%l", string.upper)

    return w
end

local manager = pctl.PlayerManager()

local function start_managing(name, just_added)
    local player = pctl.Player.new_from_name(name)
    --needs to be done for the controls to work
    manager:manage_player(player)
    local new_widget = widget_from_player(player)
    -- initial update of metadata (doing it in the "add" function somehow kills the construction process)
    if not just_added then
        update_widget_meta(new_widget, player.metadata, player)
    end
    if #widget:get_children() == 0 then
        show_icon()
    end
    widget:insert(1, new_widget)
end

function manager:on_name_appeared(name, _)
    start_managing(name, true)
end

for _, name in ipairs(manager.player_names) do
    start_managing(name, false)
end

function widget:disable_updates()
    widget:emit_signal("stop_updating")
end

function widget:enable_updates()
    widget:emit_signal("start_updating")
end

return widget
