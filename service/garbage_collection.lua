-- Garbage Collection Service
-- Manages memory cleanup with intelligent scheduling to prevent excessive collections

local gtimer = require("gears.timer")

local gc_service = {}

-- Configuration parameters
local config = {
    memory_growth_factor = 1.05, -- Trigger collection when memory grows 5% over last check
    memory_long_collection_time = 300, -- Force collection after 5 minutes regardless of growth
    check_interval = 60, -- Check memory usage every 5 seconds
    initial_gc_params = { 105, 300 }, -- Initial garbage collection parameters
}

-- Private state variables
local memory_last_check_count = 0
local memory_last_run_time = 0
local timer = nil

-- Initialize garbage collection service
function gc_service.start()
    -- Perform initial garbage collection with specified parameters
    collectgarbage(
        "collect",
        config.initial_gc_params[1],
        config.initial_gc_params[2]
    )

    -- Initialize tracking variables
    memory_last_check_count = collectgarbage("count")
    memory_last_run_time = os.time()

    -- Start periodic memory monitoring timer
    timer = gtimer.start_new(config.check_interval, function()
        local cur_memory = collectgarbage("count") -- Get current memory usage in KB

        -- Calculate time elapsed since last collection
        local elapsed = os.time() - memory_last_run_time
        local waited_long = elapsed >= config.memory_long_collection_time
        local grew_enough = cur_memory
            > (memory_last_check_count * config.memory_growth_factor)

        -- Trigger garbage collection if conditions are met
        if grew_enough or waited_long then
            -- Run garbage collection twice for thorough cleanup
            collectgarbage("collect")
            collectgarbage("collect")
            memory_last_run_time = os.time() -- Update last collection time
        end

        -- Always update memory usage tracking (even if no collection occurred)
        -- This prevents false positives on slow but steady memory growth
        memory_last_check_count = collectgarbage("count")

        return true -- Continue timer
    end)
end

-- Stop garbage collection service
function gc_service.stop()
    if timer then
        timer:stop()
        timer = nil
    end
end

-- Get current memory usage statistics
function gc_service.get_stats()
    return {
        current_memory = collectgarbage("count"),
        last_check_memory = memory_last_check_count,
        last_collection_time = memory_last_run_time,
        time_since_last_collection = os.time() - memory_last_run_time,
    }
end

-- Manually trigger garbage collection
function gc_service.force_collect()
    collectgarbage("collect")
    collectgarbage("collect")
    memory_last_run_time = os.time()
    memory_last_check_count = collectgarbage("count")
end

-- Update configuration parameters
function gc_service.configure(new_config)
    for key, value in pairs(new_config) do
        if config[key] ~= nil then
            config[key] = value
        end
    end
    -- Restart timer if check_interval is changed and service is running
    if timer and new_config.check_interval then
        timer:stop()
        timer = gtimer.start_new(config.check_interval, function()
            local cur_memory = collectgarbage("count")
            local elapsed = os.time() - memory_last_run_time
            local waited_long = elapsed >= config.memory_long_collection_time
            local grew_enough = cur_memory
                > (memory_last_check_count * config.memory_growth_factor)
            if grew_enough or waited_long then
                collectgarbage("collect")
                collectgarbage("collect")
                memory_last_run_time = os.time()
            end
            memory_last_check_count = collectgarbage("count")
            return true
        end)
    end
end

return gc_service
