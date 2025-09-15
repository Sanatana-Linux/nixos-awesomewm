local Gio = require("lgi").require("Gio")
local awful = require("awful")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local gfs = require("gears.filesystem")
local modules = require("modules")
local is_supported = require("lib").is_supported
---@diagnostic disable-next-line: undefined-global
local capi = { awesome = awesome, screen = screen, client = client }
local screenshot = require("service.screenshot").get_default()
local powermenu = require("ui.popups.powermenu").get_default()
local dpi = beautiful.xresources.apply_dpi

local menu = {}

local function create_desktop_menu()
    return modules.menu({
        theme = {
            item_font = beautiful.font_name .. dpi(9),
            item_width = dpi(250),
        },
        items = {
            {
                label = "󰒓 awesome", -- nf-md-cog
                items = {
                    {
                        label = "󰒓 config", -- nf-md-cog
                        exec = function()
                            local app = Gio.AppInfo.get_default_for_type(
                                "inode/directory"
                            )
                            if app then
                                awful.spawn(
                                    string.format(
                                        "%s %s",
                                        app:get_executable(),
                                        gfs.get_configuration_dir()
                                    )
                                )
                            end
                        end,
                    },
                    {
                        label = "󰑓 restart", -- nf-md-restart
                        exec = function()
                            capi.awesome.restart()
                        end,
                    },
                    {
                        label = "⏻ power", -- nf-fa-power_off
                        exec = function()
                            powermenu:toggle()
                        end,
                    },
                },
            },
            {
                label = " screenshot", -- nf-fa-picture_o
                items = {
                    {
                        label = "󰍹 full", -- nf-md-camera
                        exec = function()
                            screenshot:take_full()
                        end,
                    },
                    {
                        label = "󰍹 full 5s delay", -- nf-md-camera
                        exec = function()
                            screenshot:take_delay(5)
                        end,
                    },
                    {
                        label = "󰄄 select area", -- nf-fa-crop
                        exec = function()
                            screenshot:take_select()
                        end,
                    },
                },
            },
            {
                label = " terminal", -- nf-dev-terminal
                exec = function()
                    local app = "kitty"
                    if app then
                        awful.spawn(app)
                    end
                end,
            },
            {
                label = " files", -- nf-fa-folder_open
                exec = function()
                    local app = "thunar"
                    if app then
                        awful.spawn(app)
                    end
                end,
            },
            {
                label = " web", -- nf-fa-firefox
                exec = function()
                    local app = "firefox-nightly"
                    if app then
                        awful.spawn(app)
                    end
                end,
            },
        },
    })
end

local function create_client_menu(c)
    local move_to_tag_item = {}
    local toggle_on_tag_item = {}

    for _, t in ipairs(c.screen.tags) do
        table.insert(move_to_tag_item, {
            label = string.format(" %s: %s", t.index, t.name), -- nf-oct-chevron_right
            exec = function()
                c:move_to_tag(t)
            end,
        })
        table.insert(toggle_on_tag_item, {
            label = string.format(" %s: %s", t.index, t.name), -- nf-fa-eye
            exec = function()
                c:toggle_tag(t)
            end,
        })
    end

    return modules.menu({
        auto_expand = true,
        theme = {
            item_font = beautiful.font_name .. "11",
            item_width = dpi(250),
        },
        items = {
            {
                label = " move", -- nf-oct-chevron_right
                items = move_to_tag_item,
            },
            {
                label = " toggle on tag", -- nf-fa-eye
                items = toggle_on_tag_item,
            },
            not c.requests_no_titlebar and {
                label = "󰐃 toggle titlebar", -- nf-md-window_restore
                exec = function()
                    awful.titlebar.toggle(c, "top")
                end,
            },
            {
                label = "󰆧 move to center", -- nf-md-crosshairs_gps
                exec = function()
                    awful.placement.centered(c, { honor_workarea = true })
                end,
            },

            {
                label = (c.ontop and "󰒍 unset ontop" or "󰒍 set ontop"), -- nf-md-arrow_up_box
                exec = function()
                    c.ontop = not c.ontop
                end,
            },
            {
                label = (c.sticky and "󰐃 unset sticky" or "󰐃 set sticky"), -- nf-md-window_restore
                exec = function()
                    c.sticky = not c.sticky
                end,
            },
            {
                label = (c.above and "󰒍 unset above" or "󰒍 set above"), -- nf-md-arrow_up_box
                exec = function()
                    c.above = not c.above
                end,
            },
            {
                label = (c.below and "󰒎 unset below" or "󰒎 set below"), -- nf-md-arrow_down_box
                exec = function()
                    c.below = not c.below
                end,
            },
            {
                label = (
                    c.fullscreen and "󰖳 unset fullscreen"
                    or "󰖳 set fullscreen"
                ), -- nf-md-fullscreen
                exec = function()
                    c.fullscreen = not c.fullscreen
                    c:activate()
                end,
            },
            {
                label = (c.maximized and "󰁌 unmaximize" or "󰁌 maximize"), -- nf-md-arrow_expand
                exec = function()
                    c.maximized = not c.maximized
                    c:activate()
                end,
            },
            {
                label = (c.minimized and "󰘕 unminimize" or "󰘕 minimize"), -- nf-md-window_minimize
                exec = function()
                    if c.minimized then
                        c.minimized = false
                        c:activate()
                    else
                        c.minimized = true
                    end
                end,
            },
            {
                label = "✕ close", -- nf-fa-close
                exec = function()
                    c:kill()
                end,
            },
        },
    })
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
    if not c then
        return
    end
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
    if not c then
        return
    end
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
    get_default = get_default,
}
