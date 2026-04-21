---@diagnostic disable: undefined-global
--[[
System information service for collecting CPU, memory, swap and disk usage data.
Provides real-time system statistics with signal-based updates.
--]]

local gobject = require("gears.object")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local spawn = require("awful.spawn")

local system_info = {}
local instance = nil

local function new()
    local ret = gobject({})
    gtable.crush(ret, system_info, true)

    ret._private = {}
    local wp = ret._private

    -- Initialize default values
    wp.cpu_usage = 0
    wp.ram_usage = 0
    wp.ram_total = 0 
    wp.swap_usage = 0
    wp.swap_total = 0
    wp.disk_usage = 0
    wp.disk_total = 0
    wp.disk_free = 0
    wp.gpu_usage = 0

    -- CPU tracking variables for calculation
    wp.prev_total = 0
    wp.prev_idle = 0

    -- Update system info every 2 seconds
    wp.timer = gtimer({
        timeout = 2,
        call_now = true,
        autostart = true,
        callback = function()
            ret:_update_system_info()
        end,
    })

    return ret
end

function system_info:_update_cpu_usage()
    local wp = self._private
    
    -- Read /proc/stat for CPU usage
    spawn.easy_async("cat /proc/stat", function(stdout)
        local cpu_line = stdout:match("cpu%s+([^\n]+)")
        if not cpu_line then return end
        
        local values = {}
        for val in cpu_line:gmatch("%d+") do
            table.insert(values, tonumber(val))
        end
        
        if #values < 4 then return end
        
        -- Calculate total and idle time
        local user, nice, system, idle = values[1], values[2], values[3], values[4]
        local total = user + nice + system + idle
        
        -- Calculate usage percentage
        local total_diff = total - wp.prev_total
        local idle_diff = idle - wp.prev_idle
        
        if total_diff > 0 then
            wp.cpu_usage = math.floor((total_diff - idle_diff) * 100 / total_diff)
            self:emit_signal("property::cpu_usage", wp.cpu_usage)
        end
        
        wp.prev_total = total
        wp.prev_idle = idle
    end)
end

function system_info:_update_memory_usage()
    local wp = self._private
    
    -- Read /proc/meminfo for memory and swap info
    spawn.easy_async("cat /proc/meminfo", function(stdout)
        local mem_total = stdout:match("MemTotal:%s*(%d+)") 
        local mem_available = stdout:match("MemAvailable:%s*(%d+)")
        local swap_total = stdout:match("SwapTotal:%s*(%d+)")
        local swap_free = stdout:match("SwapFree:%s*(%d+)")
        
        if mem_total and mem_available then
            wp.ram_total = math.floor(tonumber(mem_total) / 1024) -- Convert to MB
            local ram_used = wp.ram_total - math.floor(tonumber(mem_available) / 1024)
            wp.ram_usage = math.floor(ram_used * 100 / wp.ram_total)
            self:emit_signal("property::ram_usage", wp.ram_usage, ram_used, wp.ram_total)
        end
        
        if swap_total and swap_free then
            wp.swap_total = math.floor(tonumber(swap_total) / 1024) -- Convert to MB
            local swap_used = wp.swap_total - math.floor(tonumber(swap_free) / 1024)
            wp.swap_usage = wp.swap_total > 0 and math.floor(swap_used * 100 / wp.swap_total) or 0
            self:emit_signal("property::swap_usage", wp.swap_usage, swap_used, wp.swap_total)
        end
    end)
end

function system_info:_update_disk_usage()
    local wp = self._private
    
    -- Get disk usage for root filesystem
    spawn.easy_async("df -h /", function(stdout)
        local lines = {}
        for line in stdout:gmatch("[^\n]+") do
            table.insert(lines, line)
        end
        
        if #lines < 2 then return end
        
        -- Parse the disk usage line (skip header)
        local disk_line = lines[2]
        local size, used, available, usage_percent = disk_line:match("%S+%s+(%S+)%s+(%S+)%s+(%S+)%s+(%d+)%%")
        
        if usage_percent then
            wp.disk_usage = tonumber(usage_percent)
            -- Convert human-readable sizes to MB for consistency
            wp.disk_total = size
            wp.disk_free = available
            self:emit_signal("property::disk_usage", wp.disk_usage, used, size, available)
        end
    end)
end

function system_info:_update_gpu_usage()
    local wp = self._private
    
    -- Try nvidia-smi first for NVIDIA GPUs
    spawn.easy_async("nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits", function(stdout)
        local gpu_percent = stdout:match("(%d+)")
        if gpu_percent then
            wp.gpu_usage = tonumber(gpu_percent)
            self:emit_signal("property::gpu_usage", wp.gpu_usage)
            return
        end
        
        -- Fallback to AMD GPU monitoring (radeontop)
        spawn.easy_async("timeout 1s radeontop -d - -l 1", function(stdout_amd)
            local gpu_percent_amd = stdout_amd:match("gpu (%d+)%%")
            if gpu_percent_amd then
                wp.gpu_usage = tonumber(gpu_percent_amd)
                self:emit_signal("property::gpu_usage", wp.gpu_usage)
                return
            end
            
            -- Fallback to Intel GPU monitoring (intel_gpu_top)
            spawn.easy_async("timeout 1s intel_gpu_top -J -s 1000", function(stdout_intel)
                -- Parse JSON output for render/3d usage
                local gpu_percent_intel = stdout_intel:match('"Render/3D".-"busy":([%d%.]+)')
                if gpu_percent_intel then
                    wp.gpu_usage = math.floor(tonumber(gpu_percent_intel))
                    self:emit_signal("property::gpu_usage", wp.gpu_usage)
                    return
                end
                
                -- If no GPU monitoring tools available, set to 0
                wp.gpu_usage = 0
                self:emit_signal("property::gpu_usage", wp.gpu_usage)
            end)
        end)
    end)
end

function system_info:_update_system_info()
    self:_update_cpu_usage()
    self:_update_memory_usage() 
    self:_update_disk_usage()
    self:_update_gpu_usage()
end

-- Getters for current values
function system_info:get_cpu_usage()
    return self._private.cpu_usage
end

function system_info:get_ram_usage()
    return self._private.ram_usage, self._private.ram_total
end

function system_info:get_swap_usage()
    return self._private.swap_usage, self._private.swap_total
end

function system_info:get_disk_usage()
    return self._private.disk_usage, self._private.disk_total, self._private.disk_free
end

function system_info:get_gpu_usage()
    return self._private.gpu_usage
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