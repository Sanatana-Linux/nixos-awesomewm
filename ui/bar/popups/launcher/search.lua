local wibox = require "wibox"
local beautiful = require "beautiful"
local dpi = beautiful.xresources.apply_dpi
local lgi = require "lgi"
local Gio = lgi.Gio
local Gtk = lgi.require("Gtk", "3.0")
local gears = require "gears"
local awful = require "awful"
local helpers = require "helpers"
-- Leveraging the fzy_lua plugin from
-- https://github.com/swarn/fzy-lua
-- (included in plugins ;])

local fzy = require "plugins.fzy"

local app_info = Gio.AppInfo
local icon_theme = Gtk.IconTheme.get_default()

local entry_template = {
	id = "bg",
	widget = wibox.container.background,
	bg = beautiful.dark_grey,
	shape =utilities.mkroundedrect(),
	{
		widget = wibox.container.margin,
		margins = dpi(5),
		{
			layout = wibox.layout.align.horizontal,
			{
				widget = wibox.container.margin,
				margins = dpi(5),
				{
					id = "icon",
					widget = wibox.widget.imagebox,
					shape =utilities.mkroundedrect(),
					valign = 'center',
					halign = 'center',
				}
			},
			{
				widget = wibox.container.place,
				valign = 'center',
				halign = 'left',
				{
					id = "nameanddesc",
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(3),
					{
						id = "appname",
						widget = wibox.widget.textbox,
						font = beautiful.nerd_font .. " 12",
						forced_height = beautiful.get_font_height(beautiful.nerd_font .. " 12"),
						fg =beautiful.white
					},
				}
			},
			wibox.widget.base.make_widget()
		}
	}
}

local function replace_with_escapes(text)
	if text then
		text = text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub("'", "&#39;")
	end
	return text
end
-- -------------------------------------------------------------------------- --
--entries need to be cached for every widget instance or highlights will be messy
---Entries of the launcher
---@return table Entries every entry is a table with widget, appinfo and appname
local function get_entries()
	local LAUNCHER_CACHED_ENTRIES = {}
	for _, app in ipairs(app_info.get_all()) do
		if app:should_show() then
			--widget instance
			local widget = wibox.widget(entry_template)
			local icon_widget = widget:get_children_by_id("icon")[1]

			-- fetch data
			local name = replace_with_escapes(app:get_name())
			local desc = app:get_description()

			-- set info
			widget:get_children_by_id("appname")[1]:set_markup_silently("<span>" .. name .. "</span>")
			local app_icon = app:get_icon()
			if app_icon then
				local pathorname = app_icon:to_string()
				if pathorname then
					if string.find(pathorname, "/") then --Icon names dont contain slashes
						icon_widget:set_image(pathorname)
					else
						local icon_info = icon_theme:lookup_icon(pathorname, dpi(48), 0)
						if icon_info then
							local path = icon_info:get_filename()
							if path then
								icon_widget:set_image(path)
							end
						end
					end
				end
			end

			if desc then
				local desc_wid = wibox.widget {
					id = "description",
					widget = wibox.widget.textbox,
					font = beautiful.nerd_font .. " 10",
					markup = "<span  foreground='" .. beautiful.lesswhite .. "'>" .. replace_with_escapes(desc) .. "</span>"
				}
				widget:get_children_by_id("nameanddesc")[1]:add(desc_wid)
			end
-- -------------------------------------------------------------------------- --
			-- connect signals
			-- 
			local bg = widget:get_children_by_id("bg")[1]
			widget:connect_signal("mouse::enter", function ()
				local s = awful.screen.focused()
				s.popup_launcher_widget:__reset_highlight()
				bg.bg = beautiful.bg_focus
				--hacky-ish way of retriving current widget position
				s.popup_launcher_widget.selected_entry = s.popup_launcher_widget:get_children_by_id("grid")[1]
				:get_widget_position(widget).row
			end)
			widget:add_button( awful.button {
				modifiers = {},
				button = 1,
				on_press = function ()
					awful.screen.focused().popup_launcher_widget:stop_search()
					app:launch()
				end
			})
			utilities.pointer_on_focus(widget)

			local cmd = app:get_commandline()

			widget.appinfo = app
			widget.search_params = { string.lower(name) }
			
			
			if cmd then table.insert(widget.search_params, string.lower(cmd)) end

			LAUNCHER_CACHED_ENTRIES[#LAUNCHER_CACHED_ENTRIES+1] = widget
		end
	end
	table.sort(LAUNCHER_CACHED_ENTRIES, function (a,b)
		--search param 1 is always the name
		-- 
		return a.search_params[1] < b.search_params[1]
	end)
	return LAUNCHER_CACHED_ENTRIES
end

local widget_template = {
	widget=wibox.container.scroll.vertical,
	id = 'grid',
	layout = wibox.layout.grid,
	homogeneous = true,
	num_cols = 1,
	num_rows = 10,
	expand = true,
	vertical_spacing = dpi(1),
}

local function init(s)
	local launcher_entries = get_entries()
	s.popup_launcher_widget = wibox.widget(widget_template)
	local entry_grid = s.popup_launcher_widget --"legacy" naming

	local promptwidget = wibox.widget {
		id = 'bg',
		widget = wibox.container.background,
		bg = beautiful.dark_grey,
		shape =utilities.mkroundedrect(),
		{
			widget = wibox.container.margin,
			margins = dpi(5),
			{
				layout = wibox.layout.align.horizontal,
				expand = "inside",
				{
					widget = wibox.container.margin,
					margins = dpi(5),
					{
						widget = wibox.widget.imagebox,
						image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. "/themes/assets/icons/svg/search.svg", beautiful.fg_normal),
						valign = 'center',
						halign = 'center',
					}
				},
				{
					id = "promptbox",
					widget = wibox.container.place,
					valign = 'center',
					halign = 'left',
					fill_content_horizontal = true,
					{
						id = 'prompttext',
						font = beautiful.nerd_font .. " 12",
						halign = 'left',
						markup = "<span >search apps</span>",
						widget = wibox.widget.textbox,
						forced_width = dpi(1000),
					}
				},
				wibox.widget.base.make_widget()
			}
		}
	}
	entry_grid:add_widget_at(promptwidget, 10, 1, 1, 1)

	local prompttext = promptwidget:get_children_by_id("prompttext")[1]
	local entry_grid = s.popup_launcher_widget:get_children_by_id("grid")[1]

	s.popup_launcher_widget.selected_entry = 10

	function s.popup_launcher_widget:stop_search()
		awful.keyboard.emulate_key_combination({}, "Escape")
		self:__reset_highlight()
	end

	function s.popup_launcher_widget:__reset_highlight()
		local prev_hl = entry_grid:get_widgets_at(self.selected_entry, 1, 1, 1)
		if prev_hl then prev_hl[1].bg = beautiful.dark_grey end
	end

	function s.popup_launcher_widget:__reset_all_highlights()
		for _, widget in ipairs(launcher_entries) do
			widget.bg = beautiful.dark_grey
		end
	end

	---@param check_valid function function to check if select function can be run
	---@param diff integer the selected_entry diff upon running select
	function s.popup_launcher_widget:__select_helper(check_valid, diff)
		if check_valid(s.popup_launcher_widget.selected_entry) then
			local new_hl = entry_grid:get_widgets_at(self.selected_entry + diff, 1, 1, 1)
			if new_hl then
				self:__reset_highlight()
				self.selected_entry = self.selected_entry + diff
				new_hl[1]:get_children_by_id('bg')[1].bg = beautiful.bg_focus
			end
		end
	end

	function s.popup_launcher_widget:select_down()
		self:__select_helper(function (index)
			return index < 9
		end, 1)
	end

	function s.popup_launcher_widget:select_up()
		self:__select_helper(function (index)
			return index > 1
		end, -1)
	end

	function s.popup_launcher_widget:__reset_search()
		prompttext:set_markup_silently("<span >Search Applications</span>")
		for i = 1, 9, 1 do
			entry_grid:remove_widgets_at(10-i, 1, 1, 1)
			entry_grid:add_widget_at(launcher_entries[i], 10-i, 1, 1, 1)
		end
		self.selected_entry = 9
		entry_grid:get_widgets_at(self.selected_entry, 1, 1, 1)[1].bg = beautiful.bg_focus
	end

	function s.popup_launcher_widget:search_entries(filter)
		self:__reset_highlight()

		local filtered = {}
		for _, entry in ipairs(launcher_entries) do
			for _, attr in ipairs(entry.search_params) do
				if fzy.has_match(filter, attr, false) then
					table.insert(filtered, entry)
					break
				end
			end
		end
		-- some weighting on the match results (to sort matches) 
		local function calc_filter_score(entry)
			local filter_res = fzy.filter(filter, entry.search_params, false)
				local sum = 0.0
				for _, scoring in ipairs(filter_res) do
					sum = sum + scoring[3]
				end
			return sum
		end

		-- save the score to not call this all the time
		for _, entry in ipairs(filtered) do
			entry.match_score = calc_filter_score(entry)
		end

		-- sort the filtered entries
		table.sort(filtered, function (a, b)
			return a.match_score > b.match_score
		end)

		-- this would usually done via reset, but the prompt is part of the grid so not possible
		for i = 1, 9, 1 do
			entry_grid:remove_widgets_at(i, 1, 1, 1)
		end
		for i, entry in ipairs(filtered) do
			if i == 10 then break end
			entry_grid:add_widget_at(entry, 10-i, 1, 1, 1)
		end
		if #filtered > 0 then
			filtered[1].bg = beautiful.bg_focus
			self.selected_entry = 9
		end
	end

	---@param hide_after_search boolean if the launcher wibox should be hidden after running the applauncher
	function s.popup_launcher_widget:start_search(hide_after_search)
		promptwidget:get_children_by_id('bg')[1].bg = beautiful.bg_focus
		self:__reset_highlight()
		entry_grid:get_widgets_at(self.selected_entry, 1, 1, 1)[1].bg = beautiful.bg_focus
		--weird shit going on for no reason whatsoever when not focusing the wibox, so mouse will be moved
		if mouse.current_wibox ~= s.launcher then
			mouse.coords({
				x = s.launcher.x + s.launcher.width/2,
				y = s.launcher.y + s.launcher.height - dpi(30)
			})
		end
		awful.prompt.run {
			textbox = prompttext,
			bg_cursor = beautiful.fg_normal,
			font = beautiful.nerd_font,
			hooks = {
				{{}, "Up", function (cmd)
					self:select_up()
					return cmd, true
				end},
				{{}, "Down", function (cmd)
					self:select_down()
					return cmd, true
				end},
				{{}, "Return",function ()
					local sel = entry_grid:get_widgets_at(self.selected_entry, 1, 1, 1)
					if sel then
						self:__reset_highlight()
						sel[1].appinfo:launch()
					end
				end}
			},
			changed_callback = function (cmd)
				s.popup_launcher_widget:search_entries(cmd)
				collectgarbage("collect")
			end,
			done_callback = function ()
				self:__reset_search()
				--resetting only the current highlight can cause buggy behaviour here
				--self:__reset_all_highlights()
				self:__reset_highlight()
				promptwidget:get_children_by_id('bg')[1].bg = beautiful.dark_grey
				if hide_after_search then
					s.launcher:hide()
				end
			end
		}
	end

	function s.popup_launcher_widget:is_active()
		return prompttext.text ~= "search apps"
	end

	--s.popup_launcher_widget:get_children_by_id("promptbox")[1]
	promptwidget:add_button(awful.button{
		modifiers = {},
		button = 1,
		on_press = function ()
			s.popup_launcher_widget:start_search(false)
		end
	})

	-- initial fill
	s.popup_launcher_widget:__reset_search()
	return s.popup_launcher_widget
end

return {
	init = init
}
