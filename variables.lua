--  ___ ___              __         __     __              
-- |   |   |.---.-.----.|__|.---.-.|  |--.|  |.-----.-----.
-- |   |   ||  _  |   _||  ||  _  ||  _  ||  ||  -__|__ --|
--  \_____/ |___._|__|  |__||___._||_____||__||_____|_____|
                                                        
-- -------------------------------------------------------------------------- --
-- Variables, as well as modules and libraries are all called here. This prevents 
-- needing to call them all redundantly in dozens of files, which I have found 
-- improves my developer experiene while seeming to improve responsiveness 

---@diagnostic disable: lowercase-global
local menubar = require("menubar")

-- -------------------------------------------------------------------------- --
-- ----------------------------- user variables ----------------------------- --
terminal = "kitty"
explorer = "thunar"
browser = "firefox"
launcher = "rofi -show drun"
editor = os.getenv("EDITOR") or "nvim"
visual_editor = "code" -- vscode
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4" -- the voldemort key 




-- -------------------------------------------------------------------------- --
-- ---------------------------- global variables ---------------------------- --

debug = debug
keygrabber = keygrabber
mouse = mouse
pairs = pairs
string = string
tonumber = tonumber
tostring = tostring
unpack = unpack or table.unpack

-- keymap variables 
numpad_map = { 87, 88, 89, 83, 84, 85, 79, 80, 81 }

-- path variables 
HOME = os.getenv 'HOME'

-- builtin modules 

awful = require('awful')
beautiful = require("beautiful")
gears = require('gears')
gobject = require('gears.object')
gtable = require('gears.table')
gtimer = require('gears.timer')
gstring = require('gears.string')
filesystem = require('gears.filesystem')
math = require('math')
menubar = require('menubar')
os = require('os')
string = require('string')
naughty = require('naughty')
spawn = require('awful.spawn')
string = require('string')
watch = require('awful.widget.watch')
wibox = require('wibox')

--  builtin submodules

cairo = require('lgi').cairo
dpi = beautiful.xresources.apply_dpi
Gio = require('lgi').Gio
gtk_variable = beautiful.gtk.get_theme_variables
menubar.utils.terminal = terminal

-- internal modules 

snap_edge = require('configuration..snap_edge')
utilities = require('utilities')
