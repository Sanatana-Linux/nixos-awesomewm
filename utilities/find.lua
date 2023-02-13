local awful = require("awful")
local gears = require("gears")

local client = client


return function (rule)
  local function matcher(c) return awful.rules.match(c, rule) end
  local clients = client.get()
  local findex = gears.table.hasitem(clients, client.focus) or 1
  local start = gears.math.cycle(#clients, findex + 1)

  local matches = {}
  for c in awful.client.iterate(matcher, start) do
    matches[#matches + 1] = c
  end

  return matches
end
