-------- --
-- NOTE: Inspired by bling but without any bloat, commented fully and given a refactor in the process
--   +---------------------------------------------------------------+

-- Import necessary modules
local math = math
local screen = screen

-- Create a table for the custom layout
local equalarea = {}
equalarea.name = "equalarea"

-- Recursive function to divide the screen area for clients
local function divide(p, g, low, high, cls, mwfact, mcount)
  if low == high then
    -- Base case: assign geometry to the client
    p.geometries[cls[low]] = g
  else
    -- Calculate the number of master and slave windows
    local masters = math.max(0, math.min(mcount, high) - low + 1)
    local numblock = high - low + 1
    local slaves = numblock - masters

    -- Determine the division ratio based on the number of windows
    local smalldiv = (numblock > 5 and (numblock % 5) == 0)
        and math.floor(numblock / 5)
      or ((numblock % 3) == 0) and math.floor(numblock / 3)
      or math.floor(numblock / 2)
    local bigdiv = numblock - smalldiv

    -- Calculate the number of master windows in small and big divisions
    local smallmasters = math.min(masters, smalldiv)
    local bigmasters = masters - smallmasters

    -- Create geometries for small and big divisions
    local smallg = { x = g.x, y = g.y }
    local bigg = {}

    -- Adjust the dimensions based on the available space
    if g.width > (g.height * 1.3) then
      smallg.height, bigg.height = g.height, g.height
      bigg.width = math.floor(
        g.width
          * (bigmasters * (mwfact - 1) + bigdiv)
          / (slaves + mwfact * masters)
      )
      smallg.width = g.width - bigg.width
      bigg.y, bigg.x = g.y, g.x + smallg.width
    else
      smallg.width, bigg.width = g.width, g.width
      bigg.height = math.floor(
        g.height
          * (bigmasters * (mwfact - 1) + bigdiv)
          / (slaves + mwfact * masters)
      )
      smallg.height = g.height - bigg.height
      bigg.x, bigg.y = g.x, g.y + smallg.height
    end

    -- Recursively divide the screen area for small and big divisions
    divide(p, smallg, low, high - bigdiv, cls, mwfact, mcount)
    divide(p, bigg, low + smalldiv, high, cls, mwfact, mcount)
  end
end

-- Function to arrange clients in the 'equalarea' layout
function equalarea.arrange(p)
  local t = p.tag or screen[p.screen].selected_tag
  local wa = p.workarea
  local cls = p.clients

  -- Check if there are no clients
  if #cls == 0 then
    return
  end

  -- Get layout parameters from the tag
  local mwfact = t.master_width_factor * 2
  local mcount = t.master_count

  -- Set up initial geometry for the whole screen
  local g = { height = wa.height, width = wa.width, x = wa.x, y = wa.y }

  -- Divide the screen area for clients
  divide(p, g, 1, #cls, cls, mwfact, mcount)
end

-- Return the 'equalarea' layout object
return equalarea
