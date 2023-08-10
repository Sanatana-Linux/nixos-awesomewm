local wibox = require("wibox")
local beautiful = require("beautiful")

local dpi = beautiful.xresources.apply_dpi

-- enable signals
require("signal.status.cpu")
require("signal.status.ram")
require("signal.status.temperature")

-- helpers
local function mkcard(label, widget)
  return wibox.widget({
    {
      {

        widget,
        top = dpi(8),
        bottom = dpi(8),
        left = dpi(8),
        right = dpi(8),
        widget = wibox.container.margin,
      },
      margins = dpi(5),
      widget = wibox.container.margin,
    },
    shape = utilities.widgets.mkroundedrect(),
    bg = beautiful.bg_contrast .. "00",
    -- border_color = beautiful.grey,
    -- border_width = dpi(0.75),
    widget = wibox.container.background,
  })
end

local function base_chart(icon)
  return wibox.widget({
    {
      {
        {
          {
            image = icon,
            align = "center",
            valign = "center",
            widget = wibox.widget.imagebox,
          },
          direction = "south",
          widget = wibox.container.rotate,
        },
        margins = dpi(2),
        widget = wibox.container.margin,
      },
      id = "chart",
      value = 0,
      max_value = 1,
      min_value = 0,
      forced_height = dpi(48),
      forced_width = dpi(48),
      widget = wibox.container.arcchart,
      color = beautiful.chart_arc,
      border_width = dpi(0),
      thickness = dpi(3),
      bg = beautiful.dark_grey .. "cc",
    },
    direction = "south",
    widget = wibox.container.rotate,
    set_chart_value = function(self, value)
      self:get_children_by_id("chart")[1].value = value
    end,
  })
end

-- initialize charts
local cpu = base_chart(icons.cpu)
local mem = base_chart(icons.ram)
local temp = base_chart(icons.temp)

-- give charts values
awesome.connect_signal("cpu::percent", function(percent)
  cpu.chart_value = percent / 100
end)

awesome.connect_signal("ram::used", function(used)
  mem.chart_value = used / 100
end)

awesome.connect_signal("temperature::value", function(temperature)
  temp.chart_value = temperature / 100
end)

-- container
local charts_container = wibox.widget({

  mkcard("CPU", cpu),
  mkcard("RAM", mem),
  mkcard("Temp", temp),

  spacing = dpi(8),
  layout = wibox.layout.fixed.vertical,
})

return charts_container
