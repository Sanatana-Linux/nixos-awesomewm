local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local Gio = require("lgi").Gio
local iconTheme = require("lgi").require("Gtk", "3.0").IconTheme.get_default()
local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local animation = require("modules.animation")
local dpi = beautiful.xresources.apply_dpi
local icon_theme = modules.icon_theme(beautiful.icon_theme)

-- Widgets

awful.screen.connect_for_each_screen(function(s)
    local launcherdisplay = wibox({
        width = dpi(360),
        shape = utilities.widgets.mkroundedrect(),
        height = dpi(780),
        bg = beautiful.bg_normal .. "88",
        ontop = true,
        type = "dock",
        visible = false,
    })

    local slide = animation:new({
        duration = 0.6,
        pos = 0 - launcherdisplay.height,
        easing = animation.easing.inOutExpo,
        update = function(_, pos)
            launcherdisplay.y = s.geometry.y + pos
        end,
    })

    local slide_end = gears.timer({
        single_shot = true,
        timeout = 0.43,
        callback = function()
            launcherdisplay.visible = false
        end,
    })

    local prompt = wibox.widget({
        {
            {
                {
                    id = "txt",
                    font = beautiful.title_font .. " 18",
                    widget = wibox.widget.textbox,
                },
                widget = wibox.container.margin,
                margins = 20,
            },
            widget = wibox.container.background,
            bg = beautiful.bg_contrast .. "00",
        },
        widget = wibox.container.margin,
    })

    local entries = wibox.widget({
        homogeneous = false,
        expand = false,
        forced_num_cols = 1,
        spacing = 4,
        layout = wibox.layout.grid,
    })

    launcherdisplay:setup({
        -- {
        --     image,
        --     -- {
        --     --     -- -- {
        --     --     -- --     widget = wibox.widget.textbox,
        --     --     -- -- },
        --     --     -- bg = {
        --     --     --     type = "linear",
        --     --     --     from = { 120, 0 },
        --     --     --     to = { 0, 500 },
        --     --     --     stops = {
        --     --     --         { 0.2, beautiful.bg_contrast .. "00" },
        --     --     --         { 1, beautiful.dimblack .. "00" },
        --     --     --     },
        --     --     -- },
        --     --     -- widget = wibox.container.background,
        --     -- },
        --     {
        --         {
        --             {

        --                 widget = wibox.container.margin,
        --                 margins = dpi(10),
        --             },
        --             widget = wibox.container.place,
        --             valign = "bottom",
        --         },
        --         widget = wibox.container.background,
        --         -- forced_height = 570,
        --         -- forced_width = dpi(360),
        --     },
        --     layout = wibox.layout.stack,
        -- },
        {
            {
                {
                    widget = wibox.widget.imagebox,
                    image = icons.awesome,
                    resize = true,
                    forced_height = dpi(48),
                    forced_width = dpi(48),
                },
                {
                    widget = wibox.widget.textbox,
                    font = beautiful.title_font .. " 18",
                    text = "Launcher",
                },
                layout = wibox.layout.fixed.horizontal,
                spacing = 20,
                widget = wibox.container.background,
            },
            forced_height = dpi(60),
            widget = wibox.container.margin,
            margins = dpi(10),
        },
        {
            entries,
            left = dpi(10),
            right = dpi(10),
            bottom = dpi(5),
            top = dpi(5),
            widget = wibox.container.margin,
        },
        {
            prompt,

            forced_height = dpi(60),
            widget = wibox.container.background,
        },
        spacing = dpi(10),
        layout = wibox.layout.align.vertical,
    })

    -- Functions

    local function next(entries)
        if index_entry ~= #filtered then
            index_entry = index_entry + 1
            if index_entry > index_start + 9 then
                index_start = index_start + 1
            end
        end
    end

    local function back(entries)
        if index_entry ~= 1 then
            index_entry = index_entry - 1
            if index_entry < index_start then
                index_start = index_start - 1
            end
        end
    end

    local function gen()
        local entries = {}
        for _, entry in ipairs(Gio.AppInfo.get_all()) do
            if entry:should_show() then
                local name = entry
                    :get_name()
                    :gsub("&", "&amp;")
                    :gsub("<", "&lt;")
                    :gsub("'", "&#39;")
                local icon = entry:get_icon()
                local path
                if icon then
                    path = icon:to_string()
                    if not path:find("/") then
                        local icon_info =
                            iconTheme:lookup_icon(path, dpi(48), 0)
                        local p = icon_info and icon_info:get_filename()
                        path = p
                    end
                end
                table.insert(
                    entries,
                    { name = name, appinfo = entry, icon = path or "" }
                )
            end
        end
        return entries
    end

    local function filter(cmd)
        filtered = {}
        regfiltered = {}

        -- Filter entries

        for _, entry in ipairs(unfiltered) do
            if entry.name:lower():sub(1, cmd:len()) == cmd:lower() then
                table.insert(filtered, entry)
            elseif entry.name:lower():match(cmd:lower()) then
                table.insert(regfiltered, entry)
            end
        end

        -- Sort entries

        table.sort(filtered, function(a, b)
            return a.name:lower() < b.name:lower()
        end)
        table.sort(regfiltered, function(a, b)
            return a.name:lower() < b.name:lower()
        end)

        -- Merge entries

        for i = 1, #regfiltered do
            filtered[#filtered + 1] = regfiltered[i]
        end

        -- Clear entries

        entries:reset()

        -- Add filtered entries

        for i, entry in ipairs(filtered) do
            local widget = wibox.widget({
                {
                    {
                        {
                            image = entry.icon,
                            clip_shape = utilities.widgets.mkroundedrect(),
                            forced_height = dpi(48),
                            forced_width = dpi(48),
                            valign = "center",
                            widget = wibox.widget.imagebox,
                        },
                        {
                            markup = entry.name,
                            font = beautiful.title_font .. " 14",
                            widget = wibox.widget.textbox,
                        },
                        spacing = 20,
                        layout = wibox.layout.fixed.horizontal,
                    },
                    margins = dpi(10),
                    widget = wibox.container.margin,
                },
                forced_width = dpi(360),
                forced_height = dpi(60),
                border_color = beautiful.grey .. "88",
                shape = utilities.widgets.mkroundedrect(),
                border_width = dpi(2),
                widget = wibox.container.background,
                bg = beautiful.bg_contrast .. "00",
            })

            if index_start <= i and i <= index_start + 9 then
                entries:add(widget)
            end

            if i == index_entry then
                widget.border_color = beautiful.fg_normal .. "88"
            end
        end

        -- Fix position

        if index_entry > #filtered then
            index_entry, index_start = 1, 1
        elseif index_entry < 1 then
            index_entry = 1
        end

        collectgarbage("collect")
    end

    local function open()
        -- Reset index and page

        index_start, index_entry = 1, 1

        -- Get entries

        unfiltered = gen()
        filter("")

        -- Prompt

        awful.prompt.run({
            prompt = "Launch: ",
            textbox = prompt:get_children_by_id("txt")[1],
            done_callback = function()
                slide_end:again()
                slide:set(0 - launcherdisplay.height)
                awful.keyboard.emulate_key_combination({}, "Escape")
            end,
            changed_callback = function(cmd)
                filter(cmd)
            end,
            exe_callback = function(cmd)
                local entry = filtered[index_entry]
                if entry then
                    entry.appinfo:launch()
                else
                    awful.spawn.with_shell(cmd)
                end
            end,
            keypressed_callback = function(_, key)
                if key == "Down" then
                    next(entries)
                elseif key == "Up" then
                    back(entries)
                end
            end,
        })
    end

    -- -------------------------------------------------------------------------- --
    awesome.connect_signal("toggle::launcher", function()
        open()

        if launcherdisplay.visible then
            slide_end:again()
            slide:set(0 - launcherdisplay.height)
            awful.keyboard.emulate_key_combination({}, "Escape")
        elseif not launcherdisplay.visible then
            slide:set(
                awful.screen.focused().geometry.height / 2
                    - launcherdisplay.height / 2
            )
            launcherdisplay.visible = true
        end
        awful.placement.bottom_left(launcherdisplay, {
            honor_workarea = true,
            margins = dpi(12),
            parent = awful.screen.focused(),
        })
    end)
end)
