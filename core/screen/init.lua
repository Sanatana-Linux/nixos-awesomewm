--- Screen management.
-- Makes the largest connected display the primary workspace, regardless of
-- RandR output names (DP-4, HDMI-0, …) or Xinerama index assignment, and
-- applies a small `dpi(3)` padding to every screen's workarea.
--
-- `screen.primary` is read-only in AwesomeWM — assigning it from Lua is
-- silently ignored — so the primary is enforced at the X level with
-- `xrandr --output <largest> --primary`. Everything is re-evaluated on
-- `property::geometry`, `added` and `removed`, so a layout applied after
-- startup settles on the same deterministic result.
-- @module core.screen

local capi = { screen = screen, awesome = awesome }
local awful = require("awful")
local gtimer = require("gears.timer")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local screen_module = {}

--- Pick the preferred primary screen from AwesomeWM's screen list.
-- The preferred primary is the connected screen with the largest area,
-- independent of output names and index assignment. Ties resolve to the
-- lowest index. Kept for callers that need the screen object; the actual
-- primary is enforced via RandR (see `override_primary`).
--
-- NB: do not use `#screen` — it reports 0 even with multiple screens; use
-- `screen.count()`.
-- @treturn screen The preferred primary screen
function screen_module.get_preferred_primary()
    local best, best_area = nil, -1

    for s in capi.screen do
        local geo = s.geometry
        local area = geo.width * geo.height

        if area > best_area then
            best, best_area = s, area
        end
    end

    return best or capi.screen.primary
end

--- Parse `xrandr --query` output.
-- Returns the name of the connected output with the largest area and the
-- name of the output currently flagged `primary` (which may be a
-- disconnected output, in which case it is ignored).
-- @tparam string stdout Raw `xrandr --query` output
-- @treturn string|nil name of the largest connected output
-- @treturn string|nil name of the current primary output
-- @local
local function parse_outputs(stdout)
    local best_name, best_area = nil, -1
    local current_primary = nil

    for line in stdout:gmatch("[^\n]+") do
        local name, rest = line:match("^(%S+) connected%s+(.*)$")

        if name then
            -- A `primary` flag may appear before the geometry; detect it
            -- wherever it sits in the rest of the line.
            if rest:find("%f[%w]primary%f[%W]") then
                current_primary = name
            end

            local w, h = rest:match("(%d+)x(%d+)%+")
            if not w then
                w, h = rest:match("(%d+)x(%d+)")
            end

            if w and h then
                local area = tonumber(w) * tonumber(h)
                if area > best_area then
                    best_name, best_area = name, area
                end
            end
        end
    end

    return best_name, current_primary
end

--- Ensure the largest connected output is the RandR primary.
-- `screen.primary` cannot be set from Lua, so this runs `xrandr --primary`
-- when the current primary is not the largest connected output. Emits
-- `screen::primary_override` after the change so the UI can rebuild bars.
function screen_module.override_primary()
    awful.spawn.easy_async_with_shell("xrandr --query", function(stdout)
        local best, current = parse_outputs(stdout or "")

        if not best or best == current then
            return
        end

        io.stderr:write(
            string.format(
                "[SCREEN] Setting primary output to %s (was %s)\n",
                best,
                tostring(current)
            )
        )

        awful.spawn.easy_async_with_shell(
            "xrandr --output " .. best .. " --primary",
            function()
                capi.awesome.emit_signal("screen::primary_override")
            end
        )
    end)
end

--- Apply `dpi(3)` padding to every screen's workarea.
-- Creates a consistent gap between windows and screen edges.
function screen_module.setup_screen_padding()
    local padding_size = dpi(3)

    for s in capi.screen do
        s.padding = {
            left = padding_size,
            right = padding_size,
            top = padding_size,
            bottom = padding_size,
        }
    end
end

--- Re-evaluate primary + padding, coalescing bursts of geometry events.
-- RandR emits many `property::geometry` signals while a layout is applied;
-- a delayed call plus the `pending` flag collapses them into one pass.
-- @local
local pending = false
local function refresh()
    if pending then
        return
    end
    pending = true

    gtimer.delayed_call(function()
        pending = false
        screen_module.override_primary()
        screen_module.setup_screen_padding()
    end)
end

--- Watch a screen's geometry so a layout applied after startup is caught.
-- @tparam screen s The screen to watch
-- @local
local function watch_screen(s)
    s:connect_signal("property::geometry", refresh)
end

--- Wire up screen change handling. Called automatically at module load.
function screen_module.setup_screen_handling()
    screen_module.override_primary()
    screen_module.setup_screen_padding()

    for s in capi.screen do
        watch_screen(s)
    end

    capi.screen.connect_signal("added", function(s)
        gtimer.delayed_call(function()
            watch_screen(s)
            refresh()
        end)
    end)

    capi.screen.connect_signal("removed", function()
        refresh()
    end)
end

screen_module.setup_screen_handling()

return screen_module
