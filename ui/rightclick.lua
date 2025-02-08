local awful = require("awful")
local menu = require("mods.menu")
local hotkeys_popup = require("awful.hotkeys_popup")
local focused = awful.screen.focused()

local function quickopen()
  return menu({
    menu.button({
      icon = { icon = "󰍉", font = "Font Awesome Pro 6 " },
      text = "Application Launcher",
      on_press = function()
        awesome.emit_signal("toggle::launcher")
        awesome.emit_signal("close::menu")
      end,
    }),
    menu.button({
      icon = { icon = "󱃸", font = "Font Awesome Pro 6 " },
      text = "Terminal",
      on_press = function()
        awful.spawn("kitty", false)
      end,
    }),
    menu.button({
      icon = { icon = "󰈹", font = "Font Awesome Pro 6 " },
      text = "Firefox",
      on_press = function()
        awful.spawn("firefox", false)
        awesome.emit_signal("close::menu")
      end,
    }),
    menu.button({
      icon = { icon = "󰉋", font = "Font Awesome Pro 6 " },
      text = "File Manager",
      on_press = function()
        awful.spawn("kitty -e  joshuto", false)
        awesome.emit_signal("close::menu")
      end,
    }),
    menu.button({
      icon = { icon = "󱇨", font = "Font Awesome Pro 6 " },
      text = "Neovim",
      on_press = function()
        awful.spawn("kitty -e nvim", false)
        awesome.emit_signal("close::menu")
      end,
    }),
  })end

local function awesome_menu()
  return menu({
    menu.button({
      icon = { icon = "", font = "Font Awesome Pro 6 " },
      text = "Hotkeys Popup",
      on_press = function()
        hotkeys_popup.show_help(nil, awful.screen.focused())
        awesome.emit_signal("close::menu")
      end,
    }),
    menu.button({
      icon = { icon = "", font = "Font Awesome Pro 6 " },
      text = "AwesomeWM Documentation",
      on_press = function()
        awful.spawn.with_shell("firefox https://awesomewm.org/apidoc/documentation/07-my-first-awesome.md.html#")
        awesome.emit_signal("close::menu")
      end,
    }),
    menu.button({
      icon = { icon = "󰣕", font = "Font Awesome Pro 6 " },
      text = "Edit tConfiguration",
      on_press = function()
        awful.spawn.with_shell("cd ~/.config/awesome &&  kitty -e nvim" .. " " .. awesome.conffile)
        awesome.emit_signal("close::menu")
      end,
    }),
    menu.button({
      icon = { icon = "󰦛", font = "Font Awesome Pro 6 " },
      text = "Restart",
      on_press = function()
        awesome.emit_signal("close::menu")
        awesome.restart()
      end,
    }),
    menu.button({
      icon = { icon = "󰈆", font = "Font Awesome Pro 6" },
      text = "Quit",
      on_press = function()
        awesome.quit()
        awesome.emit_signal("close::menu")
      end,
    }),
  })
end


local function widget()
  return menu({
menu.sub_menu_button({
      icon = { icon = "", font = "Font Awesome Pro 6 " },
      text = "Applications",
      sub_menu = quickopen(),
    }),

    menu.separator(),
    menu.sub_menu_button({
      icon = { icon = "󰖟", font = "Font Awesome Pro 6 " },
      text = "AwesomeWM",
      sub_menu = awesome_menu(),
    }),
  })
end


local themenu = widget()


awesome.connect_signal("close::menu", function()
  themenu:hide(true)
end)
awesome.connect_signal("toggle::menu", function()
  themenu:toggle()
end)

return { desktop = themenu }
