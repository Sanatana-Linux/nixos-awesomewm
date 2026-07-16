--- Client geometry placement and shape utilities.
-- Handles centering, keep-on-screen, maximized/fullscreen geometry
-- adjustments, and rounded-rect shape application.
-- @module core.client.placement

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local shapes = require("modules.style.shapes")
local dpi = beautiful.xresources.apply_dpi
local capi = { client = client }
local awesome = awesome

-- Place a client centered on its screen, then nudge it back inside the
-- workarea if it would otherwise be partially offscreen. This is what we
-- use as a `placement` for floating windows in `ruled.lua`.
-- @tparam client c
-- @tparam[opt] table opts Forwarded to `awful.placement.centered` and
--   `awful.placement.no_offscreen` (`{honor_workarea=bool, honor_padding=bool}`)
local function center_and_keep_on_screen(c, opts)
    local default_opts = { honor_workarea = true, honor_padding = true }
    local placement_opts = opts or default_opts

    awful.placement.centered(c, placement_opts)

    local offscreen_opts = {}
    if opts then
        offscreen_opts.honor_workarea = opts.honor_workarea
        offscreen_opts.honor_padding = opts.honor_padding
    else
        offscreen_opts = default_opts
    end

    awful.placement.no_offscreen(c, offscreen_opts)
end

--- Geometry adjustments for the `request::manage` signal.
-- Handles fullscreen fit-to-screen, maximized inset, and
-- transient-for centering.
-- @tparam client c
local function handle_manage_geometry(c)
    if c.fullscreen then
        c:geometry(c.screen.geometry)
    elseif c.maximized then
        local workarea = c.screen.workarea
        c:geometry({
            x = workarea.x + dpi(3),
            y = workarea.y + dpi(3),
            width = workarea.width - dpi(6),
            height = workarea.height - dpi(6),
        })
    elseif c.transient_for and not c.disallow_autocenter then
        awful.placement.centered(c, { parent = c.transient_for })
        awful.placement.no_offscreen(c)
    end
end

--- Startup no-offscreen placement.
-- Ensures windows spawned during startup without explicit position
-- hints are brought on-screen.
-- @tparam client c
local function handle_manage_startup(c)
    if
        awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position
    then
        awful.placement.no_offscreen(c)
    end
end

--- Apply rounded-rect shape to a client (nil when max/fullscreen).
-- The shape uses `modules.shapes.rrect(dpi(12))`.
-- @tparam client c
local function update_client_shape(c)
    if c.maximized or c.fullscreen then
        c.shape = nil
    else
        c.shape = shapes.rrect(dpi(12))
    end
end

--- Handle the `property::maximized` signal: update shape then
-- adjust geometry to fit within the workarea with inset padding.
-- @tparam client c
local function handle_maximized(c)
    update_client_shape(c)
    if c.maximized then
        local workarea = c.screen.workarea
        c:geometry({
            x = workarea.x + dpi(3),
            y = workarea.y + dpi(3),
            width = workarea.width - dpi(6),
            height = workarea.height - dpi(6),
        })
    end
end

--- Handle the `property::geometry` signal: delayed shape update.
-- Defers via `gears.timer.delayed_call` to avoid fighting the
-- layout engine.
-- @tparam client c
local function handle_geometry_shape(c)
    gears.timer.delayed_call(function()
        if c.valid then
            update_client_shape(c)
        end
    end)
end

return {
    center_and_keep_on_screen = center_and_keep_on_screen,
    handle_manage_geometry = handle_manage_geometry,
    handle_manage_startup = handle_manage_startup,
    update_client_shape = update_client_shape,
    handle_maximized = handle_maximized,
    handle_geometry_shape = handle_geometry_shape,
}
