local Gio = require("lgi").require("Gio")
local awful = require("awful")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local gfs = require("gears.filesystem")
local modules = require("modules")
local user = require("user")
local is_supported = require("lib").is_supported
local table_to_file = require("lib").table_to_file
local capi = { awesome = awesome, screen = screen, client = client }
local screenshot = require("service.screenshot").get_default()
local powermenu = require("ui.powermenu").get_default()

local menu = {}

local function create_desktop_menu()
	return modules.menu {
		theme = {
			item_font = beautiful.font_h0
		},
		items = {
			{
				label = "awesome",
				items = {
					{
						label = "config",
						exec = function()
							local app = Gio.AppInfo.get_default_for_type("inode/directory")
							if app then
								awful.spawn(string.format(
									"%s %s",
									app:get_executable(),
									gfs.get_configuration_dir()
								))
							end
						end
					},
					{
						label = "set wallpaper",
						exec = function()
							awful.spawn.easy_async("zenity --file-selection", function(stdout)
								stdout = string.gsub(stdout, "\n", "")
								local formats = { "png", "jpg", "jpeg" }
								if stdout ~= nil and stdout ~= "" and is_supported(stdout, formats) then
									for s in capi.screen do
										s.wallpaper:set_image(stdout)
									end
									user.wallpaper = stdout
									table_to_file(user, gfs.get_configuration_dir() .. "/user.lua")
								end
							end)
						end
					},
					{
						label = "restart",
						exec = function()
							capi.awesome.restart()
						end
					},
					{
						label = "power",
						exec = function()
							powermenu:toggle()
						end
					}
				}
			},
			{
				label = "screenshot",
				items = {
					{
						label = "full",
						exec = function()
							screenshot:take_full()
						end
					},
					{
						label = "full 5s delay",
						exec = function()
							screenshot:take_delay(5)
						end
					},
					{
						label = "select area",
						exec = function()
							screenshot:take_select()
						end
					}
				}
			},
			{
				label = "terminal",
				exec = function()
					local app = "kitty"
					if app then awful.spawn(app) end
				end
			},
			{
				label = "files",
				exec = function()
					local app = "thunar"
					if app then awful.spawn(app) end
				end
			},
			{
				label = "web",
				exec = function()
					local app = "firefox"
					if app then awful.spawn(app) end
				end
			}
		}
	}
end

local function create_client_menu(c)
	local move_to_tag_item = {}
	local toggle_on_tag_item = {}

	for _, t in ipairs(c.screen.tags) do
		table.insert(move_to_tag_item, {
			label = string.format("%s: %s", t.index, t.name),
			exec = function()
				c:move_to_tag(t)
			end
		})
		table.insert(toggle_on_tag_item, {
			label = string.format("%s: %s", t.index, t.name),
			exec = function()
				c:toggle_tag(t)
			end
		})
	end

	return modules.menu {
		auto_expand = true,
		theme = {
			item_font = beautiful.font_h0
		},
		items = {
			{
				label = "move to tag",
				items = move_to_tag_item
			},
			{
				label = "toggle on tag",
				items = toggle_on_tag_item
			},
			not c.requests_no_titlebar and {
				label = "toggle titlebar",
				exec = function()
					awful.titlebar.toggle(c, "top")
				end
			},
			{
				label = "move to center",
				exec = function()
					awful.placement.centered(c, { honor_workarea = true })
				end
			},
			{
				label = c.ontop and "unset ontop" or "set ontop",
				exec = function()
					c.ontop = not c.ontop
				end
			},
			{
				label = c.fullscreen and "unset fullscreen" or "set fullscreen",
				exec = function()
					c.fullscreen = not c.fullscreen
					c:activate()
				end
			},
			{
				label = c.maximized and "unmaximize" or "maximize",
				exec = function()
					c.maximized = not c.maximized
					c:activate()
				end
			},
			{
				label = c.minimized and "unminimize" or "minimize",
				exec = function()
					if c.minimized then
						c.minimized = false
						c:activate()
					else
						c.minimized = true
					end
				end
			},
			{
				label = "close",
				exec = function()
					c:kill()
				end
			}
		}
	}
end

function menu:hide()
	if self.menu_widget and self.menu_widget.visible then
		self.menu_widget:hide()
		self.menu_widget = nil
	end
end

function menu:show_desktop_menu()
	if self.menu_widget then
		if not self.menu_widget.visible then
			self.menu_widget = create_desktop_menu()
			self.menu_widget:show()
		end
	else
		self.menu_widget = create_desktop_menu()
		self.menu_widget:show()
	end
end

function menu:toggle_desktop_menu()
	if self.menu_widget then
		if self.menu_widget.visible then
			self.menu_widget:hide()
			self.menu_widget = nil
		else
			self.menu_widget = create_desktop_menu()
			self.menu_widget:show()
		end
	else
		self.menu_widget = create_desktop_menu()
		self.menu_widget:show()
	end
end

function menu:show_client_menu(c)
	c = c or capi.client.focus
	if not c then return end
	if self.menu_widget then
		if not self.menu_widget.visible then
			self.menu_widget = create_client_menu(c)
			self.menu_widget:show()
		end
	else
		self.menu_widget = create_client_menu(c)
		self.menu_widget:show()
	end
end

function menu:toggle_client_menu(c)
	c = c or capi.client.focus
	if not c then return end
	if self.menu_widget then
		if self.menu_widget.visible then
			self.menu_widget:hide()
			self.menu_widget = nil
		else
			self.menu_widget = create_client_menu(c)
			self.menu_widget:show()
		end
	else
		self.menu_widget = create_client_menu(c)
		self.menu_widget:show()
	end
end

local function new()
	local ret = {}
	gtable.crush(ret, menu, true)
	return ret
end

local instance = nil
local function get_default()
	if not instance then
		instance = new()
	end
	return instance
end

return {
	get_default = get_default
}
