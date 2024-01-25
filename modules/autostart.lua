-- autostart module

-- Libraries and Modules
local awful = require("awful")
local sfx = require("modules.sfx")

-- -------------------------------------------------------------------------- --
-- Autostart Applications

-- Function to run a command once
local function run_once(cmd)
  local findme = cmd
  local firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace - 1)
  end
  awful.spawn.with_shell(
    string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd)
  )
end

-- -------------------------------------------------------------------------- --
-- Add apps to autostart here via terminal commands in subshells (meaning ending with &)
autostart_apps = {
  "picom -b --experimental-backends &", -- picom for compositing
  ' eval "$(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)" &', -- gnome secrets daemon
  "xrdb -merge $HOME/.Xresources &", -- xsettings
  "xss-lock lock &", -- screen locking
}

-- -------------------------------------------------------------------------- --
-- Run the autostart applications
for app = 1, #autostart_apps do
  run_once(autostart_apps[app])
end

sfx.startup()
