---@diagnostic disable: lowercase-global
-- -------------------------------------------------------------------------- --
--  ___ ___              __         __     __              
-- |   |   |.---.-.----.|__|.---.-.|  |--.|  |.-----.-----.
-- |   |   ||  _  |   _||  ||  _  ||  _  ||  ||  -__|__ --|
--  \_____/ |___._|__|  |__||___._||_____||__||_____|_____|
-- -------------------------------------------------------------------------- --
-- Variables, as well as modules and libraries are all called here. This prevents 
-- needing to call them all redundantly in dozens of files, which I have found 
-- improves my developer experiene while seeming to improve responsiveness 
-- -------------------------------------------------------------------------- --
-- requires menubar called first locally or it will fail
-- 
local menubar = require("menubar")
-- -------------------------------------------------------------------------- --
-- 
-- -------------------------------------------------------------------------- --
--                               User Variables                               --
-- -------------------------------------------------------------------------- --
terminal = "kitty"
explorer = "thunar"
browser = "firefox"
launcher = "rofi -show drun"
editor = os.getenv("EDITOR") or "nvim"
visual_editor = "code" -- vscode
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4" -- the voldemort key 
-- -------------------------------------------------------------------------- --
-- 
-- -------------------------------------------------------------------------- --
--                              Global Variables                              --
-- -------------------------------------------------------------------------- --
debug = debug
keygrabber = keygrabber
mouse = mouse
pairs = pairs
string = string
tonumber = tonumber
tostring = tostring
unpack = unpack or table.unpack
-- -------------------------------------------------------------------------- --
-- 
-- ---------------------------- Keymap Variables---------------------------- --
-- 
numpad_map = { 87, 88, 89, 83, 84, 85, 79, 80, 81 }
-- -------------------------------------------------------------------------- --
-- 
-- ----------------------------- Path Variables ----------------------------- --
-- 
HOME = os.getenv 'HOME'
-- -------------------------------------------------------------------------- --
-- 
-- ----------------------------- Builtin Modules ---------------------------- --
-- 
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
-- -------------------------------------------------------------------------- --
 -- --------------------------- Builtin Submodules --------------------------- --
cairo = require('lgi').cairo
dpi = beautiful.xresources.apply_dpi
Gio = require('lgi').Gio
gtk_variable = beautiful.gtk.get_theme_variables
menubar.utils.terminal = terminal
-- -------------------------------------------------------------------------- --
-- --------------------------- Third Party Modules -------------------------- --
rubato = require("modules.rubato")
-- -------------------------------------------------------------------------- --
-- 
-- ---------------------------- Internal Modules ---------------------------- --
utilities = require('utilities')
icons = require('themes.assets.icons')
