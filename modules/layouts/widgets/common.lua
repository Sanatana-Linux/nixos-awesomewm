local awful = require("awful")
local naughty = require("naughty")
local gtable = require("gears.table")
local ipairs = ipairs
local alayout = awful.layout
local utils = require("modules.layouts.widgets.utils")
local common = { handler = {}, last = {}, tips = {}, keys = {}, mouse = {} }
common.wfactstep = 0.05

--- Layout Navigator shared state.
-- Exposes a uniform API so any custom layout can plug into the Mod4+F2 navigation
-- mode without re-implementing key grabbing, tips, or mouse move handling.
-- @field handler table<awful.layout, function> Key handler per layout object
-- @field tips table<awful.layout, table> Hotkey tip entries per layout object
-- @field keys table<string, table> Default key tables (base, swap, tile, corner, magnifier)
-- @field mouse table Mouse-move handlers
-- @field wfactstep number Master width step (default 0.05)
-- @table common

-- default keys
common.keys.base = {
    {
        { "Mod4" },
        "c",
        function()
            common.action.kill()
        end,
        { description = "Kill application", group = "Action" },
    },
    {
        {},
        "Escape",
        function()
            common.action.exit()
        end,
        { description = "Exit navigation mode", group = "Action" },
    },
    {
        { "Mod4" },
        "Escape",
        function()
            common.action.exit()
        end,
        {}, -- hidden key
    },
    {
        { "Mod4" },
        "Super_L",
        function()
            common.action.exit()
        end,
        { description = "Exit navigation mode", group = "Action" },
    },
    {
        { "Mod4" },
        "F1",
        function()
            naughty.notify({
                title = "Layout Hints",
                text = "Use Mod4 + arrows to move clients, Mod4 + h/l for master size",
                timeout = 3,
            })
        end,
        { description = "Show hotkeys helper", group = "Action" },
    },
}
common.keys.swap = {
    {
        { "Mod4" },
        "Up",
        function()
            awful.client.swap.bydirection("up")
        end,
        { description = "Move application up", group = "Movement" },
    },
    {
        { "Mod4" },
        "Down",
        function()
            awful.client.swap.bydirection("down")
        end,
        { description = "Move application down", group = "Movement" },
    },
    {
        { "Mod4" },
        "Left",
        function()
            awful.client.swap.bydirection("left")
        end,
        { description = "Move application left", group = "Movement" },
    },
    {
        { "Mod4" },
        "Right",
        function()
            awful.client.swap.bydirection("right")
        end,
        { description = "Move application right", group = "Movement" },
    },
}
common.keys.tile = {
    {
        { "Mod4" },
        "l",
        function()
            awful.tag.incmwfact(common.wfactstep)
        end,
        { description = "Increase master width factor", group = "Layout" },
    },
    {
        { "Mod4" },
        "h",
        function()
            awful.tag.incmwfact(-common.wfactstep)
        end,
        { description = "Decrease master width factor", group = "Layout" },
    },
    {
        { "Mod4", "Shift" },
        "h",
        function()
            awful.tag.incnmaster(1, nil, true)
        end,
        {
            description = "Increase the number of master clients",
            group = "Layout",
        },
    },
    {
        { "Mod4", "Shift" },
        "l",
        function()
            awful.tag.incnmaster(-1, nil, true)
        end,
        {
            description = "Decrease the number of master clients",
            group = "Layout",
        },
    },
    {
        { "Mod4", "Control" },
        "h",
        function()
            awful.tag.incncol(1, nil, true)
        end,
        { description = "Increase the number of columns", group = "Layout" },
    },
    {
        { "Mod4", "Control" },
        "l",
        function()
            awful.tag.incncol(-1, nil, true)
        end,
        { description = "Decrease the number of columns", group = "Layout" },
    },
}
common.keys.corner = {
    {
        { "Mod4" },
        "l",
        function()
            awful.tag.incmwfact(common.wfactstep)
        end,
        { description = "Increase master width factor", group = "Layout" },
    },
    {
        { "Mod4" },
        "h",
        function()
            awful.tag.incmwfact(-common.wfactstep)
        end,
        { description = "Decrease master width factor", group = "Layout" },
    },
    {
        { "Mod4", "Shift" },
        "h",
        function()
            awful.tag.incnmaster(1, nil, true)
        end,
        {
            description = "Increase the number of master clients",
            group = "Layout",
        },
    },
    {
        { "Mod4", "Shift" },
        "l",
        function()
            awful.tag.incnmaster(-1, nil, true)
        end,
        {
            description = "Decrease the number of master clients",
            group = "Layout",
        },
    },
}
common.keys.magnifier = {
    {
        { "Mod4" },
        "l",
        function()
            awful.tag.incmwfact(common.wfactstep)
        end,
        { description = "Increase master width factor", group = "Layout" },
    },
    {
        { "Mod4" },
        "h",
        function()
            awful.tag.incmwfact(-common.wfactstep)
        end,
        { description = "Decrease master width factor", group = "Layout" },
    },
    {
        { "Mod4" },
        "g",
        function()
            awful.client.setmaster(client.focus)
        end,
        { description = "Set focused client as master", group = "Movement" },
    },
}
-- TODO: set real keyset from navigator theme
common.keys._fake = {
    {
        { "Mod4" },
        "N1 N2",
        nil,
        {
            description = "Swap clients by key",
            group = "Movement",
            keyset = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
        },
    },
    {
        { "Mod4" },
        "N1 N1",
        nil,
        {
            description = "Focus client by key",
            group = "Action",
            keyset = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
        },
    },
}
-- Common handler actions
-----------------------------------------------------------------------------------------------------------------------
common.action = {}

--- Exit the Mod4+F2 navigator and clear pending state.
function common.action.exit()
    utils.get_navigator():close()
    common.last = {}
end

--- Kill the focused client and restart the navigator.
function common.action.kill()
    client.focus:kill()
    utils.get_navigator():restart()
    common.last.key = nil
end

-- Keys setup
-----------------------------------------------------------------------------------------------------------------------

-- Hotkey tips update functions
--------------------------------------------------------------------------------
common.updates = {}

--- Build the tip table for layouts that only use base+swap keys.
-- @treturn table Joined key entries for the hotkeys popup
-- @local
local function build_base_tip()
    return gtable.join(common.keys.swap, common.keys.base, common.keys._fake)
end

--- Build the tip table for master/slave tiled layouts.
-- @treturn table Joined key entries (tile + swap + base + _fake)
-- @local
local function build_tile_tip()
    return gtable.join(
        common.keys.swap,
        common.keys.tile,
        common.keys.base,
        common.keys._fake
    )
end

--- Build the tip table for corner layouts.
-- @treturn table Joined key entries (corner + swap + base + _fake)
-- @local
local function build_corner_tip()
    return gtable.join(
        common.keys.swap,
        common.keys.corner,
        common.keys.base,
        common.keys._fake
    )
end

--- Build the tip table for the magnifier layout.
-- @treturn table Joined key entries (magnifier + base + _fake)
-- @local
local function build_magnifier_tip()
    return gtable.join(
        common.keys.magnifier,
        common.keys.base,
        common.keys._fake
    )
end

--- Assign the corner tip to all four corner layout variants.
-- @local
local function set_corner_tip()
    common.tips[alayout.suit.corner.nw] = build_corner_tip()
    common.tips[alayout.suit.corner.ne] = build_corner_tip()
    common.tips[alayout.suit.corner.sw] = build_corner_tip()
    common.tips[alayout.suit.corner.se] = build_corner_tip()
end

--- Assign the tile tip to all five tile layout variants.
-- @local
local function set_tile_tip()
    common.tips[alayout.suit.tile] = build_tile_tip()
    common.tips[alayout.suit.tile.right] = build_tile_tip()
    common.tips[alayout.suit.tile.left] = build_tile_tip()
    common.tips[alayout.suit.tile.top] = build_tile_tip()
    common.tips[alayout.suit.tile.bottom] = build_tile_tip()
end

--- Update tips for layouts that only use swap keys.
common.updates.swap = function()
    common.tips[alayout.suit.fair] = build_base_tip()
    common.tips[alayout.suit.spiral] = build_base_tip()
    common.tips[alayout.suit.spiral.dwindle] = build_base_tip()
    set_tile_tip()
    set_corner_tip()
end

--- Update tips for base-key layouts (fair, spiral, magnifier).
common.updates.base = function()
    common.tips[alayout.suit.fair] = build_base_tip()
    common.tips[alayout.suit.spiral] = build_base_tip()
    common.tips[alayout.suit.spiral.dwindle] = build_base_tip()
    common.tips[alayout.suit.magnifier] = build_magnifier_tip()
    set_tile_tip()
    set_corner_tip()
end

--- Update tips for the magnifier layout.
common.updates.magnifier = function()
    common.tips[alayout.suit.magnifier] = build_magnifier_tip()
end

--- Update tips for tile layouts.
common.updates.tile = function()
    set_tile_tip()
end

--- Update tips for corner layouts.
common.updates.corner = function()
    set_corner_tip()
end

-- Keys setup function
--------------------------------------------------------------------------------
--- Set or update key bindings for a given layout, then rebuild the tip table.
-- @tparam[opt] table keys New key bindings to register under `common.keys[layout]`
-- @tparam string layout Layout name (`"base"`, `"swap"`, `"tile"`, `"corner"`, `"magnifier"`)
function common:set_keys(keys, layout)
    if keys then
        common.keys[layout] = keys
    end -- update keys
    if self.updates[layout] then
        self.updates[layout]()
    end -- update tips
end

-- Shared keyboard handlers
-----------------------------------------------------------------------------------------------------------------------
common.grabbers = {}

-- Base grabbers
--------------------------------------------------------------------------------
-- Base grabber — handles kill, focus by number, swap by double-press.
--- @tparam table mod Key modifier table
-- @tparam string key Key name
-- @treturn boolean True if the key was consumed
common.grabbers.base = function(mod, key)
    for _, k in ipairs(common.keys.base) do
        if utils.match_grabber(k, mod, key) then
            k[3]()
            return true
        end
    end

    -- if numkey pressed
    local nav = utils.get_navigator()
    local index = gtable.hasitem(nav.style.num, key)

    -- swap or focus client
    if index then
        if
            nav.data[index]
            and gtable.hasitem(nav.cls, nav.data[index].client)
        then
            if common.last.key then
                if common.last.key == index then
                    client.focus = nav.data[index].client
                    client.focus:raise()
                else
                    utils.client_swap(
                        nav.data[common.last.key].client,
                        nav.data[index].client
                    )
                end
                common.last.key = nil
            else
                common.last.key = index
            end

            return true
        end
    end
end

--- Swap grabber — handles master-slave swap key bindings.
-- @tparam table mod
-- @tparam string key
-- @treturn boolean
common.grabbers.swap = function(mod, key)
    for _, k in ipairs(common.keys.swap) do
        if utils.match_grabber(k, mod, key) then
            k[3]()
            return true
        end
    end
end

--- Tile grabber — handles mwfact, nmaster, ncol key bindings.
-- @tparam table mod
-- @tparam string key
-- @treturn boolean
common.grabbers.tile = function(mod, key)
    for _, k in ipairs(common.keys.tile) do
        if utils.match_grabber(k, mod, key) then
            k[3]()
            return true
        end
    end
end

--- Corner grabber — handles mwfact, nmaster for corner layouts.
-- @tparam table mod
-- @tparam string key
-- @treturn boolean
common.grabbers.corner = function(mod, key)
    for _, k in ipairs(common.keys.corner) do
        if utils.match_grabber(k, mod, key) then
            k[3]()
            return true
        end
    end
end

--- Magnifier grabber — handles mwfact for the magnifier layout.
-- @tparam table mod
-- @tparam string key
-- @treturn boolean
common.grabbers.magnifier = function(mod, key)
    for _, k in ipairs(common.keys.magnifier) do
        if utils.match_grabber(k, mod, key) then
            k[3]()
            return true
        end
    end
end

-- Grabbers for awful layouts
--------------------------------------------------------------------------------
--- Fair/spiral keyboard handler — swap + base keys only.
-- @tparam table mod
-- @tparam string key
-- @tparam string event `"press"` or `"release"`
-- @treturn boolean True if handled
-- @local
local function fair_handler(mod, key, event)
    if event == "release" then
        return
    end
    if common.grabbers.swap(mod, key, event) then
        return true
    end
    if common.grabbers.base(mod, key, event) then
        return true
    end
end

--- Magnifier keyboard handler — magnifier + base keys.
-- @local
local function magnifier_handler(mod, key, event)
    if event == "release" then
        return
    end
    if common.grabbers.magnifier(mod, key, event) then
        return true
    end
    if common.grabbers.base(mod, key, event) then
        return true
    end
end

--- Tile keyboard handler — tile + swap + base keys.
-- @local
local function tile_handler(mod, key, event)
    if event == "release" then
        return
    end
    if common.grabbers.tile(mod, key, event) then
        return true
    end
    if common.grabbers.swap(mod, key, event) then
        return true
    end
    if common.grabbers.base(mod, key, event) then
        return true
    end
end

--- Corner keyboard handler — corner + swap + base keys.
-- @local
local function corner_handler(mod, key, event)
    if event == "release" then
        return
    end
    if common.grabbers.corner(mod, key, event) then
        return true
    end
    if common.grabbers.swap(mod, key, event) then
        return true
    end
    if common.grabbers.base(mod, key, event) then
        return true
    end
end

-- Handlers table
---------------------------------------------------------------------------------------
common.handler[alayout.suit.max] = magnifier_handler
common.handler[alayout.suit.fair] = fair_handler
common.handler[alayout.suit.spiral] = fair_handler
common.handler[alayout.suit.magnifier] = magnifier_handler
common.handler[alayout.suit.floating] = fair_handler
common.handler[alayout.suit.tile] = tile_handler
common.handler[alayout.suit.tile.right] = tile_handler
common.handler[alayout.suit.tile.left] = tile_handler
common.handler[alayout.suit.tile.top] = tile_handler
common.handler[alayout.suit.tile.bottom] = tile_handler
common.handler[alayout.suit.corner.nw] = corner_handler
common.handler[alayout.suit.corner.ne] = corner_handler
common.handler[alayout.suit.corner.se] = corner_handler
common.handler[alayout.suit.corner.sw] = corner_handler
common.handler[alayout.suit.spiral.dwindle] = fair_handler

-- Custom layout handler/tip registration
-- Called from init.lua after all layouts are loaded (avoids circular dep)
--- Register the layout-agnostic key handler and tip entries for every custom layout.
-- Master/slave layouts get the `tile_handler` (mwfact, nmaster, ncol). Others
-- get the simpler `fair_handler` (swap + base only).
-- @tparam table layouts Table of all loaded layout modules keyed by short name
function common.register_custom_layouts(layouts)
    -- Master/slave layouts get tile_handler (supports mwfact, nmaster, ncol)
    common.handler[layouts.mstab] = tile_handler
    common.handler[layouts.cascade.tile] = tile_handler
    common.handler[layouts.centerwork] = tile_handler
    common.handler[layouts.centerwork.horizontal] = tile_handler
    common.handler[layouts.termfair] = tile_handler
    common.handler[layouts.termfair.center] = tile_handler
    common.handler[layouts.thrizen] = tile_handler

    -- Non-master/slave layouts get fair_handler (swap + base only)
    common.handler[layouts.cascade] = fair_handler
    common.handler[layouts.deck] = fair_handler
    common.handler[layouts.equalarea] = fair_handler
    common.handler[layouts.termfair.stable] = fair_handler
    common.handler[layouts.grid] = fair_handler
    common.handler[layouts.map] = fair_handler
    common.handler[layouts.stack] = tile_handler
    common.handler[layouts.stack.left] = tile_handler

    -- Register tip entries for the hotkey popup
    common.tips[layouts.mstab] = build_tile_tip()
    common.tips[layouts.cascade] = build_base_tip()
    common.tips[layouts.cascade.tile] = build_tile_tip()
    common.tips[layouts.centerwork] = build_tile_tip()
    common.tips[layouts.centerwork.horizontal] = build_tile_tip()
    common.tips[layouts.termfair] = build_tile_tip()
    common.tips[layouts.termfair.center] = build_tile_tip()
    common.tips[layouts.termfair.stable] = build_base_tip()
    common.tips[layouts.thrizen] = build_tile_tip()
    common.tips[layouts.deck] = build_base_tip()
    common.tips[layouts.equalarea] = build_base_tip()
    common.tips[layouts.grid] = build_base_tip()
    common.tips[layouts.map] = build_base_tip()
    common.tips[layouts.stack] = build_tile_tip()
    common.tips[layouts.stack.left] = build_tile_tip()
end

-- tip dirty setup
common:set_keys(nil, "base")

-- Slightly changed awful mouse move handler
-----------------------------------------------------------------------------------------------------------------------
--- Mouse-move handler that swaps the focused client when the user moves a client onto it.
-- Slightly changed from the stock awful handler to honor custom layout `move_handler` overrides.
-- @tparam client c Client being moved
-- @tparam string context `awful.mouse.move` context token
-- @tparam table hints Geometry hints from the mouse-move event
function common.mouse.move(c, context, hints)
    -- Quit if it isn't a mouse.move on a tiled layout, that's handled elsewhere (WHERE?)
    if c.floating then
        return
    end
    if context ~= "mouse.move" then
        return
    end

    -- move to screen with mouse
    if mouse.screen ~= c.screen then
        c.screen = mouse.screen
    end

    -- check if cutstom layout hadler availible
    local l = c.screen.selected_tag and c.screen.selected_tag.layout or nil
    if l == awful.layout.suit.floating then
        return
    end

    if l and l.move_handler then
        l.move_handler(c, context, hints)
        return
    end

    -- general handler for tile layouts
    local c_u_m = mouse.current_client
    if c_u_m and not c_u_m.floating then
        if c_u_m ~= c then
            c:swap(c_u_m)
        end
    end
end

return common
