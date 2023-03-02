---@diagnostic disable: undefined-global
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")

local icon = wibox.widget.textbox()
local placeholder = wibox.widget.textbox()

 icon.font = beautiful.nerd_font .. ' 20'
icon.markup = utilities.get_colorized_markup("", beautiful.light_grey)

-- to make a large input by default
placeholder.markup = utilities.get_colorized_markup(
                         "Launch...                          ", beautiful.light_grey)

local reset = function()
  placeholder.markup = utilities.get_colorized_markup(
                           "Launch...                          ", beautiful.light_grey)
end

local get_input = function()
  awful.prompt.run {
    prompt = "",
    text = "",
    bg_cursor = beautiful.lessgrey,
    textbox = placeholder,
    hooks = {{{}, "Escape", reset}},
    done_callback = reset,
    completion_callback = awful.completion.shell,
    exe_callback = function(prog)
      if not prog or #prog == 0 then
        return
      end
      awful.spawn(prog)
    end
  }
end

local input = wibox.widget {
  {
    {icon, placeholder, spacing = 8, layout = wibox.layout.fixed.horizontal},
    left = 6,
    right = 6,
    widget = wibox.container.margin
  },
  bg = beautiful.black,
  border_color = beautiful.grey,
  border_width = 0.75,
  forced_width = dpi(160),
  shape = utilities.mkroundedrect(),
  widget = wibox.container.background
}

utilities.add_hover(input, beautiful.black, beautiful.bg_focus)

awesome.connect_signal("bar::searchbox::get_input", get_input)

input:add_button(awful.button({}, 1, function()
  awesome.emit_signal("bar::searchbox::get_input")
end))

return wibox.widget {
  input,
  top = 3,
  bottom = 3,
  widget = wibox.container.margin
}
