local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local wibox = require("wibox")
local gears = require("gears")
local empty = require("ui.notify.mods.empty")
local make = require("ui.notify.mods.make")
local progs = require("ui.notify.mods.progs")
local hotkeys_popup = require("awful.hotkeys_popup").widget

awful.screen.connect_for_each_screen(function(s)
  local notify = wibox({
    shape = helpers.rrect(12),
    screen = s,
    width = 500,
    height = 1080 - 40 - 60,
    bg = beautiful.bg,
    ontop = true,
    visible = false,
  })

  local function close_notify()
    notify.visible = false
    awful.keygrabber.stop() -- Stop the keygrabber when closing the popup.
  end

  -- Keygrabber to close the notification popup
  local keygrabber = function(mod, key, event)
    if notify.visible then
      if key == "q" or key == "Escape" then
        close_notify()
        return true -- Stop propagation
      end
    end
  end

  local start_keygrabber = function()
    awful.keygrabber.run(keygrabber)
  end

  -- Add a click away handler.
  --  The `mouse` object to be in a scope that will last for
  --  the lifetime of the popup

  local function add_click_away()
    local mouse = awful.mouse.client_under_pointer()
    if mouse then
        mouse.buttons = gears.table.join(mouse.buttons, {
        awful.button({ }, 3, function ()
          if notify.visible then
            close_notify()
          end
        end)
      })
    end
  end
  add_click_away()

  local finalcontent = wibox.widget {
    layout = require('mods.overflow').vertical,
    scrollbar_enabled = false,
    spacing = dpi(10),
  }
  finalcontent:insert(1, empty)

  local remove_notifs_empty           = true

  notif_center_reset_notifs_container = function()
    finalcontent:reset(finalcontent)
    finalcontent:insert(1, empty)
    remove_notifs_empty = true
  end

  notif_center_remove_notif           = function(box)
    finalcontent:remove_widgets(box)
    if #finalcontent.children == 0 then
      finalcontent:insert(1, empty)
      remove_notifs_empty = true
    end
  end


  local clearButton = wibox.widget {
    font = beautiful.icon .. " 26",
    markup = helpers.colorize_text("󰎟", beautiful.fg),
    widget = wibox.widget.textbox,
    valign = "center",
    align = "center",
    buttons = {
      awful.button({}, 1, function()
        notif_center_reset_notifs_container()
      end)
    }
  }
  naughty.connect_signal("request::display", function(n)
    if #finalcontent.children == 1 and remove_notifs_empty then
      finalcontent:reset(finalcontent)
      remove_notifs_empty = false
    end

    local appicon = n.icon or n.app_icon
    if not appicon then
      appicon = gears.filesystem.get_configuration_dir() .. "theme/assets/awesome.svg"
    end
    finalcontent:insert(1, make(appicon, n))
  end)
  notify:setup {
    {
      {
        {
          {
            {
              markup = helpers.colorize_text("Notifications", beautiful.fg),
              halign = 'center',
              font   = beautiful.prompt_font .. " 18",
              widget = wibox.widget.textbox
            },
            nil,
            clearButton,
            widget = wibox.layout.align.horizontal,
          },
          widget = wibox.container.margin,
          margins = dpi(20),
        },
        widget = wibox.container.background,
        bg = beautiful.mbg
      },
      {
        {
          finalcontent,
          widget = wibox.container.margin,
          margins = dpi(20),
        },
        widget = wibox.container.background,
      },
      progs,
      layout = wibox.layout.align.vertical,
      spacing = dpi(20),
    },
    widget = wibox.container.margin,
    margins = 0,
  }
  awful.placement.bottom_right(notify, { honor_workarea = true, margins = dpi(20) })
  awesome.connect_signal("toggle::notify", function()
    notify.visible = not notify.visible
    if notify.visible then
      start_keygrabber() -- Start the keygrabber only when popup is visible.
    else
      awful.keygrabber.stop() -- Ensure keygrabber is stopped when popup is hidden.
    end
  end)
end)