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
 
        
          widget,
          top = dpi(14),
          bottom = dpi(14),
          left = dpi(14),
          right = dpi(14),
          widget = wibox.container.margin
        
      },
      margins = dpi(5),
      widget = wibox.container.margin
    },
    shape = utilities.mkroundedrect(),
    bg = beautiful.bg_contrast,
    border_color = beautiful.grey,
    border_width = 0.75,
    widget = wibox.container.background
  }
end
local wibox = require "wibox"
local beautiful = require "beautiful"

local dpi = beautiful.xresources.apply_dpi


-- helpers
local function mkcard(label, widget)
  return wibox.widget {
    {
      {
 
        
          widget,
          top = dpi(14),
          bottom = dpi(14),
          left = dpi(14),
          right = dpi(14),
          widget = wibox.container.margin
        
      },
      margins = dpi(5),
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
            image = icon,
            align = "center",
            valign = "center",
            widget = wibox.widget.imagebox
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
      forced_height = dpi(72),
      forced_width = dpi(72),
      widget = wibox.container.arcchart,
      color = beautiful.chart_arc,
      border_width = dpi(0),
      thickness = dpi(8),
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
local cpu = base_chart(icons.cpu)
local mem = base_chart(icons.ram)
local disk = base_chart(icons.disk)
local temp = base_chart(icons.temp)

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
    spacing = dpi(8),
    layout = wibox.layout.fixed.horizontal
  },
  {
    mkcard("Disk", disk),
    mkcard("Temp", temp),
    spacing = dpi(8),
    layout = wibox.layout.fixed.horizontal
  },
  spacing = dpi(8),
  layout = wibox.layout.fixed.vertical
}

return charts_container
