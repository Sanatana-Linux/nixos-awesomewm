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
local backdrop = require("modules.backdrop")

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
    
    -- Create arc charts for system metrics
    ret.cpu_chart = arc_chart.new({
        value = 0,
        label = "CPU",
        color = beautiful.red or "#f7768e",
        thickness = dpi(4),
        margins = dpi(8),
    })
    
    ret.ram_chart = arc_chart.new({
        value = 0,
        label = "RAM", 
        color = beautiful.blue or "#7aa2f7",
        thickness = dpi(4),
        margins = dpi(8),
    })
    
    ret.swap_chart = arc_chart.new({
        value = 0,
        label = "Swap",
        color = beautiful.yellow or "#e0af68", 
        thickness = dpi(4),
        margins = dpi(8),
    })
    
    ret.disk_chart = arc_chart.new({
        value = 0,
        label = "Disk",
        color = beautiful.green or "#9ece6a",
        thickness = dpi(4),
        margins = dpi(8),
    })
    
    ret.gpu_chart = arc_chart.new({
        value = 0,
        label = "GPU",
        color = beautiful.purple or "#bb9af7",
        thickness = dpi(4),
        margins = dpi(8),
    })

    -- Battery info text widget
    ret.battery_info = wibox.widget({
        widget = wibox.widget.textbox,
        markup = "<b>Battery Information</b>\nLoading...",
        font = (beautiful.font_name or "Sans") .. " 9",
        valign = "top",
    })
    
    -- Detailed system info text
    ret.system_details = wibox.widget({
        widget = wibox.widget.textbox,
        markup = "<b>System Details</b>\nLoading...",
        font = (beautiful.font_name or "Sans") .. " 8",
        valign = "top",
    })

    -- Main popup widget with strict size control
    ret.widget = wibox.widget({
        widget = wibox.container.constraint,
        width = dpi(300),  -- Fixed width to prevent expansion
        height = dpi(310), -- Increased height for GPU chart
        {
            widget = wibox.container.background,
            bg = beautiful.bg .. "bb",  -- Match control center semi-transparent style
            shape = shapes.rrect(20),  -- Match control center radius
            border_width = beautiful.border_width,
            border_color = beautiful.border_color_normal,
            {
                widget = wibox.container.margin,
                margins = dpi(12),
                {
                    layout = wibox.layout.fixed.vertical,
                    spacing = dpi(8),
                    -- Title
                    {
                        widget = wibox.widget.textbox,
                        markup = "<b>System Monitor</b>",
                        font = (beautiful.font_name or "Sans") .. " Bold 11",
                        align = "center",
                    },
                    -- Arc charts grid
                    {
                        widget = wibox.container.constraint,
                        width = dpi(276),
                        height = dpi(150), -- Increased height for 3 rows
                        {
                            layout = wibox.layout.grid,
                            spacing = dpi(4),
                            forced_num_cols = 2,
                            forced_num_rows = 3, -- Changed to 3 rows
                            homogeneous = true,
                            expand = false,
                            ret.cpu_chart,
                            ret.ram_chart,
                            ret.swap_chart,
                            ret.disk_chart,
                            ret.gpu_chart,
                            -- Empty slot for balance
                            {
                                widget = wibox.widget.base.empty_widget(),
                            },
                        },
                    },
                    -- Separator
                    {
                        widget = wibox.widget.separator,
                        orientation = "horizontal",
                        color = beautiful.border_color or "#3c3836",
                        thickness = dpi(1),
                    },
                    -- Info section
                    {
                        widget = wibox.container.constraint,
                        width = dpi(276),
                        height = dpi(80),
                        {
                            layout = wibox.layout.flex.horizontal,
                            spacing = dpi(8),
                            {
                                widget = wibox.container.constraint,
                                width = dpi(130),
                                ret.battery_info,
                            },
                            {
                                widget = wibox.widget.separator,
                                orientation = "vertical", 
                                color = beautiful.border_color or "#3c3836",
                                thickness = dpi(1),
                            },
                            {
                                widget = wibox.container.constraint,
                                width = dpi(130),
                                ret.system_details,
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
        placement = function(c)
            return awful.placement.bottom_right(c, {
                margins = {
                    bottom = dpi(50), -- Match control center bottom margin
                    right = dpi(12),
                }
            })
        end,
        shape = shapes.rrect(20),  -- Match control center shape
        border_width = 0,
    })

    -- Animation state
    ret._shown = false
    ret._animation = nil

    function ret:_update_battery_info()
        -- Get detailed battery information using shell commands
        awful.spawn.easy_async_with_shell([[
            echo "Status: $(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo 'N/A')"
            echo "Level: $(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 'N/A')%"
            echo "Health: $(cat /sys/class/power_supply/BAT0/health 2>/dev/null || echo 'N/A')"
            if [ -f /sys/class/power_supply/BAT0/voltage_now ]; then
                voltage=$(cat /sys/class/power_supply/BAT0/voltage_now)
                voltage_v=$(echo "scale=1; $voltage/1000000" | bc 2>/dev/null || echo "N/A")
                echo "Voltage: ${voltage_v}V"
            fi
            if [ -f /sys/class/power_supply/BAT0/power_now ]; then
                power=$(cat /sys/class/power_supply/BAT0/power_now)
                power_w=$(echo "scale=1; $power/1000000" | bc 2>/dev/null || echo "N/A")
                echo "Power: ${power_w}W"
            fi
        ]], function(stdout)
            self.battery_info:set_markup("<b>Battery Information</b>\n" .. stdout:gsub("\n$", ""))
        end)
    end

    function ret:_update_system_details()
        local cpu = sysinfo:get_cpu_usage()
        local ram_usage, ram_total = sysinfo:get_ram_usage()
        local swap_usage, swap_total = sysinfo:get_swap_usage() 
        local disk_usage, disk_total, disk_free = sysinfo:get_disk_usage()
        local gpu = sysinfo:get_gpu_usage()
        
        local details = string.format(
            "<b>System Details</b>\n" ..
            "CPU: %d%% usage\n" ..
            "RAM: %d MB total\n" ..
            "Swap: %d MB total\n" ..
            "Disk: %s total\n" ..
            "GPU: %d%% usage\n" ..
            "Free: %s available",
            cpu,
            ram_total or 0,
            swap_total or 0, 
            disk_total or "N/A",
            gpu,
            disk_free or "N/A"
        )
        
        self.system_details:set_markup(details)
    end

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
        if wp.shown then return end
        
        -- Show backdrop first
        backdrop.show(self.popup)
        
        -- Update all info before showing
        self:_update_battery_info()
        self:_update_system_details() 
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
        if not wp.shown then return end
        
        wp.shown = false
        
        local start_y = self.popup.y
        local final_y = start_y + dpi(20)
        
        anim.animate({
            start = 1,
            target = 0,
            duration = 0.3,
            easing = anim.easing.quadratic,
            update = function(progress)
                self.popup.opacity = progress
                self.popup.y = final_y - (final_y - start_y) * progress
            end,
            complete = function()
                self.popup.visible = false
                backdrop.hide()  -- Hide backdrop when popup hides
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
            ret:_update_system_details()
        end
    end)
    
    sysinfo:connect_signal("property::ram_usage", function()
        if wp.shown then
            ret:_update_charts()
            ret:_update_system_details()
        end
    end)
    
    sysinfo:connect_signal("property::swap_usage", function()
        if wp.shown then
            ret:_update_charts() 
            ret:_update_system_details()
        end
    end)
    
    sysinfo:connect_signal("property::disk_usage", function()
        if wp.shown then
            ret:_update_charts()
            ret:_update_system_details()
        end
    end)
    
    sysinfo:connect_signal("property::gpu_usage", function()
        if wp.shown then
            ret:_update_charts()
            ret:_update_system_details()
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