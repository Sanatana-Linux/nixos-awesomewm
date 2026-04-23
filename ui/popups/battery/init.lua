---@diagnostic disable: undefined-global
--[[
Battery popup with system information and arc charts.
Shows detailed battery info, CPU load, RAM usage, swap usage, and disk space.
--]]

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local gtimer = require("gears.timer")
local dpi = beautiful.xresources.apply_dpi
local anim = require("modules.animations")
local click_to_hide = require("modules.click_to_hide")

local battery_service = require("service.battery")
local system_info = require("service.system_info")
local arc_chart = require("modules.arc_chart")
local animations = require("modules.animations")
local shapes = require("modules.shapes")

local battery_popup = {}
local instance = nil

local function new()
    local ret = {}
    ret._private = {}
    local wp = ret._private

    -- Initialize state
    wp.shown = false

    -- Get services
    local battery = battery_service.get_default()
    local sysinfo = system_info.get_default()

    -- Create arc charts for system metrics with larger sizing
    ret.cpu_chart = arc_chart.new({
        value = 0,
        label = "CPU",
        color = beautiful.red or "#f7768e",
        thickness = dpi(12), -- Thicker arc (doubled)
        margins = dpi(24), -- More margin for label space (doubled)
    })

    ret.ram_chart = arc_chart.new({
        value = 0,
        label = "RAM",
        color = beautiful.blue or "#7aa2f7",
        thickness = dpi(12),
        margins = dpi(24),
    })

    ret.swap_chart = arc_chart.new({
        value = 0,
        label = "SWAP",
        color = beautiful.yellow or "#e0af68",
        thickness = dpi(12),
        margins = dpi(24),
    })

    ret.disk_chart = arc_chart.new({
        value = 0,
        label = "DISK",
        color = beautiful.green or "#9ece6a",
        thickness = dpi(12),
        margins = dpi(24),
    })

    ret.gpu_chart = arc_chart.new({
        value = 0,
        label = "GPU",
        color = beautiful.purple or "#bb9af7",
        thickness = dpi(12),
        margins = dpi(24),
    })

    -- Enhanced Battery Indicator Widget
    local function create_battery_indicator()
        local battery = battery_service.get_default()

        -- Large battery shape with level indicator
        local battery_body = wibox.widget({
            widget = wibox.widget.progressbar,
            max_value = 100,
            value = battery.level or 0,
            forced_width = dpi(120),
            forced_height = dpi(60),
            shape = shapes.rrect(8),
            bar_shape = shapes.rrect(6),
            border_width = dpi(3),
            border_color = beautiful.fg_normal or beautiful.fg,
            background_color = beautiful.bg_alt or beautiful.bg_3,
            color = beautiful.green, -- Will be updated based on level
            paddings = dpi(4),
        })

        -- Battery terminal (small cap on the right)
        local battery_terminal = wibox.widget({
            widget = wibox.container.background,
            forced_width = dpi(8),
            forced_height = dpi(25),
            bg = beautiful.fg_normal or beautiful.fg,
            shape = shapes.rrect(4),
        })

        -- Large percentage text overlay
        local percentage_text = wibox.widget({
            widget = wibox.widget.textbox,
            text = (battery.level or 0) .. "%",
            font = beautiful.font_name .. " Bold 16",
            align = "center",
            valign = "center",
        })

        -- Charging indicator icon
        local charging_icon = wibox.widget({
            widget = wibox.widget.textbox,
            markup = beautiful.text_icons and beautiful.text_icons.bolt
                or "⚡",
            font = beautiful.font_name .. " 20",
            align = "center",
            valign = "center",
            visible = battery.is_charging or false,
        })

        -- Stack the text and charging icon over the battery
        local battery_display = wibox.widget({
            layout = wibox.layout.stack,
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(3),
                battery_body,
                {
                    widget = wibox.container.place,
                    valign = "center",
                    battery_terminal,
                },
            },
            percentage_text,
            charging_icon,
        })

        -- Detailed info text
        local status_text = wibox.widget({
            widget = wibox.widget.textbox,
            font = beautiful.font_name .. " Bold 14",
            align = "center",
            markup = "<span foreground='"
                .. (beautiful.fg_normal or beautiful.fg)
                .. "'>Battery Status</span>",
        })

        local details_text = wibox.widget({
            widget = wibox.widget.textbox,
            font = beautiful.font_name .. " 11",
            align = "left",
            markup = "Loading battery information...",
        })

        -- Time remaining indicator
        local time_remaining = wibox.widget({
            widget = wibox.widget.textbox,
            font = beautiful.font_name .. " 12",
            align = "center",
            markup = "",
        })

        -- Complete battery indicator widget
        local battery_indicator = wibox.widget({
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(12),
            {
                widget = wibox.container.place,
                halign = "center",
                battery_display,
            },
            status_text,
            details_text,
            time_remaining,
        })

        -- Update function
        local function update_battery_display()
            local level = battery.level or 0
            local is_charging = battery.is_charging or false
            local health = battery.health or "Unknown"
            local voltage = battery.voltage
            local power = battery.power

            -- Update battery level and color
            battery_body:set_value(level)
            if level > 70 then
                battery_body.color = beautiful.green or "#9ece6a"
            elseif level > 30 then
                battery_body.color = beautiful.yellow or "#e0af68"
            elseif level > 15 then
                battery_body.color = beautiful.orange or "#ff9e64"
            else
                battery_body.color = beautiful.red or "#f7768e"
            end

            -- Update percentage text
            percentage_text:set_text(level .. "%")

            -- Update charging state
            charging_icon.visible = is_charging
            percentage_text.visible = not is_charging

            -- Update status text
            local status_color = is_charging and (beautiful.green or "#9ece6a")
                or (beautiful.blue or "#7aa2f7")
            local status_msg = is_charging and "Charging" or "On Battery"
            status_text:set_markup(
                "<span foreground='"
                    .. status_color
                    .. "'>"
                    .. status_msg
                    .. "</span>"
            )

            -- Build detailed info
            local details = {}
            table.insert(details, "Level: " .. level .. "%")
            table.insert(details, "Health: " .. health)

            if voltage then
                table.insert(details, "Voltage: " .. voltage .. "V")
            end

            if power then
                if is_charging then
                    table.insert(details, "Charge Rate: " .. power .. "W")
                else
                    table.insert(details, "Discharge Rate: " .. power .. "W")
                end
            end

            details_text:set_markup(table.concat(details, "\n"))

            -- Calculate and show time remaining (more accurate estimation)
            if
                power
                and power > 0
                and battery.energy_full
                and battery.energy_now
            then
                local time_hours
                if is_charging then
                    -- Time to full charge = (energy_full - energy_now) / power
                    local energy_needed = battery.energy_full
                        - battery.energy_now
                    time_hours = energy_needed / power
                else
                    -- Time remaining = energy_now / power
                    time_hours = battery.energy_now / power
                end

                if time_hours > 0 and time_hours < 24 then -- Reasonable time range
                    local hours = math.floor(time_hours)
                    local minutes = math.floor((time_hours - hours) * 60)
                    local time_str = is_charging and "Time to Full: "
                        or "Time Remaining: "
                    if hours > 0 then
                        time_str = time_str .. hours .. "h " .. minutes .. "m"
                    else
                        time_str = time_str .. minutes .. "m"
                    end
                    time_remaining:set_markup("<i>" .. time_str .. "</i>")
                else
                    time_remaining:set_markup("<i>Calculating...</i>")
                end
            elseif power and power > 0 then
                -- Fallback calculation if energy values not available
                local time_hours
                if is_charging then
                    -- Estimate time to full charge (rough calculation)
                    time_hours = ((100 - level) / 100) * 4 -- Assume ~4 hours for full charge
                else
                    -- Estimate time remaining (rough calculation)
                    time_hours = (level / 100) * 8 -- Assume ~8 hours total battery life
                end

                if time_hours > 0 then
                    local hours = math.floor(time_hours)
                    local minutes = math.floor((time_hours - hours) * 60)
                    local time_str = is_charging and "Time to Full: ~"
                        or "Time Remaining: ~"
                    if hours > 0 then
                        time_str = time_str .. hours .. "h " .. minutes .. "m"
                    else
                        time_str = time_str .. minutes .. "m"
                    end
                    time_remaining:set_markup("<i>" .. time_str .. "</i>")
                else
                    time_remaining:set_markup("")
                end
            else
                time_remaining:set_markup("")
            end
        end

        -- Connect to battery service signals
        battery:connect_signal("property::level", update_battery_display)
        battery:connect_signal("property::is_charging", update_battery_display)
        battery:connect_signal("property::health", update_battery_display)
        battery:connect_signal("property::voltage", update_battery_display)
        battery:connect_signal("property::power", update_battery_display)
        battery:connect_signal("property::energy_full", update_battery_display)
        battery:connect_signal("property::energy_now", update_battery_display)

        -- Initial update
        update_battery_display()

        return battery_indicator
    end

    ret.battery_indicator = create_battery_indicator()

    -- Main popup widget with larger size
    ret.widget = wibox.widget({
        widget = wibox.container.constraint,
        width = dpi(1100), -- Increased width significantly (more than doubled)
        height = dpi(600), -- Much smaller now without system details section
        {
            widget = wibox.container.background,
            bg = beautiful.bg .. "bb", -- Match control center semi-transparent style
            shape = shapes.rrect(20), -- Match control center radius
            border_width = beautiful.border_width,
            border_color = beautiful.border_color_normal,
            {
                widget = wibox.container.margin,
                margins = dpi(25), -- Slightly reduced margins
                {
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(20), -- Increased spacing
                    -- Title
                    {
                        widget = wibox.widget.textbox,
                        markup = "<b>System Monitor</b>",
                        font = (beautiful.font_name or "Sans") .. " Bold 18", -- Larger title
                        align = "center",
                    },
                    -- Arc charts grid
                    {
                        widget = wibox.container.constraint,
                        width = dpi(1000),
                        height = dpi(500), -- Much larger height for proper charts
                        {
                            layout = wibox.layout.grid,
                            spacing = dpi(20), -- More spacing between charts
                            forced_num_cols = 2,
                            forced_num_rows = 3,
                            homogeneous = true,
                            expand = true,
                            -- CPU Chart
                            {
                                widget = wibox.container.background,
                                bg = beautiful.bg_alt or beautiful.bg_3,
                                shape = shapes.rrect(12),
                                border_width = dpi(1),
                                border_color = beautiful.border_color_normal,
                                buttons = {
                                    awful.button({}, 1, function()
                                        awful.spawn({ "kitty", "-e", "htop" })
                                    end),
                                },
                                {
                                    widget = wibox.container.constraint,
                                    strategy = "exact",
                                    width = dpi(480),
                                    height = dpi(230),
                                    ret.cpu_chart,
                                },
                            },
                            -- RAM Chart
                            {
                                widget = wibox.container.background,
                                bg = beautiful.bg_alt or beautiful.bg_3,
                                shape = shapes.rrect(12),
                                border_width = dpi(1),
                                border_color = beautiful.border_color_normal,
                                buttons = {
                                    awful.button({}, 1, function()
                                        awful.spawn({ "kitty", "-e", "htop" })
                                    end),
                                },
                                {
                                    widget = wibox.container.constraint,
                                    strategy = "exact",
                                    width = dpi(480),
                                    height = dpi(230),
                                    ret.ram_chart,
                                },
                            },
                            -- Swap Chart
                            {
                                widget = wibox.container.background,
                                bg = beautiful.bg_alt or beautiful.bg_3,
                                shape = shapes.rrect(12),
                                border_width = dpi(1),
                                border_color = beautiful.border_color_normal,
                                buttons = {
                                    awful.button({}, 1, function()
                                        awful.spawn({ "kitty", "-e", "htop" })
                                    end),
                                },
                                {
                                    widget = wibox.container.constraint,
                                    strategy = "exact",
                                    width = dpi(480),
                                    height = dpi(230),
                                    ret.swap_chart,
                                },
                            },
                            -- Disk Chart
                            {
                                widget = wibox.container.background,
                                bg = beautiful.bg_alt or beautiful.bg_3,
                                shape = shapes.rrect(12),
                                border_width = dpi(1),
                                border_color = beautiful.border_color_normal,
                                buttons = {
                                    awful.button({}, 1, function()
                                        awful.spawn({ "kitty", "-e", "yazi" })
                                    end),
                                },
                                {
                                    widget = wibox.container.constraint,
                                    strategy = "exact",
                                    width = dpi(480),
                                    height = dpi(230),
                                    ret.disk_chart,
                                },
                            },
                            -- GPU Chart
                            {
                                widget = wibox.container.background,
                                bg = beautiful.bg_alt or beautiful.bg_3,
                                shape = shapes.rrect(12),
                                border_width = dpi(1),
                                border_color = beautiful.border_color_normal,
                                buttons = {
                                    awful.button({}, 1, function()
                                        awful.spawn({ "kitty", "-e", "nvtop" })
                                    end),
                                },
                                {
                                    widget = wibox.container.constraint,
                                    strategy = "exact",
                                    width = dpi(480),
                                    height = dpi(230),
                                    ret.gpu_chart,
                                },
                            },
                            -- Enhanced Battery Indicator in 6th slot
                            {
                                widget = wibox.container.background,
                                bg = beautiful.bg_alt or beautiful.bg_3,
                                shape = shapes.rrect(12),
                                border_width = dpi(1),
                                border_color = beautiful.border_color_normal,
                                {
                                    widget = wibox.container.constraint,
                                    strategy = "exact",
                                    width = dpi(480),
                                    height = dpi(230),
                                    {
                                        widget = wibox.container.margin,
                                        margins = dpi(12),
                                        ret.battery_indicator,
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
    })

    -- Create popup
    ret.popup = awful.popup({
        widget = ret.widget,
        visible = false,
        ontop = true,
        type = "utility",
        bg = "#00000000",
        name = "awesome-popup",
        placement = function(c)
            return awful.placement.bottom_right(c, {
                margins = {
                    bottom = dpi(50),
                    right = dpi(20),
                },
            })
        end,
        shape = shapes.rrect(20),
        border_width = 0,
    })

    -- Animation state
    ret._shown = false
    ret._animation = nil

    function ret:_update_charts()
        -- Update arc charts with current values
        self.cpu_chart:set_value(sysinfo:get_cpu_usage())

        local ram_usage = sysinfo:get_ram_usage()
        self.ram_chart:set_value(ram_usage)

        local swap_usage = sysinfo:get_swap_usage()
        self.swap_chart:set_value(swap_usage)

        local disk_usage = sysinfo:get_disk_usage()
        self.disk_chart:set_value(disk_usage)

        local gpu_usage = sysinfo:get_gpu_usage()
        self.gpu_chart:set_value(gpu_usage)
    end

    function ret:show()
        if wp.shown then
            return
        end

        -- Update charts before showing
        self:_update_charts()

        wp.shown = true
        self.popup.opacity = 0
        self.popup.visible = true

        gtimer.delayed_call(function()
            local placement_func = self.popup.placement
            if placement_func then
                placement_func(self.popup)
            end

            gtimer.delayed_call(function()
                self.popup:emit_signal("widget::layout_changed")

                local final_y = self.popup.y
                local start_y = final_y + dpi(20)
                self.popup.y = start_y

                anim.animate({
                    start = 0,
                    target = 1,
                    duration = 0.3,
                    easing = anim.easing.quadratic,
                    update = function(progress)
                        self.popup.opacity = progress
                        self.popup.y = start_y + (final_y - start_y) * progress
                    end,
                    complete = function()
                        self.popup:emit_signal("property::shown", wp.shown)
                    end,
                })
            end)
        end)
    end

    function ret:hide()
        if not wp.shown then
            return
        end

        wp.shown = false

        local start_y = self.popup.y
        local final_y = start_y + dpi(20)

        anim.animate({
            start = 1,
            target = 0,
            duration = 0.2,
            easing = anim.easing.quadratic,
            update = function(progress)
                self.popup.opacity = progress
                self.popup.y = start_y + (final_y - start_y) * (1 - progress)
            end,
            complete = function()
                self.popup.visible = false
                self.popup:emit_signal("property::shown", wp.shown)
            end,
        })
    end

    function ret:toggle()
        if not self.popup.visible then
            self:show()
        else
            self:hide()
        end
    end

    -- Connect to system info signals for live updates when popup is shown
    sysinfo:connect_signal("property::cpu_usage", function()
        if wp.shown then
            ret:_update_charts()
        end
    end)

    sysinfo:connect_signal("property::ram_usage", function()
        if wp.shown then
            ret:_update_charts()
        end
    end)

    sysinfo:connect_signal("property::swap_usage", function()
        if wp.shown then
            ret:_update_charts()
        end
    end)

    sysinfo:connect_signal("property::disk_usage", function()
        if wp.shown then
            ret:_update_charts()
        end
    end)

    sysinfo:connect_signal("property::gpu_usage", function()
        if wp.shown then
            ret:_update_charts()
        end
    end)

    -- Setup centralized click-to-hide behavior
    click_to_hide.popup(ret.popup, function()
        ret:hide()
    end, { outside_only = true, exclusive = true })

    return ret
end

local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
