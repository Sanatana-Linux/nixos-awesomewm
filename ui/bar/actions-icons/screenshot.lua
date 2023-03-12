---@diagnostic disable: undefined-global
local wibox = require "wibox"
local beautiful = require "beautiful"
local awful = require "awful"

require("ui.bar.actions-icons.widgets.screenshot-select")

local function get_icon(s)
  local CAMERA_ICON = ""

  local icon = wibox.widget {
    id = "screenshot_action_icon",
    markup = CAMERA_ICON,
    align = "center",
    font = beautiful.nerd_font .. " 24",
    widget = wibox.widget.textbox
  }

  local tooltip = utilities.make_popup_tooltip("Press to take a screenshot",
                                             function(d)
    return awful.placement.bottom_right(d, {
      margins = {
        bottom = beautiful.bar_height + beautiful.useless_gap * 2,
        right = beautiful.useless_gap * 2 + 85
      }
    })
  end)

  tooltip.attach_to_object(icon)

  icon:add_button(awful.button({}, 1, function()
    s.screenshot_selecter.toggle()
    tooltip.toggle()

    if s.screenshot_selecter.popup.visible then
      icon:set_markup_silently(utilities.get_colorized_markup(CAMERA_ICON,
                                                              beautiful.grey))
      awesome.emit_signal("screenshot::show")
    else
      icon:set_markup_silently(CAMERA_ICON)
        awesome.emit_signal("screenshot::hide")
    end
  end))

  awesome.connect_signal("screenshot::show", function()
    icon:set_markup_silently(utilities.get_colorized_markup(CAMERA_ICON,
    beautiful.grey))
  end)

  awesome.connect_signal("screenshot::hide", function()
    icon:set_markup_silently(CAMERA_ICON)
  end)

  return icon
end

return get_icon
