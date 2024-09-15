
-- NOTE: This is the opposite arrangement to horizontal, unlike Thrizen which at >3 will split the columns into 2 rows where this will just make more columns indefinitely. Again thanks to bling, with some cleanup, commenting and optimization of my own for my maintaining ease at later dates that is less likely to be needed after doing such.
--   +---------------------------------------------------------------+

-- Define the vertical layout module
local vertical = {}

-- Set the name of the layout
vertical.name = "vertical"

-- Arrange function for the vertical layout
function vertical.arrange(p)
  local area = p.workarea
  local t = p.tag or screen[p.screen].selected_tag
  local mwfact = t.master_width_factor
  local nclients = #p.clients

  -- Calculate the number of master and slave clients
  local nmaster = math.min(t.master_count, nclients)
  local nslaves = nclients - nmaster

  -- Calculate the width of master and slave areas
  local master_area_width = area.width * mwfact
  local slave_area_width = area.width - master_area_width

  -- Special case: no secondary clients
  if nslaves == 0 then
    master_area_width = area.width
    slave_area_width = 0
  end

  -- Special case: no primary clients
  if nmaster == 0 then
    master_area_width = 0
    slave_area_width = area.width
  end

  -- Arrange master clients
  for idx = 1, nmaster do
    local c = p.clients[idx]
    local g = {
      x = area.x,
      y = area.y + (idx - 1) * (area.height / nmaster),
      width = master_area_width,
      height = area.height / nmaster,
    }
    p.geometries[c] = g
  end

  -- Arrange slave clients
  for idx = 1, nslaves do
    local c = p.clients[idx + nmaster]
    local g = {
      x = area.x + master_area_width + (idx - 1) * (slave_area_width / nslaves),
      y = area.y,
      width = slave_area_width / nslaves,
      height = area.height,
    }
    p.geometries[c] = g
  end
end

-- Return the vertical layout module
return vertical
