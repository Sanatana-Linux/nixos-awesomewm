

local awful = require "awful"




-- ------------------------------------------------- --
-- Autostart Applications

local function run_once(cmd)
   local findme = cmd
   local firstspace = cmd:find(' ')
   if firstspace then
       findme = cmd:sub(0, firstspace - 1)
   end
   awful.spawn.easy_async_with_shell(string.format('pgrep -u $USER -x %s > /dev/null || (%s)', findme, cmd))
end
-- ------------------------------------------------- --
-- Add apps to autostart here via terminal commands in subshells (meaning ending with &)
autostart_apps = {
   'xautolock -time 5 -locker $HOME/.config/awesome/scripts/blur.sh & ',
   'picom &'

}

-- ------------------------------------------------- --
for app = 1, #autostart_apps do
   run_once(autostart_apps[app])
end