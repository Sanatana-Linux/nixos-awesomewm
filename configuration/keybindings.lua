---@diagnostic disable: undefined-global
local awful = require("awful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- -------------------------------------------------------------------------- --
--                                 Keybindings                                --
-- -------------------------------------------------------------------------- --
local function set_keybindings()
  awful.keyboard.append_global_keybindings({
    awful.key({modkey}, "F1", hotkeys_popup.show_help,
              {description = "show help", group = "awesome"}),
    -- -------------------------------------------------------------------------- --
    awful.key({modkey}, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    -- -------------------------------------------------------------------------- --
    awful.key({modkey, "Shift"}, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    -- -------------------------------------------------------------------------- --
    awful.key({modkey}, "Return", function()
      awful.spawn(terminal)
    end, {description = "open a terminal", group = "launcher"}),
    -- -------------------------------------------------------------------------- --
    awful.key({modkey}, "p", function()
      menubar.show()
    end, {description = "show the menubar", group = "launcher"}),
    -- -------------------------------------------------------------------------- --
    awful.key({modkey, "Shift"}, "Return", function()
      awful.spawn("rofi -show drun")
    end, {description = "Open rofi", group = "launcher"})
  })

  -- -------------------------------------------------------------------------- --
  -- center a floating window
  awful.keyboard.append_global_keybindings({
    awful.key({modkey}, "`", function()
      awful.placement.centered(client.focus, {honor_workarea = true})
    end, {description = "Center a floating window", group = "Client"})
  })
  -- -------------------------------------------------------------------------- --
  -- ------------------------------ Focus Related ----------------------------- --
  awful.keyboard.append_global_keybindings({
   
   -- -------------------------------------------------------------------------- --
   
    awful.key({modkey}, "j", function()
      awful.client.focus.byidx(1)
    end, {description = "focus next by index", group = "Client"}),
   
    -- -------------------------------------------------------------------------- --
   
    awful.key({modkey}, "k", function()
      awful.client.focus.byidx(-1)
    end, {description = "focus previous by index", group = "Client"}),
    -- -------------------------------------------------------------------------- --
   
    awful.key({modkey, "Control"}, "j", function()
      awful.screen.focus_relative(1)
    end, {description = "focus the next screen", group = "Screen"}),
   
    -- -------------------------------------------------------------------------- --
   
    awful.key({modkey, "Control"}, "k", function()
      awful.screen.focus_relative(-1)
    end, {description = "focus the previous screen", group = "Screen"}),
   
    -- -------------------------------------------------------------------------- --
  
    awful.key({modkey, "Control"}, "n", function()
      local c = awful.client.restore()
      if c then
        c:activate{raise = true, context = "key.unminimize"}
      end
    end, {description = "restore minimized", group = "Client"})
  })
  
  -- -------------------------------------------------------------------------- --
  -- ----------------------------- Layout related ----------------------------- --
  
  awful.keyboard.append_global_keybindings({
  
    -- -------------------------------------------------------------------------- --

    awful.key({modkey, "Shift"}, "j", function()
      awful.client.swap.byidx(1)
    end, {description = "swap with next client by index", group = "Client"}),
  
    -- -------------------------------------------------------------------------- --
  
    awful.key({modkey, "Shift"}, "k", function()
      awful.client.swap.byidx(-1)
    end, {description = "swap with previous client by index", group = "Client"}),

    -- -------------------------------------------------------------------------- --
    
    awful.key({modkey}, "l", function()
      awful.tag.incmwfact(0.05)
    end, {description = "increase master width factor", group = "Layout"}),
    
    -- -------------------------------------------------------------------------- --
    
    awful.key({modkey}, "h", function()
      awful.tag.incmwfact(-0.05)
    end, {description = "decrease master width factor", group = "Layout"}),
    
    -- -------------------------------------------------------------------------- --
    
    awful.key({modkey, "Shift"}, "h", function()
      awful.tag.incnmaster(1, nil, true)
    end, {
      description = "increase the number of master clients",
      group = "Layout"
    }),
    
    -- -------------------------------------------------------------------------- --
    
    awful.key({modkey, "Shift"}, "l", function()
      awful.tag.incnmaster(-1, nil, true)
    end, {
      description = "decrease the number of master clients",
      group = "Layout"
    }),
    
    -- -------------------------------------------------------------------------- --
    
    awful.key({modkey, "Control"}, "h", function()
      awful.tag.incncol(1, nil, true)
    end, {description = "increase the number of columns", group = "Layout"}),
    
    -- -------------------------------------------------------------------------- --
    
    awful.key({modkey, "Control"}, "l", function()
      awful.tag.incncol(-1, nil, true)
    end, {description = "decrease the number of columns", group = "Layout"}),
    
    -- -------------------------------------------------------------------------- --
    
    awful.key({modkey}, "space", function()
        awesome.emit_signal('layout::changed:next')
    end, {description = "select next", group = "Layout"}),
    
    -- -------------------------------------------------------------------------- --
    
    awful.key({modkey, "Shift"}, "space", function()
        awesome.emit_signal('layout::changed:prev')
    end, {description = "select previous", group = "Layout"})
  })

  -- -------------------------------------------------------------------------- --
  -- ------------------------ @DOC_NUMBER_KEYBINDINGS@ ------------------------ --

  awful.keyboard.append_global_keybindings({
    awful.key({
      modifiers = {modkey},
      keygroup = "numrow",
      description = "only view tag",
      group = "tags",
      on_press = function(index)
        local screen = awful.screen.focused()
        local tag = screen.tags[index]
        if tag then
          tag:view_only()
        end
      end
    }),
    
    -- -------------------------------------------------------------------------- --
    
    awful.key({
      modifiers = {modkey, "Control"},
      keygroup = "numrow",
      description = "toggle tag",
      group = "tag",
      on_press = function(index)
        local screen = awful.screen.focused()
        local tag = screen.tags[index]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end
    }),
    
    -- -------------------------------------------------------------------------- --
    
    awful.key({
      modifiers = {modkey, "Shift"},
      keygroup = "numrow",
      description = "move focused client to tag",
      group = "tag",
      on_press = function(index)
        if client.focus then
          local tag = client.focus.screen.tags[index]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end
    }),
    
    -- -------------------------------------------------------------------------- --
    
    awful.key({
      modifiers = {modkey, "Control", "Shift"},
      keygroup = "numrow",
      description = "toggle focused client on tag",
      group = "tag",
      on_press = function(index)
        if client.focus then
          local tag = client.focus.screen.tags[index]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end
    })
    
    -- -------------------------------------------------------------------------- --
  })
  -- -------------------------------------------------------------------------- --
  -- ------------------------ @DOC_CLIENT_KEYBINDINGS@ ------------------------ --
  client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
      -- -------------------------------------------------------------------------- --
      awful.key({modkey, "Control"}, "f", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
      end, {description = "toggle fullscreen", group = "Client"}),
      -- -------------------------------------------------------------------------- --
      awful.key({modkey}, "w", function(c)
        c:kill()
      end, {description = "close", group = "Client"}),
      -- -------------------------------------------------------------------------- --
      awful.key({modkey}, "f", awful.client.floating.toggle,
                {description = "toggle floating", group = "Client"}),
      -- -------------------------------------------------------------------------- --
      awful.key({modkey, "Control"}, "Return", function(c)
        c:swap(awful.client.getmaster())
      end, {description = "move to master", group = "Client"}),
      -- -------------------------------------------------------------------------- --
      awful.key({modkey}, "o", function(c)
        c:move_to_screen()
      end, {description = "move to screen", group = "Client"}),
      -- -------------------------------------------------------------------------- --
      awful.key({modkey}, "t", function(c)
        c.ontop = not c.ontop
      end, {description = "toggle keep on top", group = "Client"}),
      -- -------------------------------------------------------------------------- --
      awful.key({modkey}, "n", function(c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
      end, {description = "minimize", group = "Client"}),
      -- -------------------------------------------------------------------------- --
      
      awful.key({modkey}, "m", function(c)
        c.maximized = not c.maximized
        c:raise()
      end, {description = "(un)maximize", group = "Client"}),
      
      -- -------------------------------------------------------------------------- --

      awful.key({modkey, "Control"}, "m", function(c)
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
      end, {description = "(un)maximize vertically", group = "Client"}),
      -- -------------------------------------------------------------------------- --

      awful.key({modkey, "Shift"}, "m", function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
      end, {description = "(un)maximize horizontally", group = "Client"}),

      -- -------------------------------------------------------------------------- --
      -- --------------------------- Snap to edge/corner -------------------------- --
      
      awful.key({modkey, "Shift"}, "#" .. numpad_map[1], function(c)
        snap_edge(c, "bottomleft")
      end),
      
      -- -------------------------------------------------------------------------- --

      awful.key({modkey, "Shift"}, "#" .. numpad_map[2], function(c)
        snap_edge(c, "bottom")
      end),
      -- -------------------------------------------------------------------------- --

      awful.key({modkey, "Shift"}, "#" .. numpad_map[3], function(c)
        snap_edge(c, "bottomright")
      end),
      
      -- -------------------------------------------------------------------------- --
      
      awful.key({modkey, "Shift"}, "#" .. numpad_map[4], function(c)
        snap_edge(c, "left")
      end),
      
      -- -------------------------------------------------------------------------- --
      
      awful.key({modkey, "Shift"}, "#" .. numpad_map[5], function(c)
        snap_edge(c, "center")
      end),
      
      -- -------------------------------------------------------------------------- --
      
      awful.key({modkey, "Shift"}, "#" .. numpad_map[6], function(c)
        snap_edge(c, "right")
      end),
      
      -- -------------------------------------------------------------------------- --
      
      awful.key({modkey, "Shift"}, "#" .. numpad_map[7], function(c)
        snap_edge(c, "topleft")
      end),
      
      -- -------------------------------------------------------------------------- --
      
      awful.key({modkey, "Shift"}, "#" .. numpad_map[8], function(c)
        snap_edge(c, "top")
      end),
      
      -- -------------------------------------------------------------------------- --
      
      awful.key({modkey, "Shift"}, "#" .. numpad_map[9], function(c)
        snap_edge(c, "topright")
      end)

    })
  end)

end

set_keybindings()
