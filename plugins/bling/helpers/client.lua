local awful = require("awful")
local gears = require("gears")

local _client = {}

--- Turn off passed client
-- Remove current tag from window's tags
--
-- @param c A client
function _client.turn_off(c, current_tag)
    current_tag = current_tag or c.screen.selected_tag
    local ctags = {}
    for _, tag in ipairs(c:tags()) do
        if tag ~= current_tag then
            table.insert(ctags, tag)
        end
    end
    c:tags(ctags)
    c.sticky = false
end

--- Turn on passed client (add current tag to window's tags)
--
-- @param c A client
function _client.turn_on(c)
    local current_tag = c.screen.selected_tag
    local ctags = { current_tag }
    for _, tag in ipairs(c:tags()) do
        if tag ~= current_tag then
            table.insert(ctags, tag)
        end
    end
    c:tags(ctags)
    c:raise()
    client.focus = c
end

--- Sync two clients
--
-- @param to_c The client to which to write all properties
-- @param from_c The client from which to read all properties
function _client.sync(to_c, from_c)
    if not from_c or not to_c or not from_c.valid or not to_c.valid or from_c.modal then
        return
    end
    to_c.floating = from_c.floating
    to_c.maximized = from_c.maximized
    to_c.above = from_c.above
    to_c.below = from_c.below
    to_c:geometry(from_c:geometry())
end

--- Checks whether the passed client is a child process of a given process ID
--
-- @param c A client
-- @param pid The process ID
-- @return True if the passed client is a child process of the given PID otherwise false
function _client.is_child_of(c, pid)
    if not c or not c.valid then
        return false
    end
    if tostring(c.pid) == tostring(pid) then
        return true
    end
    local pid_cmd = "pstree -T -p -a -s " .. tostring(c.pid) .. " | sed '2q;d' | grep -o '[0-9]*$' | tr -d '\n'"
    local handle = io.popen(pid_cmd)
    local parent_pid = handle:read("*a")
    handle:close()
    return tostring(parent_pid) == tostring(pid) or tostring(parent_pid) == tostring(c.pid)
end

--- Finds all clients that satisfy the passed rule
--
-- @param rule The rule to be searched for
-- @return A list of clients that match the given rule
function _client.find(rule)
    local clients = client.get()
    local findex = gears.table.hasitem(clients, client.focus) or 1
    local matches = {}
    for _, c in ipairs(clients) do
        if awful.rules.match(c, rule) then
            matches[#matches + 1] = c
        end
    end
    return matches
end

--- Gets the next client by direction from the focused one
--
-- @param direction The direction as a string ("up", "down", "left" or "right")
-- @return The client in the given direction starting at the currently focused one, nil otherwise
function _client.get_by_direction(direction)
    local sel = client.focus
    if not sel then
        return nil
    end
    local cltbl = sel.screen:get_clients()
    local geomtbl = {}
    for _, cl in ipairs(cltbl) do
        geomtbl[#geomtbl + 1] = cl:geometry()
    end
    local target = gears.geometry.rectangle.get_in_direction(direction, geomtbl, sel:geometry())
    return cltbl[target]
end

return _client