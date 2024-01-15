-- battery notifications
--
local gfs = require("gears.filesystem")
local naughty = require("naughty")
require("signal.status.battery")

local display_high = true
local display_low = true
local display_charge = true

local function showNotification(title, text, image)
  naughty.notification({
    title = title,
    text = text,
    image = image,
  })
end

awesome.connect_signal("signal::battery", function(percentage, state)
  local value = percentage

  -- Only display message if it's not charging and low
  if value < 16 and display_low and state == 2 then
    showNotification(
      "Battery Low",
      "Running low at " .. value .. "%",
      gfs.get_configuration_dir() .. "themes/icons/svg/battery-alert-red.svg"
    )
    display_low = false
  end

  -- Only display message once if it's fully charged and high
  if display_high and state == 4 and value > 99 then
    showNotification(
      "Battery Status",
      "Fully charged!",
      gfs.get_configuration_dir()
        .. "themes/icons/svg/battery-fully-charged.svg"
    )
    display_high = false
  end

  -- Only display once if charging
  if display_charge and state == 1 then
    showNotification(
      "Battery Status",
      "Charging",
      gfs.get_configuration_dir() .. "icons/svg/battery-fully-charged.svg"
    )
    display_charge = false
  end

  -- Reset display flags if battery percentage is within the normal range
  if value < 88 and value > 18 then
    display_low = true
    display_high = true
  end

  -- Reset display flag if battery is no longer charging
  if state == 2 then
    display_charge = true
  end
end)
