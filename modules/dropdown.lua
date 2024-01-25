-- Drop-down applications manager for the awesome window manager
-- Parameters:
--   prog   - Program to run
--   vert   -  "bottom", "center" or "top"
--   horiz  - "left", "right" or "center"
--   width  - Width in absolute pixels, or width percentage
--   height - Height in absolute pixels, or height percentage
--   sticky - Visible on all tags
--   screen - Screen (optional)
-- based largely off of attachdrop, just streamlined to my use case
-- https://github.com/tumurzakov/attachdrop
-- This module provides functionality for creating drop-down windows in the Awesome Window Manager.
-- It allows attaching a window under the cursor to a specific program and toggling between hidden and visible states.

local pairs = pairs
local awful = require("awful")
local setmetatable = setmetatable
local capi = {
  mouse = mouse,
  client = client,
  screen = screen,
}

local dropdown = {}

-- Attaches a window under the cursor to the specified program.
-- @param prog The program to attach the window to.
function dropdown.attach(prog)
  -- Create a table for the program if it doesn't exist
  if not dropdown[prog] then
    dropdown[prog] = {}
  end

  -- Get the current screen and client under the cursor
  local screen = capi.mouse.screen
  local c = awful.mouse.client_under_pointer()

  -- Store the client under the program and screen
  dropdown[prog][screen] = c
end

-- Creates a new window for the drop-down application when it doesn't exist,
-- or toggles between hidden and visible states when it does.
-- @param prog The program to create the window for or toggle.
-- @param vert (optional) The vertical position of the window ("top", "center", "bottom").
-- @param horiz (optional) The horizontal position of the window ("left", "center", "right").
-- @param width (optional) The width of the window (percentage of the screen width or absolute value).
-- @param height (optional) The height of the window (percentage of the screen height or absolute value).
-- @param sticky (optional) Whether the window should be sticky (always visible).
-- @param screen (optional) The screen to create the window on.
function dropdown.toggle(prog, vert, horiz, width, height, sticky, screen)
  -- Set default values if not provided
  vert = vert or "top"
  horiz = horiz or "center"
  width = width or 1
  height = height or 0.25
  sticky = sticky or false
  screen = screen or capi.mouse.screen

  -- Determine signal usage in this version of Awesome
  local attach_signal = capi.client.connect_signal or capi.client.add_signal
  local detach_signal = capi.client.disconnect_signal or capi.client.remove_signal

  -- Create a table for the program if it doesn't exist
  if not dropdown[prog] then
    dropdown[prog] = {}

    -- Add an "unmanage" signal to remove the client from the table when it is unmanaged
    attach_signal("unmanage", function(c)
      for scr, cl in pairs(dropdown[prog]) do
        if cl == c then
          dropdown[prog][scr] = nil
        end
      end
    end)
  end

  -- If the window doesn't exist, create it
  if not dropdown[prog][screen] then
    local spawnw = function(c)
      dropdown[prog][screen] = c

      -- Set the client as a floater
      awful.client.floating.set(c, true)

      -- Calculate the window geometry and placement
      local screengeom = capi.screen[screen].workarea

      if width <= 1 then
        width = math.ceil(screengeom.width * width) - 3
      end
      if height <= 1 then
        height = math.ceil(screengeom.height * height)
      end

      local x, y
      if horiz == "left" then
        x = screengeom.x
      elseif horiz == "right" then
        x = screengeom.width - width
      else
        x = screengeom.x + math.ceil((screengeom.width - width) / 2) - 1
      end

      if vert == "bottom" then
        y = screengeom.height + screengeom.y - height
      elseif vert == "center" then
        y = screengeom.y + math.ceil((screengeom.height - height) / 2)
      else
        y = screengeom.y
      end

      -- Set the client's geometry and properties
      c:geometry({ x = x, y = y, width = width, height = height })
      c.ontop = true
      c.above = true

      c:raise()
      capi.client.focus = c
      detach_signal("manage", spawnw)
    end

    -- Add a "manage" signal to create the window and spawn the program
    attach_signal("manage", spawnw)
    awful.util.spawn_with_shell(prog, false)
  else
    -- Get the running client
    local c = dropdown[prog][screen]

    -- Move the client to the current workspace
    local status, err = pcall(awful.client.movetotag, awful.tag.selected(screen), c)
    if err then
      dropdown[prog][screen] = false
      return
    end

    -- Switch the client to the current workspace if it's hidden
    if not c:isvisible() then
      c.hidden = true
      awful.client.movetotag(awful.tag.selected(screen), c)
    end

    -- Focus and raise the client if it's hidden
    if c.hidden then
      if vert == "center" then
        awful.placement.center_vertical(c)
      end
      if horiz == "center" then
        awful.placement.center_horizontal(c)
      end
      c.hidden = false
      c:raise()
      capi.client.focus = c
    else
      -- Hide and detach tags if the client is not hidden
      c.hidden = true
      local ctags = c:tags()
      for i, t in pairs(ctags) do
        ctags[i] = nil
      end
      c:tags(ctags)
    end
  end
end

return dropdown
