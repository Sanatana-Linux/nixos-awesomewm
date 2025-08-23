--[[
  Module Loader

  This file returns a table containing all available modules for the AwesomeWM configuration.
  Each key represents a module name, and its value is the required module.
  Modules included:
    - hover_button: UI button with hover effects
    - calendar: Calendar widget
    - remote_watch: Watches remote resources
    - text_input: Text input widget
    - menu: Custom menu widget
    - dropdown: Dropdown selection widget
    - snap_edge: Window edge snapping functionality
]]

return {

    hover_button = require("modules.hover_button"),
    calendar = require("modules.calendar"),
    remote_watch = require("modules.remote_watch"),
    text_input = require("modules.text_input"),
    menu = require("modules.menu"),
    dropdown = require("modules.dropdown"),
    snap_edge = require("modules.snap_edge"),
}
