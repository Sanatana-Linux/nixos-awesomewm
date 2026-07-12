--- Garbage collection service.
-- Schedules periodic `collectgarbage()` calls, gated by a memory-growth threshold
-- or a long-idle interval, whichever comes first. The dual-pass pattern (two
-- `collectgarbage("collect")` calls back-to-back) is intentional — it lets
-- finalizers on first-pass garbage run and create new garbage which the second
-- pass then collects.
-- @module service.garbage_collection

local gtimer = require("gears.timer")

local gc_service = {}

-- Tunable parameters. Override at module load time before `start()` if you
-- need a different memory-growth sensitivity.
-- @table config
local config = {
    -- Trigger collection when memory grows by this factor over the last check
    memory_growth_factor = 1.05,
    -- Force collection after this many seconds of idle regardless of growth
    memory_long_collection_time = 300,
    -- How often (in seconds) to poll memory usage
    check_interval = 60,
    -- Initial `collectgarbage("collect", pause, stepmul)` parameters
    initial_gc_params = { 105, 300 },
}

-- Private state variables
local memory_last_check_count = 0
local memory_last_run_time = 0
local timer = nil

-- Initialize garbage collection service
--- Start the periodic GC timer. Idempotent — calling `start` while already
-- running is safe.
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
--- Stop the periodic GC timer. Safe to call when the timer isn't running.
function gc_service.stop()
    if timer then
        timer:stop()
        timer = nil
    end
end

-- Get current memory usage statistics
--- @treturn table Memory stats:
--   `current_memory`, `last_check_memory`, `last_collection_time`, `time_since_last_collection`
function gc_service.get_stats()
    return {
        current_memory = collectgarbage("count"),
        last_check_memory = memory_last_check_count,
        last_collection_time = memory_last_run_time,
        time_since_last_collection = os.time() - memory_last_run_time,
    }
end

-- Manually trigger garbage collection
--- Force a two-pass collection right now, regardless of threshold.
function gc_service.force_collect()
    collectgarbage("collect")
    collectgarbage("collect")
    memory_last_run_time = os.time()
    memory_last_check_count = collectgarbage("count")
end

-- Update configuration parameters
--- Merge new config values into the live config and restart the timer if
-- `check_interval` changed. Unknown keys are ignored.
-- @tparam table new_config
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
