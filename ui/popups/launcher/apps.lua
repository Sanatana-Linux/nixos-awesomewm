--- App discovery, filtering, and launching for the launcher.
-- Encapsulates Gio.DesktopAppInfo operations and search/filter logic.
-- @module ui.popups.launcher.apps

local lgi = require("lgi")
local Gio = lgi.Gio
local awful = require("awful")
local lua_escape = require("lib.util").lua_escape

local apps = {}

--- Spawn the app's executable, honouring its Terminal=true flag.
-- Apps marked Terminal=true in their .desktop file get spawned inside
-- the user's default terminal emulator (resolved via
-- Gio.AppInfo.get_default_for_uri_scheme).
-- @tparam table app A Gio.DesktopAppInfo-like object
function apps.launch(app)
    if not app then
        return
    end

    -- Safely get desktop app info to check terminal requirement
    local term_needed = false
    if Gio.DesktopAppInfo then
        local status, desktop_app_info = pcall(function()
            return Gio.DesktopAppInfo.new(app:get_id())
        end)

        if status and desktop_app_info then
            local term_status, terminal_string = pcall(function()
                return desktop_app_info:get_string("Terminal")
            end)
            if term_status and terminal_string == "true" then
                term_needed = true
            end
        end
    end

    local term_status, term = pcall(function()
        return Gio.AppInfo.get_default_for_uri_scheme("terminal")
    end)
    if not term_status then
        term = nil
    end

    awful.spawn(
        term_needed
                and term
                and string.format(
                    "%s -e %s",
                    term:get_executable(),
                    app:get_executable()
                )
            or string.match(app:get_executable(), "^env") and string.gsub(
                app:get_commandline(),
                "%%%a",
                ""
            )
            or app:get_executable()
    )
end

--- Load all desktop applications. Wraps Gio.AppInfo.get_all() with pcall.
-- @treturn table Array of Gio.DesktopAppInfo-like objects
function apps.get_all()
    local status, result = pcall(function()
        return Gio.AppInfo.get_all()
    end)
    if status and result then
        return result
    end
    return {}
end

--- Filter apps by a search query with two-tier sort.
-- Prefix matches come first (sorted by optional sort_fn, then
-- alphabetically), then substring matches (also sorted). Hidden apps
-- (should_show() == false) are skipped. The query is lua_escape'd to
-- neutralise pattern metacharacters.
-- @tparam table apps_list Array of Gio.DesktopAppInfo-like objects
-- @tparam string query User-typed search string
-- @tparam[opt] function sort_fn Custom comparator (default: alphabetical)
-- @treturn table Filtered and sorted app list
function apps.filter(apps_list, query, sort_fn)
    query = lua_escape(query)
    local filtered = {}
    local filtered_any = {}

    if not sort_fn then
        sort_fn = function(a, b)
            return string.lower(a:get_name()) < string.lower(b:get_name())
        end
    end

    for _, app in ipairs(apps_list) do
        if app:should_show() then
            local name_match = string.lower(
                string.sub(app:get_name(), 1, #query)
            ) == string.lower(query)
            local name_match_any =
                string.match(string.lower(app:get_name()), string.lower(query))
            local exec_match_any = string.match(
                string.lower(app:get_executable()),
                string.lower(query)
            )

            if name_match then
                table.insert(filtered, app)
            elseif name_match_any or exec_match_any then
                table.insert(filtered_any, app)
            end
        end
    end

    table.sort(filtered, sort_fn)
    table.sort(filtered_any, sort_fn)

    for i = 1, #filtered_any do
        filtered[#filtered + 1] = filtered_any[i]
    end

    return filtered
end

return apps
