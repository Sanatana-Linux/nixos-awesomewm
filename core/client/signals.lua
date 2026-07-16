---@diagnostic disable: undefined-global
--- Client signal wiring hub.
-- Connects client and tag signals to handler functions extracted in
-- dedicated submodules. Each submodule owns one concern:
--   * `placement.lua` — geometry, shape, keep-on-screen
--   * `focus.lua`     — sloppy focus, focus-back, timer
--   * `opacity.lua`   — type/class/focus-based opacity
--
-- Still exports `center_and_keep_on_screen` from the placement
-- module for use in `ruled.lua` placement rules.
-- @module core.client.signals

local placement = require("core.client.placement")
local focus = require("core.client.focus")
local opacity = require("core.client.opacity")

local capi = { client = client, tag = tag }

require("awful.autofocus")

-- Placement / geometry / shape
capi.client.connect_signal("request::manage", placement.handle_manage_geometry)
capi.client.connect_signal("manage", placement.handle_manage_startup)
capi.client.connect_signal("manage", placement.update_client_shape)
capi.client.connect_signal("property::maximized", placement.handle_maximized)
capi.client.connect_signal(
    "property::fullscreen",
    placement.update_client_shape
)
capi.client.connect_signal(
    "property::geometry",
    placement.handle_geometry_shape
)

-- Focus (sloppy, timer, focus-back)
capi.client.connect_signal("mouse::enter", focus.activate_under_pointer)
capi.tag.connect_signal("property::selected", focus.start_focus_timer)
capi.client.connect_signal("request::unmanage", focus.start_focus_timer)
capi.client.connect_signal("property::tags", focus.handle_tags_change)
capi.client.connect_signal("manage", focus.handle_manage_focus)
capi.client.connect_signal("property::minimized", focus.focus_back)
capi.client.connect_signal("unmanage", focus.focus_back)
capi.tag.connect_signal("property::selected", focus.focus_back)

-- Opacity
capi.client.connect_signal("manage", opacity.apply_opacity)
capi.client.connect_signal("focus", opacity.apply_opacity)
capi.client.connect_signal("unfocus", opacity.apply_opacity)

return {
    center_and_keep_on_screen = placement.center_and_keep_on_screen,
}
