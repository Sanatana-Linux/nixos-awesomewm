-- Import necessary modules
local awful = require("awful")

-- Define the custom layout
local paper_layout = {}
paper_layout.name = "paper"

function paper_layout.arrange(p)
  -- Check if there are any clients
  if #p.clients == 0 then
    return
  end

  -- Store the number of clients
  local num_clients = #p.clients

  -- Check if the workarea width and height are not zero
  if p.workarea.width == 0 or p.workarea.height == 0 then
    return
  end

  -- Iterate over each client
  for i, c in ipairs(p.clients) do
    -- Calculate the new geometry for the client
    local new_geometry = {
      x = p.workarea.x + (i - 1) * p.workarea.width / num_clients,
      y = p.workarea.y,
      width = p.workarea.width / num_clients,
      height = p.workarea.height,
    }

    -- Apply the new geometry
    c:geometry(new_geometry)
  end
end

-- Add the custom layout to the global layouts table
table.insert(awful.layout.layouts, paper_layout)
