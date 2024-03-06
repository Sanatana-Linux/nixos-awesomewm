local beautiful = require("beautiful")

local dpi = beautiful.xresources.apply_dpi
-- -------------------------------------------------------------------------- --
-- Widgets

awful.screen.connect_for_each_screen(function(s)
  local launcherdisplay = wibox({
    width = dpi(440),
    shape = utilities.graphics.mkroundedrect(),
    height = dpi(720),
    bg = beautiful.bg_normal .. "66",
    border_color = beautiful.grey .. "cc",
    border_width = dpi(2),
    ontop = true,
    type = "dock",
    visible = false,
  })
  -- -------------------------------------------------------------------------- --
  local slide = effects.instance.timed({
    pos = s.geometry.height,
    rate = 60,
    intro = 0.14,
    duration = 0.33,
    subscribed = function(pos)
      launcherdisplay.y = s.geometry.y + pos
    end,
  })
  -- -------------------------------------------------------------------------- --
  local slide_end = gears.timer({
    single_shot = true,
    timeout = 0.43,
    callback = function()
      launcherdisplay.visible = false
      awful.keyboard.emulate_key_combination({}, "Escape")
    end,
  })
  -- -------------------------------------------------------------------------- --
  local prompt = wibox.widget({
    {
      {
        {

          id = "txt",
          font = beautiful.title_font .. " 22",
          widget = wibox.widget.textbox,
        },
        widget = wibox.container.margin,
        left = dpi(20),
        right = dpi(20),
      },

      widget = wibox.container.background,
      bg = beautiful.bg_contrast .. "22",
      border_width = dpi(2),
      border_color = beautiful.grey .. "cc",
      forced_height = dpi(50),
      shape = utilities.graphics.mkroundedrect(),
    },
    widget = wibox.container.margin,
    layout = wibox.layout.fixed.vertical,
  })

  local entries = wibox.widget({
    homogeneous = true,
    expand = false,
    forced_num_cols = 1,
    spacing = 4,
    layout = wibox.layout.grid.vertical,
  })
  -- -------------------------------------------------------------------------- --

  -- -------------------------------------------------------------------------- --
  launcherdisplay:setup({
    {
      widget = wibox.container.background,
      border_color = beautiful.grey .. "99",
      border_width = dpi(2),
      {
        widget = wibox.container.margin,
        margins = dpi(5),
        spacing = dpi(8),
        layout = wibox.layout.align.vertical,

        {
          {
            widget = wibox.widget.imagebox,
            image = icons.awesome_alt,
            forced_height = dpi(75),
            forced_width = dpi(75),
          },
          valign = "top",
          widget = wibox.container.margin,
          margins = dpi(5),
        },
        require("ui.launcher.charts"),
        {
          valign = "bottom",
          widget = wibox.container.margin,
          margins = dpi(20),
          {
            widget = wibox.container.background,
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(10),
            require("ui.launcher.powermenu_containers.lock"),
            require("ui.launcher.powermenu_containers.logout"),
            require("ui.launcher.powermenu_containers.restart"),
            require("ui.launcher.powermenu_containers.shutdown"),
          },
        },
      },
    },
    {
      {
        entries,
        left = dpi(10),
        right = dpi(10),
        bottom = dpi(5),
        top = dpi(5),
        forced_height = dpi(650),
        widget = wibox.container.margin,
      },
      {
        {
          prompt,
          widget = wibox.container.margin,
          margins = dpi(10),
          shape = utilities.graphics.mkroundedrect(),
        },

        widget = wibox.container.background,
      },
      spacing = dpi(10),
      layout = wibox.layout.align.vertical,
    },

    widget = wibox.container.background,
    layout = wibox.layout.fixed.horizontal,
  })
  -- -------------------------------------------------------------------------- --
  -- Functions

  local function next(entries)
    if index_entry ~= #filtered then
      index_entry = index_entry + 1
      if index_entry > index_start + 9 then
        index_start = index_start + 1
      end
    end
  end
  -- -------------------------------------------------------------------------- --
  local function back(entries)
    if index_entry ~= 1 then
      index_entry = index_entry - 1
      if index_entry < index_start then
        index_start = index_start - 1
      end
    end
  end
  -- -------------------------------------------------------------------------- --
  local function gen()
    local entries = {}
    for _, entry in ipairs(Gio.AppInfo.get_all()) do
      if entry:should_show() then
        local name = entry
          :get_name()
          :gsub("&", "&amp;")
          :gsub("<", "&lt;")
          :gsub("'", "&#39;")
        local icon = entry:get_icon()
        local path
        if icon then
          path = icon:to_string()
          if not path:find("/") then
            local icon_info = iconTheme:lookup_icon(path, dpi(48), 0)
            local p = icon_info and icon_info:get_filename()
            path = p
          end
        end
        table.insert(
          entries,
          { name = name, appinfo = entry, icon = path or "" }
        )
      end
    end
    return entries
  end
  -- -------------------------------------------------------------------------- --
  local function filter(cmd)
    filtered = {}
    regfiltered = {}
    -- -------------------------------------------------------------------------- --
    -- Filter entries

    for _, entry in ipairs(unfiltered) do
      if entry.name:lower():sub(1, cmd:len()) == cmd:lower() then
        table.insert(filtered, entry)
      elseif entry.name:lower():match(cmd:lower()) then
        table.insert(regfiltered, entry)
      end
    end
    -- -------------------------------------------------------------------------- --
    -- Sort entries

    table.sort(filtered, function(a, b)
      return a.name:lower() < b.name:lower()
    end)
    table.sort(regfiltered, function(a, b)
      return a.name:lower() < b.name:lower()
    end)
    -- -------------------------------------------------------------------------- --
    -- Merge entries

    for i = 1, #regfiltered do
      filtered[#filtered + 1] = regfiltered[i]
    end

    -- Clear entries

    entries:reset()
    -- -------------------------------------------------------------------------- --
    -- Add filtered entries

    for i, entry in ipairs(filtered) do
      local widget = wibox.widget({
        {
          {
            {
              image = entry.icon,
              clip_shape = utilities.graphics.mkroundedrect(),
              forced_height = dpi(48),
              forced_width = dpi(48),
              valign = "center",
              widget = wibox.widget.imagebox,
            },
            {
              markup = entry.name,
              font = beautiful.title_font .. " 14",
              widget = wibox.widget.textbox,
            },
            spacing = dpi(20),
            layout = wibox.layout.fixed.horizontal,
          },
          top = dpi(10),
          bottom = dpi(10),
          left = dpi(5),
          right = dpi(5),
          widget = wibox.container.margin,
        },
        forced_width = dpi(360),
        forced_height = dpi(60),
        border_color = beautiful.grey .. "88",
        shape = utilities.graphics.mkroundedrect(),
        border_width = dpi(2),
        widget = wibox.container.background,
        bg = beautiful.bg_contrast .. "22",
      })

      if index_start <= i and i <= index_start + 9 then
        entries:add(widget)
      end

      if i == index_entry then
        widget.border_color = beautiful.fg_normal .. "88"
        widget.bg = beautiful.black .. "77"
      end
    end
    -- -------------------------------------------------------------------------- --
    -- Fix position

    if index_entry > #filtered then
      index_entry, index_start = 1, 1
    elseif index_entry < 1 then
      index_entry = 1
    end

    collectgarbage("collect")
  end

  local function open()
    -- -------------------------------------------------------------------------- --
    -- Reset index and page

    index_start, index_entry = 1, 1

    -- Get entries

    unfiltered = gen()
    filter("")
    -- -------------------------------------------------------------------------- --
    -- Prompt

    awful.prompt.run({
      prompt = "Launch:   ",
      textbox = prompt:get_children_by_id("txt")[1],
      done_callback = function()
        slide_end:again()
        slide.target = (0 - launcherdisplay.height)
        awful.keyboard.emulate_key_combination({}, "Escape")
      end,
      changed_callback = function(cmd)
        filter(cmd)
      end,
      exe_callback = function(cmd)
        local entry = filtered[index_entry]
        if entry then
          entry.appinfo:launch()
        else
          awful.spawn.with_shell(cmd)
        end
      end,
      keypressed_callback = function(_, key)
        if key == "Down" then
          next(entries)
        elseif key == "Up" then
          back(entries)
        end
      end,
    })
  end

  local function launcher_hide()
    if launcherdisplay.visible then
      slide_end:again()
      slide.target = (0 - launcherdisplay.height)
      awful.keygrabber.stop()
    end
  end
  -- -------------------------------------------------------------------------- --
  awesome.connect_signal("toggle::launcher", function()
    open()
    local click = awful.button({}, 1, function(c)
      launcher_hide()
    end)

    if launcherdisplay.visible then
      slide_end:again()
      slide.target = (0 - launcherdisplay.height)
      client.connect_signal("mouse::press", function()
        launcher_hide()
      end)
      awful.mouse.remove_global_mousebinding(click)
      awful.keyboard.emulate_key_combination({}, "Escape")
    elseif not launcherdisplay.visible then
      slide.target = (
        awful.screen.focused().geometry.height / 2
        - launcherdisplay.height / 2
      )
      client.connect_signal("button::press", function()
        launcher_hide()
      end)
      launcherdisplay.visible = true
    end
    awful.placement.bottom_left(launcherdisplay, {
      honor_workarea = true,
      margins = dpi(6),
      parent = awful.screen.focused(),
    })
  end)
end)
