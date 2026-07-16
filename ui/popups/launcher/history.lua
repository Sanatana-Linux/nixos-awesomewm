--- Launch history tracking for the launcher.
-- Persists app usage counts to disk so frequently-used apps appear
-- higher in search results. Data is stored as a Lua table in a file
-- that can be loaded via dofile().
-- @module ui.popups.launcher.history

local gfs = require("gears.filesystem")
local table_to_file = require("lib.util").table_to_file

local history = {}

local HISTORY_FILE = gfs.get_configuration_dir()
    .. "ui/popups/launcher/history.dat"

-- Maps app_id (string) -> usage count (number)
local usage_counts = {}

--- Load usage counts from disk. Silently no-ops if the file doesn't exist.
function history.load()
    local ok, data = pcall(dofile, HISTORY_FILE)
    if ok and type(data) == "table" then
        usage_counts = data
    end
end

--- Save usage counts to disk as a returnable Lua chunk.
-- Uses lib.table_to_file for serialization.
function history.save()
    table_to_file(usage_counts, HISTORY_FILE)
end

--- Record a launch for the given app ID, incrementing its usage count.
-- The count is persisted to disk immediately after recording.
-- @tparam string app_id The desktop file ID (e.g. "firefox.desktop")
function history.record_launch(app_id)
    if not app_id or app_id == "" then
        return
    end
    usage_counts[app_id] = (usage_counts[app_id] or 0) + 1
    history.save()
end

--- Get the usage score for an app ID. Returns 0 if never launched.
-- @tparam string|nil app_id
-- @treturn number Usage count (0+)
function history.get_score(app_id)
    if not app_id then
        return 0
    end
    return usage_counts[app_id] or 0
end

--- Build a comparator that sorts apps by usage (descending), then
-- alphabetically by name as tiebreaker. Designed to be passed as the
-- sort_fn argument to apps.filter().
-- @treturn function Comparator(a, b) -> boolean
function history.make_sort_fn()
    return function(a, b)
        local sa = history.get_score(a:get_id())
        local sb = history.get_score(b:get_id())
        if sa ~= sb then
            return sa > sb
        end
        return string.lower(a:get_name()) < string.lower(b:get_name())
    end
end

--- Reset all usage data (for testing or manual reset).
function history.clear()
    usage_counts = {}
end

-- Load persisted history on module init
history.load()

return history
