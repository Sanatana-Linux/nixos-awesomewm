-- https://github.com/garado/cozy/blob/main/sysconf/restore.lua
-- When restarting awesome, save client/tag state, restart, and then restore client/tag states.

local awful = require("awful")
local gfs = require("gears.filesystem")
local json = require("lib.json")

local cache_dir = gfs.get_cache_dir()
local client_cache = cache_dir .. "restore/client"
local tag_cache = cache_dir .. "restore/tag"
local focus_cache = cache_dir .. "restore/focus"

-- █▀█ █▀█ █▀▀ █▀ █▀▀ █▀█ █░█ █▀▀
-- █▀▀ █▀▄ ██▄ ▄█ ██▄ █▀▄ ▀▄▀ ██▄
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

local function preserve_focus(s)
    local t = awful.screen.focused().selected_tag
    awful.spawn.with_shell("echo " .. t.index .. " >> " .. focus_cache)
end

-- █▀█ █▀▀ █▀ ▀█▀ █▀█ █▀█ █▀▀
-- █▀▄ ██▄ ▄█ ░█░ █▄█ █▀▄ ██▄
local function find_layout(name)
    local layouts = awful.layout.layouts
    for i, _ in ipairs(layouts) do
        if layouts[i]["name"] == name then
            return layouts[i]
        end
    end
end

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
local function rel(screen, win)
    return {
        x = (win.x - screen.x) / screen.width,
        y = (win.y - screen.y) / screen.height,
        width = win.width / screen.width,
        aspect = win.height / win.width,
    }
end

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

local function forget(c)
    stored[c] = nil
end

local floating = awful.layout.suit.floating

function remember(c)
    if floating == awful.layout.get(c.screen) or c.floating then
        stored[c.window] = rel(c.screen.geometry, c:geometry())
    end
end

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
