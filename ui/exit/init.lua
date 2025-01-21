local wibox     = require("wibox")
local helpers   = require("helpers")
local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local dpi       = require("beautiful.xresources").apply_dpi

awful.screen.connect_for_each_screen(function(s)
  local exit = wibox({
    screen = s,
    width = dpi(2560),
    height = dpi(1600),
    bg = beautiful.bg .. "00",
    ontop = true,
    visible = false,
  })

  local back = wibox.widget {
    id = "bg",
    image = beautiful.wallpaper,
    widget = wibox.widget.imagebox,
    forced_height = dpi(1600),
    horizontal_fit_policy = "fit",
    vertical_fit_policy = "fit",
    forced_width = dpi(2560),
  }

  local overlay = wibox.widget {
    widget = wibox.container.background,
    forced_height = 1080,
    forced_width = 1920,
    bg = beautiful.bg .. "d1"
  }
  local makeImage = function()
    local cmd = 'convert ' ..
        beautiful.wallpaper .. ' -filter Gaussian -blur 0x6 ~/.cache/awesome/exit.jpg'
    awful.spawn.easy_async_with_shell(cmd, function()
      local blurwall = gears.filesystem.get_cache_dir() .. "exit.jpg"
      back.image = blurwall
    end)
  end

  makeImage()

  local createButton = function(icon, name, cmd)
    local widget = wibox.widget {
      {
        {
          {
            id     = "icon",
            markup = helpers.colorize_text(icon, beautiful.fg3), -- Initially fg3
            font   = beautiful.icon .. " 40",
            align  = "center",
            widget = wibox.widget.textbox,
          },
          widget = wibox.container.margin,
          margins = 40,
        },
        shape = helpers.rrect(15),
        widget = wibox.container.background,
        bg = beautiful.bg,
        id = "bg",
        shape_border_color = beautiful.fg3, -- Border color also fg3
        shape_border_width = 2,
      },
      buttons = {
        awful.button({}, 1, function()
          awesome.emit_signal("toggle::exit")
          awful.spawn.with_shell(cmd)
        end)
      },
      spacing = 15,
      layout = wibox.layout.fixed.vertical,
    }

    -- Mouse hover effects
    widget:connect_signal("mouse::enter", function()
      helpers.gc(widget, "bg").bg = beautiful.mbg
      helpers.gc(widget, "icon").markup = helpers.colorize_text(icon, beautiful.fg) -- Change to fg on hover
      widget:get_children_by_id("bg")[1].shape_border_color = beautiful.fg          -- Change border to fg on hover
    end)
    widget:connect_signal("mouse::leave", function()
      helpers.gc(widget, "bg").bg = beautiful.bg
      helpers.gc(widget, "icon").markup = helpers.colorize_text(icon, beautiful.fg3) -- Revert to fg3 on leave
      widget:get_children_by_id("bg")[1].shape_border_color = beautiful.fg3          -- Revert border to fg3 on leave
    end)

    return widget
  end

  local buttons = wibox.widget {
    {
      createButton("󰐥", "Power", "poweroff"),
      createButton("󰦛", "Reboot", "reboot"),
      createButton("󰌾", "Lock", "screenlocked"),
      createButton("󰖔", "Sleep", "systemctl suspend"),
      createButton("󰈆", "Log Out", "loginctl kill-user $USER"),
      layout = wibox.layout.fixed.horizontal,
      spacing = 20,
    },
    widget = wibox.container.place,
    halign = "center",
    valign = "center"
  }

  exit:setup {
    back,
    overlay,
    buttons,
    widget = wibox.layout.stack
  }
  awful.placement.centered(exit)
  awesome.connect_signal("toggle::exit", function()
    exit.visible = not exit.visible
    if exit.visible then
      -- Grab keyboard when the exit screen is visible
      awful.keygrabber.run(function(_, key, event)
        if event == "press" and (key == "Escape" or key == "q") then
          awesome.emit_signal("toggle::exit") -- Toggle off the exit screen
        end
        return true
      end)
    else
      -- Stop grabbing keyboard when the exit screen is hidden
      awful.keygrabber.stop()
    end
  end)
end)
