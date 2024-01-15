-- original author: Aire-One (https://github.com/Aire-One)
local upower = require("lgi").require("UPowerGlib")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local wbase = require("wibox.widget.base")

local setmetatable = setmetatable
local screen = screen

-- Declare namespace
local battery_widget = {}
local mt = {}

-- Helper to get the path of all connected power devices.
function battery_widget.list_devices()
  local ret = {}
  local devices = upower.Client():get_devices()

  if not devices then
    awesome.emit_signal("signal::battery:error")
    return ret
  end

  for _, d in ipairs(devices) do
    table.insert(ret, d:get_object_path())
  end

  return ret
end

-- Helper function to get a device instance from its path.
function battery_widget.get_device(path)
  local devices = upower.Client():get_devices()

  if not devices then
    awesome.emit_signal("signal::battery:error")
    return nil
  end

  for _, d in ipairs(devices) do
    if d:get_object_path() == path then
      return d
    end
  end

  return nil
end

-- Helper function to easily get the default BAT0 device path.
function battery_widget.get_BAT0_device_path()
  return "/org/freedesktop/UPower/devices/battery_BAT0"
end

-- Helper function to convert seconds into a human readable clock string.
function battery_widget.to_clock(seconds)
  if seconds <= 0 then
    return "00:00"
  else
    local hours = string.format("%02.f", math.floor(seconds / 3600))
    local mins = string.format("%02.f", math.floor(seconds / 60 % 60))
    return string.format("%s:%s", hours, mins)
  end
end

-- Gives the default widget to use if the user didn't specify one.
local function default_template()
  return wbase.empty_widget()
end

-- Battery widget constructor.
function battery_widget.new(args)
  args = gtable.crush({
    widget_template = default_template(),
    create_callback = nil,
    device_path = "",
    use_display_device = false,
  }, args or {})
  args.screen = screen[args.screen or 1]

  local widget = wbase.make_widget_from_value(args.widget_template)

  widget.device = args.use_display_device
      and upower.Client():get_display_device()
    or battery_widget.get_device(args.device_path)

  if type(args.create_callback) == "function" then
    args.create_callback(widget, widget.device)
  end

  -- Attach signals
  widget.device.on_notify = function(d)
    widget:emit_signal("upower::update", d)
  end

  -- Call an update cycle if the user asked to instantly update the widget.
  if args.instant_update then
    gtimer.delayed_call(
      widget.emit_signal,
      widget,
      "upower::update",
      widget.device
    )
  end

  return widget
end

-- Complex return statement
function mt.__call(self, ...)
  return battery_widget.new(...)
end

return setmetatable(battery_widget, mt)
