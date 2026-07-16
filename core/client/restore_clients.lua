-- https://github.com/garado/cozy/blob/main/sysconf/restore.lua
--- Client/tag state persistence across AwesomeWM restarts.
-- On `exit` (with restart=true): saves each screen's client geometry,
-- tag layouts, and focused-tag index to JSON flat files under
-- `gears.filesystem.get_cache_dir() .. "restore/"`.
-- On `startup`: reads those files back to restore state.
--
-- Also remembers per-client floating geometry via `remember()` /
-- `restore()` signal hooks so floating clients keep their position
-- when switching between tiled and floating layouts.
-- @module core.client.restore_clients

local awful = require("awful")
local gfs = require("gears.filesystem")
local json = require("lib.json")

local cache_dir = gfs.get_cache_dir()
local client_cache = cache_dir .. "restore/client"
local tag_cache = cache_dir .. "restore/tag"
local focus_cache = cache_dir .. "restore/focus"

--- Save all client geometries on this screen to a JSON flat file.
-- Triggers on restart (`exit` with restart=true). Each client's
-- width, height, x, y, active, and hidden state are persisted.
-- @tparam screen s
-- @local
local function preserve_client_state(s)
    local clients = {}

    for i, c in ipairs(s.all_clients) do
        clients[i] = {}
        if c.width then
            clients[i].width = c.width
        end
        if c.height then
            clients[i].height = c.height
        end
        if c.x then
            clients[i].x = c.x
        end
        if c.y then
            clients[i].y = c.y
        end
        if c.active then
            clients[i].active = c.active
        end
        if c.hidden then
            clients[i].hidden = c.hidden
        end
    end

    local jsonified = json.encode(clients)
    jsonified = string.gsub(jsonified, '"', "@")
    awful.spawn.with_shell('echo "' .. jsonified .. '" >> ' .. client_cache)
end

--- Save all tag layouts and master-width factors on this screen.
-- Triggers on restart. Each tag's `layout.name` and
-- `master_width_factor` are persisted.
-- @tparam screen s
-- @local
local function preserve_tag_state(s)
    local taglist = {}

    for i, t in ipairs(root.tags()) do
        taglist[i] = {}
        if t.layout and t.layout.name then
            taglist[i].layout = t.layout.name
        end

        if t.master_width_factor then
            taglist[i].master_width_factor = t.master_width_factor
        end
    end

    local jsonified = json.encode(taglist)
    jsonified = string.gsub(jsonified, '"', "@")
    awful.spawn.with_shell('echo "' .. jsonified .. '" >> ' .. tag_cache)
end

--- Save the currently focused tag index on this screen.
-- Triggers on restart. Writes a single integer to a cache file.
-- @tparam screen s
-- @local
local function preserve_focus(s)
    local t = awful.screen.focused().selected_tag
    awful.spawn.with_shell("echo " .. t.index .. " >> " .. focus_cache)
end

-- █▀█ █▀▀ █▀ ▀█▀ █▀█ █▀█ █▀▀
-- █▀▄ ██▄ ▄█ ░█░ █▄█ █▀▄ ██▄
--- Find a layout object by its `name` field.
-- Searches `awful.layout.layouts` for a layout whose `.name` matches.
-- @tparam string name Layout name to find
-- @treturn table|nil The layout object, or nil
local function find_layout(name)
    local layouts = awful.layout.layouts
    for i, _ in ipairs(layouts) do
        if layouts[i]["name"] == name then
            return layouts[i]
        end
    end
end

--- Restore tag layouts and master-width factors from persisted cache.
-- Async-reads the tag cache file and applies stored values.
-- @tparam screen s
-- @local
local function restore_tag_state(s)
    if not gfs.file_readable(tag_cache) then
        return
    end

    -- not sure if this should be async or not
    awful.spawn.easy_async_with_shell("cat " .. tag_cache, function(stdout)
        stdout = string.gsub(stdout, "@", '"')
        local state = json.decode(stdout)

        for i, t in ipairs(root.tags()) do
            t.master_width_factor = state[i].master_width_factor

            local layout = find_layout(state[i].layout)
            if layout then
                t.layout = layout
            end
        end
    end)
end

--- Restore client geometries from persisted cache.
-- Async-reads the client cache file and applies stored x/y/width/height.
-- @tparam screen s
-- @local
local function restore_client_state(s)
    if not gfs.file_readable(client_cache) then
        return
    end

    awful.spawn.easy_async_with_shell("cat " .. client_cache, function(stdout)
        stdout = string.gsub(stdout, "@", '"')
        local state = json.decode(stdout)

        for i, c in ipairs(s.all_clients) do
            for k, v in pairs(state[i]) do
                -- cannot set active directly
                if k == "active" then
                    c:activate()
                else
                    c[k] = v
                end
            end
        end
    end)
end

--- Restore focused tag index from persisted cache.
-- Async-reads the focus cache file and activates the stored tag.
-- @tparam screen s
-- @local
local function restore_focus_state(s)
    if not gfs.file_readable(focus_cache) then
        return
    end

    awful.spawn.easy_async_with_shell("cat " .. focus_cache, function(stdout)
        local idx = string.gsub(stdout, "\r\n", "")
        idx = tonumber(idx)
        for i, t in ipairs(root.tags()) do
            if i == idx then
                t:view_only()
                return
            end
        end
    end)
end

-- █▀▀ █░░ █▀█ ▄▀█ ▀█▀ █ █▄░█ █▀▀   █▀▀ █▀▀ █▀█ █▀▄▀█ █▀▀ ▀█▀ █▀█ █▄█
-- █▀░ █▄▄ █▄█ █▀█ ░█░ █ █░▀█ █▄█   █▄█ ██▄ █▄█ █░▀░█ ██▄ ░█░ █▀▄ ░█░
--- Convert a window's absolute geometry to screen-relative coordinates.
-- Returns `{x, y, width, aspect}` where x/y are fractions of screen
-- dimensions and `aspect = height/width`.
-- @tparam screen screen
-- @tparam table win A client geometry table `{x, y, width, height}`
-- @treturn table Relative geometry `{x=n, y=n, width=n, aspect=n}`
local function rel(screen, win)
    return {
        x = (win.x - screen.x) / screen.width,
        y = (win.y - screen.y) / screen.height,
        width = win.width / screen.width,
        aspect = win.height / win.width,
    }
end

--- Convert screen-relative geometry back to absolute pixel coordinates.
-- Inverse of `rel()`.
-- @tparam screen s
-- @tparam table rel Relative geometry `{x, y, width, aspect}`
-- @treturn table|nil Absolute geometry `{x, y, width, height}`, or nil
local function unrel(s, rel)
    return rel
        and {
            x = s.x + s.width * rel.x,
            y = s.y + s.height * rel.y,
            width = s.width * rel.width,
            height = rel.aspect * s.width * rel.width,
        }
end

local stored = {}

--- Remove a client from the floating-geometry store.
-- @tparam client c
local function forget(c)
    stored[c] = nil
end

local floating = awful.layout.suit.floating

--- Store a client's floating geometry when placed in floating layout.
-- Triggers on `manage` and `property::geometry` signals.
-- @tparam client c
function remember(c)
    if floating == awful.layout.get(c.screen) or c.floating then
        stored[c.window] = rel(c.screen.geometry, c:geometry())
    end
end

--- Restore a client's stored floating geometry.
-- Called when switching to a floating layout.
-- @tparam client c
-- @treturn boolean True if geometry was restored, false if no stored state
function restore(c)
    local s = stored[c.window]
    if s then
        c:geometry(unrel(c.screen.geometry, stored[c.window]))
        return true
    else
        return false
    end
end

client.connect_signal("manage", remember)
client.connect_signal("property::geometry", remember)
client.connect_signal("unmanage", forget)

tag.connect_signal("property::layout", function(t)
    if floating == awful.layout.get(t.screen) then
        for _, c in ipairs(t:clients()) do
            c:geometry(unrel(t.screen.geometry, stored[c.window]))
        end
    end
end)

-- Save states on restart
awesome.connect_signal("exit", function(reason_restart)
    if reason_restart then
        -- Clear the caches
        local cmd
        cmd = "echo '' > " .. tag_cache
        awful.spawn.with_shell(cmd)

        cmd = "echo '' > " .. client_cache
        awful.spawn.with_shell(cmd)

        cmd = "echo '' > " .. focus_cache
        awful.spawn.with_shell(cmd)

        -- Then write state
        for s in screen do
            preserve_focus(s)
            preserve_client_state(s)
            preserve_tag_state(s)
        end
    end
end)

-- Restore states on startup, if applicable
awesome.connect_signal("startup", function()
    for s in screen do
        restore_client_state(s)
        restore_tag_state(s)
        restore_focus_state(s)
    end
end)

return restore
