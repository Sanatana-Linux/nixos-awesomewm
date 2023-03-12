---@diagnostic disable: undefined-global
--            __ __               
-- .--.--.--.|__|  |--.---.-.----.
-- |  |  |  ||  |  _  |  _  |   _|
-- |________||__|_____|___._|__|  
-- -------------------------------------------------------------------------- --
--                            libraries and modules                           --
-- -------------------------------------------------------------------------- --
-- 
local searchbar = require("ui.bar.widgets.searchbox")
local network = require("ui.bar.actions-icons.network")
local volume = require("ui.bar.actions-icons.volume")
local get_screenshot_icon = require("ui.bar.actions-icons.screenshot")
-- local get_notification_icon = require("ui.bar.actions-icons.notifications")
local battery_widget = require("ui.bar.widgets.battery")

require("ui.bar.widgets.calendar")
require("ui.bar.widgets.tray")
-- -------------------------------------------------------------------------- --
-- assign to each screen 
screen.connect_signal("request::desktop_decoration", function(s)

  -- -------------------------------------------------------------------------- --
  --                                    tags                                    --
  -- -------------------------------------------------------------------------- --
  -- 
  awful.tag({"1", "2", "3", "4", "5", "6"}, s, awful.layout.layouts[1])
  local get_tags = require("ui.bar.widgets.tags")
  local taglist = get_tags(s)

  -- -------------------------------------------------------------------------- --
  --                                  launcher                                  --
  -- -------------------------------------------------------------------------- --
  -- 
  local launcher = utilities.mkbtn({
    image = beautiful.launcher_icon,
    screen = s,
    forced_height = dpi(24),
    forced_width = dpi(24),
    halign = "center",
    valign = "center",
    widget = wibox.widget.imagebox
  }, beautiful.black, beautiful.bg_focus)

  local launcher_tooltip = utilities.make_popup_tooltip("Search Applications",
                                                        function(d)
    return awful.placement.bottom_left(d, {
      margins = {
        bottom = beautiful.bar_height + beautiful.useless_gap * 2,
        left = beautiful.useless_gap * 2
      }
    })
  end)

  launcher_tooltip.attach_to_object(launcher)
  launcher_popup = require("ui.bar.popups.launcher")
  launcher_popup.init(s)

  launcher:add_button(awful.button({}, 1, function()
    launcher_tooltip.hide()
    launcher_popup.run_applauncher(s)

  end))
  -- -------------------------------------------------------------------------- --
  --                                  dashboard                                 --
  -- -------------------------------------------------------------------------- --
  -- 
  local settings_button = utilities.mkbtn({
    widget = wibox.widget.imagebox,
    image = beautiful.menu_icon,
    forced_height = dpi(24),
    forced_width = dpi(24),
    halign = "center"
  }, beautiful.black, beautiful.bg_focus)

  local settings_tooltip = utilities.make_popup_tooltip("Toggle dashboard",
                                                        function(d)
    return awful.placement.bottom_left(d, {
      margins = {
        bottom = beautiful.bar_height + beautiful.useless_gap * 2,
        left = beautiful.useless_gap * 2 + 165
      }
    })
  end)

  settings_tooltip.attach_to_object(settings_button)
  notif_center = require("ui.bar.popups.quicksettings")
  notif_center.init(s)
  settings_button:add_button(awful.button({}, 1, function()
    require("ui.dashboard")
    awesome.emit_signal("dashboard::toggle")
  end))
  settings_button:add_button(awful.button({}, 3, function()
    awesome.emit_signal("quicksettings::toggle", s)
end))



  -- -------------------------------------------------------------------------- --
  --                                   systray                                  --
  -- -------------------------------------------------------------------------- --
  -- 
  local tray_dispatcher = wibox.widget {
    image = beautiful.tray_chevron_up,
    forced_height = 10,
    forced_width = 10,
    valign = "center",
    halign = "center",
    widget = wibox.widget.imagebox
  }

  local tray_dispatcher_tooltip = utilities.make_popup_tooltip(
                                      "Press to toggle the systray panel",
                                      function(d)
        return awful.placement.bottom_right(d, {
          margins = {
            bottom = beautiful.bar_height + beautiful.useless_gap * 2,
            right = beautiful.useless_gap * 33
          }
        })
      end)

  tray_dispatcher:add_button(awful.button({}, 1, function()
    awesome.emit_signal("tray::toggle")
    tray_dispatcher_tooltip.hide()

    if s.tray.popup.visible then
      tray_dispatcher.image = beautiful.tray_chevron_down
    else
      tray_dispatcher.image = beautiful.tray_chevron_up
    end
  end))

  tray_dispatcher_tooltip.attach_to_object(tray_dispatcher)
  -- -------------------------------------------------------------------------- --
  --                               action buttons                               --
  -- -------------------------------------------------------------------------- --
  -- make screenshot action icon global to edit it in anothers contexts.
  s.myscreenshot_action_icon = get_screenshot_icon(s)
  -- s.notification_icon = get_notification_icon(s)
  local actions_icons_container = utilities.mkbtn({
    {
      network,
      s.myscreenshot_action_icon,
      spacing = dpi(4),
      layout = wibox.layout.fixed.horizontal
    },
    left = dpi(5),
    right = dpi(6),
    widget = wibox.container.margin
  }, beautiful.black, beautiful.bg_focus)

  -- -------------------------------------------------------------------------- --
  --                                    clock                                   --
  -- -------------------------------------------------------------------------- --
  local clock_formats = {hour = "%H:%M", day = "%d/%m/%Y"}

  local clock = wibox.widget {
    format = clock_formats.hour,
    font = beautiful.title_font,
    widget = wibox.widget.textclock
  }

  local date = wibox.widget {
    {
      {widget = wibox.container.margin, left = dpi(15), right = dpi(15), clock},
      fg = beautiful.fg_normal,
      bg = beautiful.black,
      border_width = 0.75,
      border_color = beautiful.grey,
      widget = wibox.container.background,
      shape = utilities.mkroundedrect()
    },
    left = dpi(3),
    right = dpi(3),
    widget = wibox.container.margin
  }

  date:connect_signal("mouse::enter", function()
    awesome.emit_signal("calendar::visibility", true)
  end)

  date:connect_signal("mouse::leave", function()
    awesome.emit_signal("calendar::visibility", false)
  end)

  date:add_button(awful.button({}, 1, function()
    clock.format = clock.format == clock_formats.hour and clock_formats.day or
                       clock_formats.hour
  end))
  -- -------------------------------------------------------------------------- --
  --                                 layout box                                 --
  -- -------------------------------------------------------------------------- --
  -- 
  local base_layoutbox = awful.widget.layoutbox {
    screen = s,
    halign = "center",
    valign = "center"
  }

  -- remove built-in tooltip.
  base_layoutbox._layoutbox_tooltip:remove_from_object(base_layoutbox)

  -- create button container
  local layoutbox = utilities.mkbtn({
    widget = wibox.container.margin,
    left = dpi(5),
    right = dpi(5),
    base_layoutbox
  }, beautiful.black, beautiful.bg_focus)

  -- capitalize the layout name for consistency 
  local function layoutname()
    return "Layout: " .. utilities.capitalize(awful.layout.get(s).name)
  end

  -- make custom tooltip for the whole button
  local layoutbox_tooltip = utilities.make_popup_tooltip(layoutname(),
                                                         function(d)
    return awful.placement.bottom_right(d, {
      margins = {
        bottom = beautiful.bar_height + beautiful.useless_gap * 2,
        right = beautiful.useless_gap * 2
      }
    })
  end)

  layoutbox_tooltip.attach_to_object(layoutbox)

  -- updates tooltip content
  local update_content = function()
    layoutbox_tooltip.widget.text = layoutname()
  end

  tag.connect_signal("property::layout", update_content)
  tag.connect_signal("property::selected", update_content)

  -- layoutbox buttons
  utilities.add_buttons(layoutbox, {
    awful.button({}, 1, function()
      awesome.emit_signal("layout::changed:next")
    end),
    awful.button({}, 3, function()
      awesome.emit_signal("layout::changed:prev")
    end)
  })

  -- -------------------------------------------------------------------------- --
  --                               widget templates                              --
  -- -------------------------------------------------------------------------- --
  -- 
  local function mkcontainer(template)
    return wibox.widget {
      template,
      left = dpi(8),
      right = dpi(8),
      top = dpi(6),
      bottom = dpi(6),
      widget = wibox.container.margin
    }
  end

  s.mywibox = awful.wibar {
    position = "bottom",
    screen = s,
    width = s.geometry.width,
    height = beautiful.bar_height,
    shape = gears.shape.rectangle,
    bg = scheme.alpha(beautiful.bg_normal, 'cc'),
  }
  -- -------------------------------------------------------------------------- --
  --                                    setup                                   --
  -- -------------------------------------------------------------------------- --
  -- 
  s.mywibox:setup{
    {
      layout = wibox.layout.align.horizontal,
      
      border_color = beautiful.grey,
      border_width = dpi(1),
      {
        {
          mkcontainer {
            launcher,
            settings_button,
            spacing = dpi(12),
            layout = wibox.layout.fixed.horizontal
          },
          widget = wibox.container.margin
        },
        layout = wibox.layout.fixed.horizontal
      },
      nil,
      {
        mkcontainer {
          {tray_dispatcher, right = dpi(8), widget = wibox.container.margin},
          battery_widget,
          actions_icons_container,
          date,
          layoutbox,
          spacing = dpi(8),
          layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.fixed.horizontal
      }
    },
    {
      mkcontainer {taglist, layout = wibox.layout.fixed.horizontal},
      halign = "center",
      widget = wibox.widget.margin,
      layout = wibox.container.place
    },
    layout = wibox.layout.stack
  }
end)
