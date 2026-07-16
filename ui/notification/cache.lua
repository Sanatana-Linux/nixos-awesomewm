--- Notification history cache.
-- Persists a small history of recent notifications to
-- `~/.cache/awesome/notifications.json` so the notification center can
-- show past events even after they're dismissed. Capped at 100 entries.
-- @module ui.notification.cache

local gfs = require("gears.filesystem")
local json_lib = require("lib.json")

local notification_cache = {}

-- Cache file path
local cache_dir = (os.getenv("HOME") or "") .. "/.cache/awesome"
local cache_file = cache_dir .. "/notifications.json"

--- Ensure the cache directory exists (~/.cache/awesome).
-- @treturn boolean true if directory exists (or was created), false on failure
local function ensure_cache_dir()
    local success, err = gfs.make_directories(cache_dir)
    if not success then
        io.stderr:write(
            "Failed to create cache directory: "
                .. (err or "unknown error")
                .. "\n"
        )
        return false
    end
    return true
end

--- Load cached notifications from disk JSON file.
-- Returns empty table on any failure (missing file, parse error).
-- @treturn table Array of cached notification entries
local function load_cache()
    if not gfs.file_readable(cache_file) then
        return {}
    end

    local file = io.open(cache_file, "r")
    if not file then
        return {}
    end

    local content = file:read("*all")
    file:close()

    if not content or content == "" then
        return {}
    end

    local success, result = pcall(json_lib.decode, content)
    if success then
        return result or {}
    else
        io.stderr:write(
            "Failed to parse notification cache: " .. tostring(result) .. "\n"
        )
        return {}
    end
end

--- Save notifications array to the JSON cache file.
-- @tparam table notifications Array of notification entries
-- @treturn boolean true on success, false on failure
local function save_cache(notifications)
    if not ensure_cache_dir() then
        return false
    end

    local success, json_content = pcall(json_lib.encode, notifications)
    if not success then
        io.stderr:write(
            "Failed to encode notifications to JSON: "
                .. tostring(json_content)
                .. "\n"
        )
        return false
    end

    local file = io.open(cache_file, "w")
    if not file then
        io.stderr:write(
            "Failed to open cache file for writing: " .. cache_file .. "\n"
        )
        return false
    end

    file:write(json_content)
    file:close()
    return true
end

--- Add a notification to the cache.
-- New entry goes to position 1 (newest first). Older entries beyond 100 are
-- dropped silently.
-- @tparam naughty.notification notification
function notification_cache.add(notification)
    local cached_notifications = load_cache()

    -- Create a serializable notification entry
    local cache_entry = {
        timestamp = os.time(),
        app_name = notification.app_name or "Unknown",
        title = notification.title or "",
        text = notification.text or notification.message or "",
        urgency = notification.urgency or "normal",
        icon = notification.icon, -- Preserve icon path
        id = notification.id or tostring(os.time() .. math.random(1000, 9999)),
        actions = notification.actions or {}, -- Preserve actions
    }

    -- Add to the beginning of the list (newest first)
    table.insert(cached_notifications, 1, cache_entry)

    -- Keep only the last 100 notifications
    while #cached_notifications > 100 do
        table.remove(cached_notifications)
    end

    -- Save to file
    save_cache(cached_notifications)
end

--- @treturn table All cached notifications (most recent first)
function notification_cache.get_all()
    return load_cache()
end

--- @treturn boolean `false` on IO error, otherwise `save_cache({})`'s result
function notification_cache.clear()
    if not ensure_cache_dir() then
        return false
    end

    -- Write empty array to cache file
    return save_cache({})
end

--- Remove a specific notification from the cache by ID.
-- @tparam string notification_id
-- @treturn boolean true if removed, false if not found
function notification_cache.remove(notification_id)
    local cached_notifications = load_cache()

    -- Find and remove the notification with matching ID
    for i, cached_notif in ipairs(cached_notifications) do
        if cached_notif.id == notification_id then
            table.remove(cached_notifications, i)
            save_cache(cached_notifications)
            return true
        end
    end
    return false
end

--- @treturn integer Number of notifications currently cached
function notification_cache.count()
    local cached = load_cache()
    return #cached
end

return notification_cache
