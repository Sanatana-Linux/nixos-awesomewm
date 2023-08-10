local function cross_enter(self, _)
  self:get_children_by_id("remove")[1]
      :set_image(
        gears.color.recolor_image(icons.checkbox_marked, beautiful.blue)
      )
end
local function cross_leave(self, _)
  self:get_children_by_id("remove")[1]:set_image(
    gears.color.recolor_image(icons.checkbox_marked, beautiful.fg_normal)
  )
end
-- -------------------------------------------------------------------------- --
local main_widget

local entry_template = {
  widget = wibox.container.background,
  bg = beautiful.bg_contrast .. "88",
  shape = utilities.widgets.mkroundedrect(),
  {
    widget = wibox.container.constraint,
    width = dpi(400),
    strategy = "max",
    {
      layout = wibox.layout.fixed.vertical,
      {
        widget = wibox.container.background,
        bg = beautiful.bg_normal .. "88",
        fg = beautiful.fg_focus,
        forced_height = beautiful.get_font_height(
          beautiful.font_name .. " 11"
        ),
        {
          widget = wibox.container.place,
          fill_horizontal = true,
          halign = "right",
          valign = "bottom",
          {
            id = "remove",
            widget = wibox.widget.imagebox,
            forced_height = beautiful.get_font_height(
              beautiful.font_name .. " 11"
            ) / 2,
            forced_width = beautiful.get_font_height(
              beautiful.font_name .. " 11"
            ),
          },
        },
      },
      {
        widget = wibox.container.margin,
        margins = { left = dpi(5), right = dpi(5), bottom = dpi(5) },
        {
          layout = wibox.layout.fixed.horizontal,
          spacing = dpi(5),
          {
            widget = wibox.container.place,
            valign = "center",
            {
              id = "icon",
              widget = wibox.widget.imagebox,
              resize = true,
              forced_width = 0,
              forced_height = 0,
              clip_shape = utilities.widgets.mkroundedrect(),
            },
          },
          {
            widget = wibox.container.place,
            valign = "top",
            {
              layout = wibox.layout.fixed.vertical,
              spacing = dpi(5),
              {
                id = "title",
                widget = wibox.widget.textbox,
                font = beautiful.title_font .. " 14",
              },
              {
                id = "text",
                widget = wibox.widget.textbox,
                font = beautiful.font .. " 10",
              },
            },
          },
        },
      },
    },
  },
}

main_widget = wibox.widget({
  layout = wibox.layout.fixed.vertical,
  spacing = dpi(5),
})
-- -------------------------------------------------------------------------- --
-- this is basically just a simple header + layout to hold notifs
local app_revealer_template = {
  widget = wibox.container.background,
  shape = utilities.widgets.mkroundedrect(),
  border_color = beautiful.grey .. "cc",
  border_width = dpi(1.25),
  {
    layout = wibox.layout.fixed.vertical,
    {
      id = "revealer_top_bg",
      widget = wibox.container.background,
      forced_height = beautiful.get_font_height(
        beautiful.font_name .. " 11"
      ) + dpi(10),
      bg = beautiful.bg_contrast .. "88",
      {
        widget = wibox.container.margin,
        margins = dpi(5),
        {
          layout = wibox.layout.align.horizontal,
          expand = "inside",
          {
            id = "reveal_button",
            widget = wibox.widget.imagebox,
            image = gears.color.recolor_image(
              icons.arrow_down,
              beautiful.fg_normal
            ),
          },
          {
            widget = wibox.container.place,
            halign = "center",
            fill_horizontal = true,
            {
              id = "appname",
              widget = wibox.widget.textbox,
              font = beautiful.font .. " 10",
            },
          },
          {
            id = "clear_button",
            widget = wibox.widget.imagebox,
            image = gears.color.recolor_image(
              icons.clear_all,
              beautiful.fg_normal
            ),
          },
        },
      },
    },
    {
      widget = wibox.container.background,
      border_color = beautiful.grey,
      border_width = dpi(1.25),
      bg = beautiful.bg_contrast .. "88",
      {
        id = "notifs_margin",
        widget = wibox.container.margin,
        margins = { left = dpi(5), right = dpi(5) },
        {
          id = "notifs",
          layout = wibox.layout.fixed.vertical,
          spacing = dpi(3),
        },
      },
    },
  },
}
-- -------------------------------------------------------------------------- --
--
local function add_notif_widget(n)
  local w = wibox.widget(entry_template)
  w.app = n.app_name or "undefined"

  local drawer
  -- -------------------------------------------------------------------------- --
  -- check if the app already has a drawer
  --
  for _, d in ipairs(main_widget:get_children()) do
    if d.app == w.app then
      drawer = d
      -- -------------------------------------------------------------------------- --
      -- move currently used drawer to the top of the drawer stack
      --
      main_widget:remove_widgets(drawer)
      main_widget:insert(1, drawer)
      break
    end
  end
  -- -------------------------------------------------------------------------- --
  -- if there are no recent notifications from the app we create a new drawer for them and add button magic
  --
  if not drawer then
    drawer = wibox.widget(app_revealer_template)
    drawer:get_children_by_id("appname")[1].text = w.app
    drawer.app = w.app
    drawer.collapsed = true
    drawer.attached_notifs = {}
    drawer:get_children_by_id("reveal_button")[1]:add_button(awful.button({
      modifiers = {},
      button = 1,
      on_press = function()
        if drawer.collapsed then
          drawer
              :get_children_by_id("notifs")[1]
              :set_children(drawer.attached_notifs)
          drawer:get_children_by_id("notifs_margin")[1].margins =
              dpi(5)
          drawer:get_children_by_id("reveal_button")[1]:set_image(
            gears.color.recolor_image(
              icons.arrow_up,
              beautiful.fg_normal
            )
          )
        else
          drawer:get_children_by_id("notifs")[1]:reset()
          drawer:get_children_by_id("notifs_margin")[1].margins = 0
          drawer:get_children_by_id("reveal_button")[1]:set_image(
            gears.color.recolor_image(
              icons.arrow_down,
              beautiful.fg_normal
            )
          )
        end
        drawer.collapsed = not drawer.collapsed
        collectgarbage("collect")
      end,
    }))
    utilities.visual.pointer_on_focus(
      drawer:get_children_by_id("reveal_button")[1]
    )
    drawer:get_children_by_id("clear_button")[1]:add_button(awful.button({
      modifiers = {},
      button = 1,
      on_press = function()
        main_widget:remove_widgets(drawer)
        drawer = nil

        collectgarbage("collect")
      end,
    }))
    utilities.visual.pointer_on_focus(
      drawer:get_children_by_id("clear_button")[1]
    )
    main_widget:insert(1, drawer)
  end
  -- -------------------------------------------------------------------------- --
  -- create notification widget and add it to its widget's drawer
  --
  w:get_children_by_id("remove")[1]:set_image(
    gears.color.recolor_image(icons.checkbox_marked, beautiful.fg_normal)
  )
  w:get_children_by_id("remove")[1]:connect_signal("mouse::enter", function()
    cross_enter(w)
  end)
  w:get_children_by_id("remove")[1]:connect_signal("mouse::leave", function()
    cross_leave(w)
  end)
  w:get_children_by_id("title")[1]:set_markup_silently(n.title)
  w:get_children_by_id("text")[1]:set_markup_silently(n.message)
  if n.icon then
    w:get_children_by_id("icon")[1]:set_image(n.icon)
    w:get_children_by_id("icon")[1].forced_height = dpi(40)
    w:get_children_by_id("icon")[1].forced_width = dpi(40)
  end
  w:get_children_by_id("remove")[1]:add_button(awful.button({
    modifiers = {},
    button = 1,
    on_press = function()
      w:get_children_by_id("remove")[1]
          :disconnect_signal("mouse::enter", cross_enter)
      w:get_children_by_id("remove")[1]
          :disconnect_signal("mouse::leave", cross_leave)
      drawer:get_children_by_id("notifs")[1]:remove_widgets(w)
      for i, e in ipairs(drawer.attached_notifs) do
        if e == w then
          table.remove(drawer.attached_notifs, i)
          break
        end
      end
      drawer:get_children_by_id("appname")[1].text = drawer.app
          .. " ("
          .. #drawer.attached_notifs
          .. ")"
      if #drawer:get_children_by_id("notifs")[1]:get_children() == 0 then
        main_widget:remove_widgets(drawer)
      end

      collectgarbage("collect")
    end,
  }))
  -- -------------------------------------------------------------------------- --
  --
  table.insert(drawer.attached_notifs, 1, w)
  drawer:get_children_by_id("appname")[1].text = drawer.app
      .. " ("
      .. #drawer.attached_notifs
      .. ")"
  if not drawer.collapsed then
    drawer:get_children_by_id("notifs")[1]:insert(1, w)
  end
end
-- -------------------------------------------------------------------------- --
local notifbox
notifbox =
    wibox.widget({ -- empty because it will be filled with the update function
      layout = wibox.layout.fixed.vertical,

      spacing = dpi(5),
      {
        widget = wibox.container.background,
        layout = modules.overflow.vertical,
        bg = beautiful.black .. "88",
        border_color = beautiful.grey,
        border_width = dpi(1.25),
        shape = utilities.widgets.mkroundedrect(),
        {
          layout = wibox.layout.align.horizontal,
          expand = "inside",
          -- -------------------------------------------------------------------------- --
          --  the nil here makes the align center the title as it treats the nil as if it is a widget
          --
          nil,
          {
            widget = wibox.container.margin,
            margins = { left = dpi(5), right = dpi(5) },
            {
              widget = wibox.container.constraint,
              height = beautiful.get_font_height(
                beautiful.font_name .. " 18"
              ) + dpi(10),
              {
                widget = wibox.container.margin,
                margins = dpi(5),
                {
                  widget = wibox.container.place,
                  halign = "center",
                  valign = "center",
                  fill_horizontal = true,
                  {
                    widget = wibox.widget.textbox,
                    text = "Notifications",
                    font = beautiful.title_font .. " 24",
                  },
                },
              },
            },
          },
          -- -------------------------------------------------------------------------- --
          -- same as above nil
          --
          nil,
        },
      },
      main_widget,
    })
-- -------------------------------------------------------------------------- --
local blacklisted_appnames = { "Spotify" }
local blacklisted_titles = { "Launching Application" }

local function check_list(n)
  for _, an in ipairs(blacklisted_appnames) do
    if an == n.app_name then
      return true
    end
  end
  for _, nt in ipairs(blacklisted_titles) do
    if nt == n.title then
      return true
    end
  end
  return false
end

naughty.connect_signal("request::display", function(n)
  local client_focused
  if client.focus then
    client_focused = string.lower(client.focus.class) ~= (n.app_name or "")
  end

  add_notif_widget(n)
end)
-- -------------------------------------------------------------------------- --
client.connect_signal("property::active", function(c)
  -- most apps report their name via class so that should be alright
  --
  if c then
    local cname = string.lower(c.class) or nil
    local drawer
    for _, entry in ipairs(main_widget:get_children()) do
      if string.lower(entry.app) == cname then
        drawer = entry
      end
    end
    main_widget:remove_widgets(drawer)
  end
end)

return notifbox
