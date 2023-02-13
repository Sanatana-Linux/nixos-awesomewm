---@diagnostic disable: undefined-global
local wibox = require "wibox"
local beautiful = require "beautiful"
local awful = require "awful"
local helpers = require "helpers"


local function get_icon(s)
 

  local icon = wibox.widget {
    id = "notification_action_icon",
    markup = "<span foreground='" .. beautiful.fg_normal.. "'>" .. "" ..
    "</span>",
    align = "center",
    font = beautiful.nerd_font .. " 24",
    widget = wibox.widget.textbox
  }

  
  local notif_icon_container = utilities.mkbtn({
    icon,
    bg = beautiful.black,
    widget = wibox.container.background
  }, beautiful.bg_normal, beautiful.bg_dimblack)
  
  local notif_popup = awful.popup {
    widget = wibox.container.background,
    visible = false,
    ontop = true,
    maximum_height = beautiful.wibar_height - dpi(20),
    forced_width = dpi(500),
    placement = function(c)
        awful.placement.bottom_right(c, {
          margins = {
            bottom = beautiful.bar_height + beautiful.useless_gap * 2,
            right = beautiful.useless_gap * 2 + 85
          }
        })
    end,
    border_color = beautiful.grey,
    border_width = beautiful.widget_border_width
  }
  
function notification_center_show()
    notif_popup.widget = wibox.widget {
      require("ui.notifications.notification-center"),
      widget = wibox.container.margin
  }
  notif_popup.screen = awful.screen.focused()
  notif_popup.visible = true
  icon.margins = {
      top = dpi(10),
      bottom = dpi(9),
      left = dpi(12),
      right = dpi(12)
  }
  end

  function notification_center_hide()
    notif_popup.widget = wibox.widget {
      require("ui.notifications.notification-center"),
      widget = wibox.container.margin
  }
  notif_popup.screen = awful.screen.focused()
  notif_popup.visible = false
  icon.margins = {
      top = dpi(10),
      bottom = dpi(9),
      left = dpi(12),
      right = dpi(12)
  }
  end


  local tooltip = helpers.make_popup_tooltip("Press to take a screenshot",
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
      awesome.connect_signal("screenshot::show", function()
        icon:set_markup_silently(helpers.get_colorized_markup(CAMERA_ICON,
                                                              beautiful.grey))
      end)
    else
        awesome.connect_signal("screenshot::hide", function()
      icon:set_markup_silently(CAMERA_ICON)
        end)
    end
  end))

  return icon
end

return get_icon
