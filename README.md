## aura

A complete rebase, courtesu of the beautifully structured configurations of chadcat with tidbits I have picked up and preferred over the years and the wntire collection of base16 themes available to be swapped in as color themes (thanks to Python and generative AI making that almost trivial to throw in). Open source is often building upon thework of others, this configuration is no different, so don't get it twisted and don't post on r/unixporn if you won't post your dotfiles. You stole them same as everyone else, so give back and feel free to steal these for your own purposes.

### Features

-
- Cool Titlebars
- Modern Panel with windows like taskbar
- Dashboard with pomodoro and Todo
- Control panel
- Configure Widget
- Better right click menu with icons
- Calendar and Weather Widget
- i3lock-color like lockscreen with profile picture
- Minimal no-nonsense exit screen
- Application Launcher
- Good Looking notifications
- Mouse friendly custom ncmpcpp ui
- Screenshotter

## Not Features

- Desktop icons, I don't like desktop bloat and manage my filesystem effectively for all these years without that crap so it doesn't make sense to reverse on those good habits and go back to having clutter everywhere. I can't always control my material surroundings, life happens and we are all humans, but I can control my `/home/` directory
- Shell scripts or python scripts performing functionality that I could write lua code that more naturally integrates with the rest of the lua making up this configuration. Sure I use a shell script to test my changes to avoid seeing that default wallpaper and error code notifications and used a bit of python to do various one-off things to this configuration (mainly converting `.yaml` base16 scripts to `.lua` scripts that use the same variable names as the theme.lua expects to be provided). But one nice thing about this `flying spaghetti monster of code` is that the authors that graciously devote precious life to the awesomewm project have enabled me to avoid that patchwork of mismatched configuration files that you get with crap like hyprland or that way overhyped wayland fork of i3.

### Setup on other distros

1. Install these programs

```txt
awesome-git zsh pamixer imagemagick ncmpcpp mpd mpDris2 neofetch brightnessctl inotifywait uptime brillo networkmanager bluetoothctl picom redshift wezterm
```

2. Clone the repo

```
~ $ git clone --depth 1 --branch aura https://github.com/chadcat7/crystal ~/.config/awesome
```

3. Make this executable file `~/.local/bin/lock`

```bash
#!/bin/sh
playerctl pause
sleep 0.2
awesome-client "awesome.emit_signal('toggle::lock')"
```

#### Changing Themes

This is something that I do not handle as I use NixOs, but this is a sample function I used when I used Endevaour Os and Void.

```lua

local setTheme     = function(name)
  awful.spawn.with_shell('xrdb -remove')
  awful.spawn.with_shell('xrdb -merge ~/.palettes/' .. name .. " && kill -USR1 $(pidof st)")
  awful.spawn.with_shell("cp ~/.config/awesome/theme/colors/" .. name .. ".lua ~/.config/awesome/theme/colors.lua")
  awful.spawn.with_shell('cp ~/.config/rofi/colors/' .. name .. '.rasi ~/.config/rofi/colors.rasi')
end

```

3. Edit keys in `~/.cache/awesome/json/settings.json`

### Screenshots

| <b>Control Center</b>                                                                                                                             |
| ------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a href="#--------"><img src="https://raw.githubusercontent.com/chadcat7/crystal/aura/.github/screenshots/01.jpg" alt="bottom panel preview"></a> |

| <b>DashBoard</b>                                                                                                                                  |
| ------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a href="#--------"><img src="https://raw.githubusercontent.com/chadcat7/crystal/aura/.github/screenshots/02.jpg" alt="bottom panel preview"></a> |

| <b>Notification Center</b>                                                                                                                        |
| ------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a href="#--------"><img src="https://raw.githubusercontent.com/chadcat7/crystal/aura/.github/screenshots/03.jpg" alt="bottom panel preview"></a> |
| <a href="#--------"><img src="https://raw.githubusercontent.com/chadcat7/crystal/aura/.github/screenshots/04.jpg" alt="bottom panel preview"></a> |

| <b>Exit Screen And Lock</b>                                                                                                                       |
| ------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a href="#--------"><img src="https://raw.githubusercontent.com/chadcat7/crystal/aura/.github/screenshots/07.jpg" alt="bottom panel preview"></a> |
| <a href="#--------"><img src="https://raw.githubusercontent.com/chadcat7/crystal/aura/.github/screenshots/11.jpg" alt="bottom panel preview"></a> |

| <b>Calendar + Weather Widget</b>                                                                                                                  |
| ------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a href="#--------"><img src="https://raw.githubusercontent.com/chadcat7/crystal/aura/.github/screenshots/05.jpg" alt="bottom panel preview"></a> |

| <b>Configure Widget</b>                                                                                                                           |
| ------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a href="#--------"><img src="https://raw.githubusercontent.com/chadcat7/crystal/aura/.github/screenshots/06.jpg" alt="bottom panel preview"></a> |

| <b>App Menu</b>                                                                                                                                   |
| ------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a href="#--------"><img src="https://raw.githubusercontent.com/chadcat7/crystal/aura/.github/screenshots/10.jpg" alt="bottom panel preview"></a> |

| <b>Custom Ncmpcppp UI</b>                                                                                                                         |
| ------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a href="#--------"><img src="https://raw.githubusercontent.com/chadcat7/crystal/aura/.github/screenshots/09.jpg" alt="bottom panel preview"></a> |
| <a href="#--------"><img src="https://raw.githubusercontent.com/chadcat7/crystal/aura/.github/screenshots/08.jpg" alt="bottom panel preview"></a> |

| <b>Right Click Menu </b>                                                                                                                          |
| ------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a href="#--------"><img src="https://raw.githubusercontent.com/chadcat7/crystal/aura/.github/screenshots/12.jpg" alt="bottom panel preview"></a> |
