---@diagnostic disable: undefined-global

--- This module defines a menu for the AwesomeWM window manager.
--- It provides a main menu and an AwesomeWM-specific menu.
local menu = {}

-- Define the AwesomeWM menu items
menu.awesome = {
  {
    "Edit Config",
    editor_cmd .. " " .. os.getenv("HOME") .. "/.config/awesome/rc.lua",
    icons.text_editor,
  },
  {
    "Restart",
    awesome.restart,
    icons.restart,
  },
  {
    "Close Session",
    function()
      awesome.quit()
    end,
    icons.close,
  },
}

-- Define the main menu with various application items
menu.mainmenu = awful.menu({
  items = {
    { "Terminal", terminal, icons.terminal },
    { "Explorer", filemanager, icons.files },
    { "Browser", browser, icons.web_browser },
    { "Editor", editor_cmd, icons.text_editor },
    { "AwesomeWM", menu.awesome, icons.awesome },
  },
})

-- Customize the appearance of the main menu
menu.mainmenu.wibox.shape = utilities.graphics.mkroundedrect()
menu.mainmenu.wibox:set_widget(wibox.widget({
  {
    menu.mainmenu.wibox.widget,
    widget = wibox.container.margin,
    margins = dpi(3),
  },
  font = beautiful.nerd_font .. " 12",
  border_width = dpi(1),
  border_color = beautiful.grey .. "cc",
  shape = utilities.graphics.mkroundedrect(),
  widget = wibox.container.background,
}))

-- Override the default `awful.menu.new` function to customize the appearance of menus
awful.menu.original_new = awful.menu.new

function awful.menu.new(...)
  local ret = awful.menu.original_new(...)

  ret.wibox.shape = utilities.graphics.mkroundedrect()
  ret.wibox:set_widget(wibox.widget({
    {
      ret.wibox.widget,
      widget = wibox.container.margin,
      margins = dpi(3),
    },
    widget = wibox.container.background,
    border_width = dpi(1),
    border_color = beautiful.grey .. "cc",
    shape = utilities.graphics.mkroundedrect(),
  }))
  return ret
end

-- Define mouse bindings to hide the main menu
awful.mouse.append_client_mousebinding(awful.button({}, 1, function()
  menu.mainmenu:hide()
end))

awful.mouse.append_global_mousebinding(awful.button({}, 1, function()
  menu.mainmenu:hide()
end))

awful.mouse.append_client_mousebinding(awful.button({}, 3, function()
  menu.mainmenu:hide()
end))

-- Define a mouse binding to toggle the main menu
awful.mouse.append_global_mousebinding(awful.button({}, 3, function()
  menu.mainmenu:toggle()
end))

return menu
