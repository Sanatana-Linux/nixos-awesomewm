--  _______ __                              __
-- |    ___|  |.-----.--------.-----.-----.|  |_.-----.
-- |    ___|  ||  -__|        |  -__|     ||   _|__ --|
-- |_______|__||_____|__|__|__|_____|__|__||____|_____|
-- ------------------------------------------------- --
local elements = {}

elements.create = function(SSID, BSSID, connectStatus, signal, secure, speed)
  local box = {}

  local signalIcon =
    wibox.widget {
    layout = wibox.layout.align.vertical,
    expand = 'none',
    nil,
    {
      id = 'icon',
      image = icons.wifi_off,
      resize = true,
      widget = wibox.widget.imagebox
    },
    nil
  }

  local wifiIcon =
    wibox.widget {
    {
      {
        signalIcon,
        margins = dpi(7),
        widget = wibox.container.margin
      },
      shape = gears.shape.rect,
      bg = beautiful.bg_button,
      widget = wibox.container.background
    },
    forced_width = dpi(48),
    forced_height = dpi(48),
    widget = clickable_container
  }
  wifiIcon:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        nil,
        function()
          awful.spawn.easy_async_with_shell(
            "nmcli connection show '" .. SSID .. "' | grep 'connection.autoconnect:' | awk '{print $2}'",
            function(stdout)
              local knownStatus = stdout:gsub('\n', '')
              if knownStatus == 'yes' then
                awful.spawn.with_shell(
                  'nmcli device wifi connect ' ..
                    BSSID ..
                      " && notify-send 'Connected to internet' '" ..
                        SSID .. "' || notify-send 'Unable to connect' '" .. SSID .. "'"
                )
              else
                if secure == 'no' then
                  awful.spawn.with_shell(
                    'nmcli device wifi connect ' ..
                      BSSID ..
                        " && notify-send 'Connected to internet' '" ..
                          SSID .. "' || notify-send 'Unable to connect' '" .. SSID .. "'"
                  )
                else
                  awful.spawn.with_shell(
                    'nmcli device wifi connect ' ..
                      BSSID ..
                        " password $(rofi -dmenu -p '" ..
                          SSID ..
                            "' -theme ~/.config/awesome/configuration/rofi/centered.rasi -password)" ..
                              " && notify-send 'Connected to internet' '" ..
                                SSID .. "' || notify-send 'Unable to connect' '" .. SSID .. "'"
                  )
                end
              end
            end
          )
        end
      )
    )
  )
  local content =
    wibox.widget {
    {
      {
        nil,
        {
          text = SSID,
          font = beautiful.font .. ' Bold 14',
          widget = wibox.widget.textbox
        },
        -- {
        --   text = BSSID,
        --   font = beautiful.font .. " Bold 10",
        --   widget = wibox.widget.textbox
        -- },
        layout = wibox.layout.align.vertical
      },
      margins = dpi(10),
      widget = wibox.container.margin
    },
    shape = beautiful.client_shape_rounded_small,
    bg = beautiful.bg_normal,
    widget = wibox.container.background
  }

  local icon_table = {
    icons.wifi_0,
    icons.wifi_1,
    icons.wifi_2,
    icons.wifi_3
  }

  signalIcon.icon:set_image(icon_table[math.ceil(tonumber(signal) / 25)])

  if connectStatus == 'yes' then
    awesome.emit_signal('network::status:updateIcon', icon_table[math.ceil(tonumber(signal) / 25)])
  else
    awesome.emit_signal('network::status:updateIcon', nil)
  end

  box =
    wibox.widget {
    {
      wifiIcon,
      content,
      nil,
      layout = wibox.layout.align.horizontal
    },
    shape = beautiful.client_shape_rounded_small,
    fg = colors.white,
    widget = wibox.container.background,
    bg = beautiful.bg_menu
  }

  return box
end

return elements
