local ruled = require("ruled")
local awful = require("awful")

local function setup_rules()
  ruled.client.connect_signal("request::rules", function()

    -- -------------------------------------------------------------------------- --
    -- ----------------------------------- ALL ---------------------------------- --
    --
    ruled.client.append_rule {
      id = "global",
      rule = {},
      properties = {
        focus = awful.client.focus.filter,
        raise = true,
        maximized = false,
        above = false,
        below = false,
        size_hints_honor = true,
        ontop = false,
        honor_padding = true,
        honor_workarea = true,
        sticky = false,
        -- screen = awful.screen.preferred,
        -- most durable (so far) solution to insuring the window dialogs are
        -- on screen with the parent window and the screens open on the screen
        -- where the mouse is. The joys of awesomewm
        screen = function(c)
          if awesome.startup then
            return c.screen
          else
            return awful.screen.focused(c)
          end
        end,
        shape = utilities.mkroundedrect()
      }
    }

    -- -------------------------------------------------------------------------- --
    -- ----------------- Titlebar rules ---------------- --
    --
    ruled.client.append_rule {
      id = "titlebars",
      rule_any = {type = {"normal", "dialog", "modal", "utility"}},
      except_any = {name = {"Discord Updater"}},
      properties = {
        titlebars_enabled = true,
        round_corners = true,
        shape = utilities.mkroundedrect()
      }
    }

    -- -------------------------------------------------------------------------- --
    -- --------------------------------- Dialogs -------------------------------- --
    --
    ruled.client.append_rule {
      id = "dialog",
      rule_any = {
        type = {"dialog"},
        class = {"Wicd-client.py", "calendar.google.com"}
      },
      properties = {
        titlebars_enabled = true,
        floating = true,
        above = true,
        size_hints_honor = false,
        honor_padding = true,
        honor_workarea = true,
        placement = awful.placement.under_mouse + awful.placement.center + awful.placement.no_offscreen
      }
    }

    -- -------------------------------------------------------------------------- --
    -- --------------------------------- Modals --------------------------------- --
    --
    ruled.client.append_rule {
      id = "modal",
      rule_any = {type = {"modal"}},
      properties = {
        titlebars_enabled = true,
        floating = true,
        above = true,
        skip_decoration = true
      }
    }

    -- -------------------------------------------------------------------------- --
    -- -------------------------------- Utilities ------------------------------- --
    --
    ruled.client.append_rule {
      id = "utility",
      rule_any = {type = {"utility"}},
      properties = {titlebars_enabled = false, floating = true}
    }

    -- -------------------------------------------------------------------------- --
  -- --------------------------------- Splash --------------------------------- --
    --
    ruled.client.append_rule {
      id = "splash",
      rule_any = {type = {"splash"}, name = {"Discord Updater"}},
      properties = {
        titlebars_enabled = false,
        round_corners = false,
        floating = true,
        above = true,
        skip_decoration = true
      }
    }
    -- -------------------------------------------------------------------------- --
    -- --------------------------- Terminal Emulators --------------------------- --
    --
    ruled.client.append_rule {
      id = "terminals",
      rule_any = {
        class = {
          "URxvt",
          "XTerm",
          "Alacritty",
          "UXTerm",
          "kitty",
          "tym",
          "K3rmit",
          "wezterm",
          
        }
      },
      properties = {titlebars_enabled = true}
    }

    -- -------------------------------------------------------------------------- --
    -- ----------------------------- Image Galleries ---------------------------- --
    --
    ruled.client.append_rule {
      id = "image_viewers",
      rule_any = {class = {"feh", "Pqiv", "Sxiv", "imv"}},
      properties = {
        titlebars_enabled = true,
        skip_decoration = true,
        floating = true,
        ontop = true
      }
    }
    -- -------------------------------------------------------------------------- --
    -- ---------------------------- Centered Windows ---------------------------- --
    -- 
    ruled.client.append_rule {
      id = "center_placement",
      rule_any = {
        type = {"dialog", "modal", "utility", "splash"},
        class = {
          "Steam",
          "discord",
          "markdown_input",
          "scratchpad",
          "feh",
          "Pqiv",
          "Sxiv",
          "imv"
        },
        instance = {"markdown_input", "scratchpad"},
        role = {"GtkFileChooserDialog", "conversation"}
      },
      properties = {
        size_hints_honor = true,
        honor_padding = true,
        honor_workarea = true,
        placement = awful.placement.center + awful.placement.no_offscreen
      }
    }
    -- -------------------------------------------------------------------------- --
    -- ---------------------------- Floationg Windows --------------------------- --
    --
    ruled.client.append_rule {
      id = "floating",
      rule_any = {
        instance = {"file_progress", "Popup", "nm-connection-editor"},
        class = {"scrcpy", "gpick", "Mugshot", "Pulseeffects"},
        role = {"AlarmWindow", "ConfigManager", "pop-up"}
      },
      properties = {
        titlebars_enabled = true,
        ontop = true,
        floating = true,
        raise = true
      }
    }

    -- -------------------------------------------------------------------------- --
    
    ruled.client.append_rule {
      id = "floating_not_top",
      rule_any = {
        class = {
          "virt-manager",
          "Virt-manager",
          "VirtualBox Manager",
          "VirtualBox Manager",
          "mate-color-select",
          "Mate-color-select"
        }
      },
      properties = {
        titlebars_enabled = true,
        ontop = false,
        floating = true,
        raise = true
      }
    }
  end)

end 

setup_rules()
