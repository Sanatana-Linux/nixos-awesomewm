local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local gears = require "gears"
local awful = require "awful"

local searchwidget = require "ui.bar.popups.launcher.search"

local function create_power_button(imagename, on_press, color)
  local widget = utilities.pointer_on_focus(wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.black,
    shape = utilities.mkroundedrect(),
    {
      widget = wibox.container.margin,
      margins = dpi(5),
      {
        widget = wibox.widget.imagebox,
        image = gears.color.recolor_image(gears.filesystem
                                              .get_configuration_dir() ..
                                              "themes/assets/icons/svg/" ..
                                              imagename, color),
        buttons = {
          awful.button {modifiers = {}, button = 1, on_press = on_press}
        }
      }
    }
  })
  widget:connect_signal("mouse::enter", function()
    widget.bg = beautiful.bg_focus
  end)
  widget:connect_signal("mouse::leave", function()
    widget.bg = beautiful.black
  end)
  return widget
end

local function create_launcher_widgets(s)
  return wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(10),
    {
      widget = wibox.container.place,
      valign = "top",
      halign = "center",
      {
        widget = wibox.container.background,
        bg = beautiful.black,
        shape = utilities.mkroundedrect(),
        {
          widget = wibox.container.margin,
          margins = dpi(5),
          {
            widget = wibox.container.constraint,
            strategy = "max",
            width = dpi(50),
            {
              layout = wibox.layout.fixed.vertical,
              spacing = dpi(5),
              create_power_button("poweroff.svg", function()
                awful.spawn("poweroff")
              end, beautiful.red),
              create_power_button("restart.svg", function()
                awful.spawn("reboot")
              end, beautiful.lesswhite),
              create_power_button("suspend.svg", function()
                awful.spawn("systemctl suspend")
              end, beautiful.lesswhite),
              create_power_button("lock.svg", function()
                awful.spawn("bash -c $HOME/.config/awesome/scripts/blur.sh")
              end, beautiful.lesswhite),
              create_power_button("logout.svg", function()
                awful.spawn("pkill awesome")
              end, beautiful.lesswhite)
            }
          }
        }
      }
    },
    {
      widget = wibox.container.background,
      bg = beautiful.black,
      shape = utilities.mkroundedrect(),
      {widget = wibox.container.margin, margins = dpi(5), searchwidget.init(s)}
    }
  }
end

local function init(s)
  local w, h = dpi(450), dpi(600)

  s.launcher = wibox {
    -- x = s.geometry.x + 2 * beautiful.useless_gap,
    -- y = s.geometry.y - beautiful.bar_height + 12 * beautiful.useless_gap,
    ontop = true,
    width = w,
    height = h,
    screen = s,
    widget = wibox.widget {
      widget = wibox.container.margin,
      margins = dpi(10),
      create_launcher_widgets(s)
    }	
  }

	awful.placement.bottom_left(s.launcher, {
		margins = {
			bottom = beautiful.bar_height + beautiful.useless_gap * 1.5,
			right = beautiful.useless_gap * 2
		}
	})

  function s.launcher:show()
    self.visible = true
  end
  function s.launcher:hide()
    self.visible = false
    local searchwidget_instance = s.popup_launcher_widget
    if searchwidget_instance:is_active() then
      searchwidget_instance:stop_search()
    end
  end
end

local function show(s)
  s.launcher:show()
end

local function run_applauncher(s)
  s.launcher:show()
  s.popup_launcher_widget:start_search(true)
end

local function hide(s)
  s.launcher:hide()
end

local function toggle()
  if s.launcher.visible == true then
    s.launcher:hide()
  else
    s.launcher:show()
  end
end

return {
  init = init,
  show = show,
  hide = hide,
	toggle = toggle,
  run_applauncher = run_applauncher
}
