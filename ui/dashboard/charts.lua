local wibox = require "wibox"
local beautiful = require "beautiful"

local dpi = beautiful.xresources.apply_dpi

-- enable signals
require "signal.cpu"
require "signal.ram"
require "signal.disk"
require "signal.temperature"

-- helpers
local function mkcard(label, widget)
  return wibox.widget {
    {
      {
        {
          {
            markup = utilities.get_colorized_markup(label, beautiful.grey),
            widget = wibox.widget.textbox,
            font = beautiful.title_font
          },
          widget = wibox.container.margin,
          left = dpi(6),
          top = dpi(6)
        },
        {
          widget,
          top = dpi(15),
          bottom = dpi(15),
          left = dpi(51),
          right = dpi(51),
          widget = wibox.container.margin
        },
        nil,
        layout = wibox.layout.align.vertical
      },
      margins = dpi(3),
      widget = wibox.container.margin
    },
    shape = utilities.mkroundedrect(),
    bg = beautiful.bg_contrast,
    border_color = beautiful.grey,
    border_width = 0.75,
    widget = wibox.container.background
  }
end

local function base_chart(icon)
  return wibox.widget {
    {
      {
        {
          {
            text = icon,
            font = beautiful.nerd_font .. " 48",
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox
          },
          direction = "south",
          widget = wibox.container.rotate
        },
        top = dpi(0),
        bottom = dpi(0),
        widget = wibox.container.margin
      },
      id = "chart",
      value = 0,
      max_value = 1,
      min_value = 0,
      forced_height = dpi(124),
      forced_width = dpi(124),
      widget = wibox.container.arcchart,
      color = beautiful.chart_arc,
      border_width = dpi(0),
      thickness = dpi(12),
      bg = beautiful.dimblack
    },
    direction = "south",
    widget = wibox.container.rotate,
    set_chart_value = function(self, value)
      self:get_children_by_id("chart")[1].value = value
    end
  }
end

-- initialize charts
local cpu = base_chart("")
local mem = base_chart("")
local disk = base_chart("")
local temp = base_chart("")

-- give charts values
awesome.connect_signal("cpu::percent", function(percent)
  -- cpu chart could break sometimes, idk why, but throws some errors
  -- sometimes, so, i'll handle errors lol.
  local function get_percent()
    return percent / 100
  end

  if pcall(get_percent) then
    cpu.chart_value = get_percent()
  end
end)

awesome.connect_signal("ram::used", function(used)
  mem.chart_value = used / 100
end)

awesome.connect_signal("disk::usage", function(used)
  disk.chart_value = used / 100
end)

awesome.connect_signal("temperature::value", function(temperature)
  temp.chart_value = temperature / 100
end)

-- container
local charts_container = wibox.widget {
  {
    mkcard("CPU", cpu),
    mkcard("RAM", mem),
    spacing = dpi(15),
    layout = wibox.layout.flex.horizontal
  },
  {
    mkcard("Disk", disk),
    mkcard("Temp", temp),
    spacing = dpi(15),
    layout = wibox.layout.flex.horizontal
  },
  spacing = dpi(15),
  layout = wibox.layout.flex.vertical
}

return charts_container
