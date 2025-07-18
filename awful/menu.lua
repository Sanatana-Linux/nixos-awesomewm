---@diagnostic disable: undefined-global
local wibox = require("wibox")
local button = require("awful.button")
local gstring = require("gears.string")
local gtable = require("gears.table")
local spawn = require("awful.spawn")
local keygrabber = require("awful.keygrabber")
local beautiful = require("beautiful")
local object = require("gears.object")
local surface = require("gears.surface")
local protected_call = require("gears.protected_call")
local cairo = require("lgi").cairo
local dpi = require("beautiful").xresources.apply_dpi
local setmetatable = setmetatable
local tonumber = tonumber
local string = string
local ipairs = ipairs
local pairs = pairs
local print = print
local table = table
local type = type
local math = math
local capi = {
	screen = screen,
	mouse = mouse,
	client = client
}
local screen = require("awful.screen")

local menu = { mt = {} }

local table_update = function (t, set)
	for k, v in pairs(set) do
		t[k] = v
	end
	return t
end

--- The icon used for sub-menus.
-- @beautiful beautiful.menu_submenu_icon
-- @tparam string|gears.surface menu_submenu_icon

--- The menu text font.
-- @beautiful beautiful.menu_font
-- @param string
-- @see string

--- The item height.
-- @beautiful beautiful.menu_height
-- @tparam[opt=16] number menu_height

--- The default menu width.
-- @beautiful beautiful.menu_width
-- @tparam[opt=100] number menu_width

--- The menu item border color.
-- @beautiful beautiful.menu_border_color
-- @tparam[opt=0] number menu_border_color

--- The menu item border width.
-- @beautiful beautiful.menu_border_width
-- @tparam[opt=0] number menu_border_width

--- The default focused item foreground (text) color.
-- @beautiful beautiful.menu_fg_focus
-- @param color
-- @see gears.color

--- The default focused item background color.
-- @beautiful beautiful.menu_bg_focus
-- @param color
-- @see gears.color

--- The default foreground (text) color.
-- @beautiful beautiful.menu_fg_normal
-- @param color
-- @see gears.color

--- The default background color.
-- @beautiful beautiful.menu_bg_normal
-- @param color
-- @see gears.color

--- The default sub-menu indicator if no `menu_submenu_icon` is provided.
-- @beautiful beautiful.menu_submenu
-- @tparam[opt="▶"] string menu_submenu The sub-menu text.
-- @see beautiful.menu_submenu_icon

--- Key bindings for menu navigation.
-- Keys are: up, down, exec, enter, back, close. Value are table with a list of valid
-- keys for the action, i.e. menu_keys.up =  { "j", "k" } will bind 'j' and 'k'
-- key to up action. This is common to all created menu.
-- @class table
-- @name menu_keys
menu.menu_keys = {
	up = { "Up", "k" },
	down = { "Down", "j" },
	back = { "Left", "h" },
	exec = { "Return" },
	enter = { "Right", "l", "KP_Enter" },
	close = { "Escape" }
}

local function load_theme(a, b)
	a = a or {}
	b = b or {}
	local ret = {}
	local fallback = beautiful.get()

	if a.reset then b = fallback end
	if a == "reset" then a = fallback end

	ret.border = a.border_color or b.menu_border_color or b.border_color_normal or
		fallback.menu_border_color or fallback.border_color_normal
	ret.border_width= a.border_width or b.menu_border_width or b.border_width or
		fallback.menu_border_width or fallback.border_width or dpi(0)
	ret.fg_focus = a.fg_focus or b.menu_fg_focus or b.fg_focus or
		fallback.menu_fg_focus or fallback.fg_focus
	ret.bg_focus = a.bg_focus or b.menu_bg_focus or b.bg_focus or
		fallback.menu_bg_focus or fallback.bg_focus
	ret.fg_normal = a.fg_normal or b.menu_fg_normal or b.fg_normal or
		fallback.menu_fg_normal or fallback.fg_normal
	ret.bg_normal = a.bg_normal or b.menu_bg_normal or b.bg_normal or
		fallback.menu_bg_normal or fallback.bg_normal
	ret.submenu_icon= a.submenu_icon or b.menu_submenu_icon or b.submenu_icon or
		fallback.menu_submenu_icon or fallback.submenu_icon
	ret.submenu = a.submenu or b.menu_submenu or b.submenu or
		fallback.menu_submenu or fallback.submenu or "▶"
	ret.height = a.height or b.menu_height or b.height or
		fallback.menu_height or dpi(16)
	ret.width = a.width or b.menu_width or b.width or
		fallback.menu_width or dpi(100)
	ret.font = a.font or b.font or fallback.menu_font or fallback.font
	ret.shape = a.shape or b.menu_shape or b.shape or
		fallback.menu_shape or fallback.shape

	for _, prop in ipairs({"width", "height", "menu_width"}) do
		if type(ret[prop]) ~= "number" then
			ret[prop] = tonumber(ret[prop])
		end
	end

	return ret
end


local function item_position(self, child)
	local a, b = "height", "width"
	local dir = self.layout.dir or "y"
	if dir == "x" then  a, b = b, a  end

	local in_dir, other = 0, self[b]
	local num = gtable.hasitem(self.child, child)

	if num then
		for i = 0, num - 1 do
			local item = self.items[i]
			if item then
				other = math.max(other, item[b])
				in_dir = in_dir + item[a]
			end
		end
	end

	local w, h = other, in_dir
	if dir == "x" then  w, h = h, w  end

	return w, h
end


local function set_coords(self, s, m_coords)
	local s_geometry = s.workarea
	local screen_w = s_geometry.x + s_geometry.width
	local screen_h = s_geometry.y + s_geometry.height

	self.width = self.wibox.width
	self.height = self.wibox.height

	self.x = self.wibox.x
	self.y = self.wibox.y

	if self.parent then
		local w, h = item_position(self.parent, self)
		w = w + self.parent.theme.border_width

		self.y = self.parent.y + h + self.height > screen_h and
				 screen_h - self.height or self.parent.y + h
		self.x = self.parent.x + w + self.width > screen_w and
				 self.parent.x - self.width or self.parent.x + w
	else
		if m_coords == nil then
			m_coords = capi.mouse.coords()
			m_coords.x = m_coords.x + 1
			m_coords.y = m_coords.y + 1
		end
		self.y = m_coords.y < s_geometry.y and s_geometry.y or m_coords.y
		self.x = m_coords.x < s_geometry.x and s_geometry.x or m_coords.x

		self.y = self.y + self.height > screen_h and
				 screen_h - self.height or self.y
		self.x = self.x + self.width  > screen_w and
				 screen_w - self.width  or self.x
	end

	self.wibox.x = self.x
	self.wibox.y = self.y
end


local function set_size(self)
	local in_dir, other, a, b = 0, 0, "height", "width"
	local dir = self.layout.dir or "y"
	if dir == "x" then  a, b = b, a  end

	for _, item in ipairs(self.items) do
		other = math.max(other, item[b])
		in_dir = in_dir + item[a]
	end

	self[a], self[b] = in_dir, other
	if in_dir > 0 and other > 0 then
		self.wibox[a] = in_dir
		self.wibox[b] = other
		return true
	end

	return false
end

local function check_access_key(self, key)
	for i, item in ipairs(self.items) do
		if item.akey == key then
			self:item_enter(i)
			self:exec(i, { exec = true })
			return
		end
	end

	if self.parent then
		check_access_key(self.parent, key)
	end
end

local function grabber(self, _, key, event)
	if event ~= "press" then return end
	local sel = self.sel or 0

	if gtable.hasitem(menu.menu_keys.up, key) then
		local sel_new = sel-1 < 1 and #self.items or sel-1
		self:item_enter(sel_new)
	elseif gtable.hasitem(menu.menu_keys.down, key) then
		local sel_new = sel+1 > #self.items and 1 or sel+1
		self:item_enter(sel_new)
	elseif sel > 0 and gtable.hasitem(menu.menu_keys.enter, key) then
		self:exec(sel)
	elseif sel > 0 and gtable.hasitem(menu.menu_keys.exec, key) then
		self:exec(sel, { exec = true })
	elseif gtable.hasitem(menu.menu_keys.back, key) then
		self:hide()
	elseif gtable.hasitem(menu.menu_keys.close, key) then
		menu.get_root(self):hide()
	else
		check_access_key(self, key)
	end
end

function menu:exec(num, opts)
	opts = opts or {}
	local item = self.items[num]
	if not item then return end
	local cmd = item.cmd

	if type(cmd) == "table" then
		local action = cmd.cmd

		if #cmd == 0 then
			if opts.exec and action and type(action) == "function" then
				action()
			end
			return
		end

		if not self.child[num] then
			self.child[num] = menu.new(cmd, self)
		end

		local can_invoke_action = opts.exec and
			action and type(action) == "function" and
			(not opts.mouse or (opts.mouse and (self.auto_expand or
			(self.active_child == self.child[num] and
			self.active_child.wibox.visible))))

		if can_invoke_action then
			local visible = action(self.child[num], item)
			if not visible then
				menu.get_root(self):hide()
				return
			else
				self.child[num]:update()
			end
		end

		if self.active_child and self.active_child ~= self.child[num] then
			self.active_child:hide()
		end

		self.active_child = self.child[num]
		if not self.active_child.wibox.visible then
			self.active_child:show()
		end
	elseif type(cmd) == "string" then
		menu.get_root(self):hide()
		spawn(cmd)
	elseif type(cmd) == "function" then
		local visible, action = cmd(item, self)

		if not visible then
			menu.get_root(self):hide()
		else
			self:update()
			if self.items[num] then
				self:item_enter(num, opts)
			end
		end

		if action and type(action) == "function" then
			action()
		end
	end
end

function menu:item_enter(num, opts)
	opts = opts or {}
	local item = self.items[num]
	if num == nil or self.sel == num or not item then
		return
	elseif self.sel then
		self:item_leave(self.sel)
	end

	item._background:set_fg(item.theme.fg_focus)
	item._background:set_bg(item.theme.bg_focus)
	self.sel = num

	if self.auto_expand and opts.hover then
		if self.active_child then
			self.active_child:hide()
			self.active_child = nil
		end

		if type(item.cmd) == "table" then
			self:exec(num, opts)
		end
	end
end

function menu:item_leave(num)
	local item = self.items[num]
	if item then
		item._background:set_fg(item.theme.fg_normal)
		item._background:set_bg(item.theme.bg_normal)
	end
end

--- Show a menu.
-- @tparam[opt={}] table args The arguments
-- @tparam[opt=mouse.coords] table args.coords The menu position. A table with
--  `x` and `y` as keys and position (in pixels) as values.
-- @noreturn
-- @method show
function menu:show(args)
	args = args or {}
	local coords = args.coords or nil
	local s = capi.screen[screen.focused()]

	if not set_size(self) then return end
	set_coords(self, s, coords)

	keygrabber.run(self._keygrabber)
	self.wibox.visible = true
end

--- Hide a menu popup.
-- @method hide
-- @noreturn
function menu:hide()
	-- Remove items from screen
	for i = 1, #self.items do
		self:item_leave(i)
	end

	if self.active_child then
		self.active_child:hide()
		self.active_child = nil
	end

	self.sel = nil
	keygrabber.stop(self._keygrabber)
	self.wibox.visible = false
end

--- Toggle menu visibility.
-- @tparam table args The arguments.
-- @tparam[opt=mouse.coords] table args.coords The menu position. A table with
--  `x` and `y` as keys and position (in pixels) as values.
-- @noreturn
-- @method toggle
function menu:toggle(args)
	if self.wibox.visible then
		self:hide()
	else
		self:show(args)
	end
end

--- Update menu content.
-- @method update
-- @noreturn
function menu:update()
	if self.wibox.visible then
		self:show({ coords = { x = self.x, y = self.y } })
	end
end

--- Get the elder parent so for example when you kill
-- it, it will destroy the whole family.
-- @method get_root
-- @treturn awful.menu The root menu.
function menu:get_root()
	return self.parent and menu.get_root(self.parent) or self
end

--- Add a new menu entry.
-- args.* params needed for the menu entry constructor.
-- @tparam table args The item params.
-- @tparam[opt=awful.menu.entry] function args.new The menu entry constructor.
-- @tparam[opt] table args.theme The menu entry theme.
-- @tparam[opt] number index The index where the new entry will inserted.
-- @treturn table|nil The new item.
-- @method add
function menu:add(args, index)
	if not args then return end
	local theme = load_theme(args.theme or {}, self.theme)
	args.theme = theme
	args.new = args.new or menu.entry

	local item = protected_call(args.new, self, args)
	if (not item) or (not item.widget) then
		print("Error while checking menu entry: no property widget found.")
		return
	end

	item.parent = self
	item.theme = item.theme or theme
	item.width = item.width or theme.width
	item.height = item.height or theme.height

	wibox.widget.base.check_widget(item.widget)

	item._background = wibox.container.background()
	item._background:set_widget(item.widget)
	item._background:set_fg(item.theme.fg_normal)
	item._background:set_bg(item.theme.bg_normal)

	-- Create bindings
	item._background.buttons = {
		button({}, 3, function () self:hide() end),
		button({}, 1, function ()
			local num = gtable.hasitem(self.items, item)
			self:item_enter(num, { mouse = true })
			self:exec(num, { exec = true, mouse = true })
		end)
	}

	item._mouse = function ()
		local num = gtable.hasitem(self.items, item)
		self:item_enter(num, { hover = true, mouse = true })
	end
	item.widget:connect_signal("mouse::enter", item._mouse)

	if index then
		self.layout:reset()
		table.insert(self.items, index, item)
		for _, i in ipairs(self.items) do
			self.layout:add(i._background)
		end
	else
		table.insert(self.items, item)
		self.layout:add(item._background)
	end

	if self.wibox then
		set_size(self)
	end

	return item
end

--- Delete menu entry at given position.
-- @tparam table|number num The index in the table of the menu entry to be deleted; can be also the menu entry itself.
-- @noreturn
-- @method delete
function menu:delete(num)
	if type(num) == "table" then
		num = gtable.hasitem(self.items, num)
	end

	local item = self.items[num]
	if not item then return end

	item.widget:disconnect_signal("mouse::enter", item._mouse)
	item.widget:set_visible(false)
	table.remove(self.items, num)

	if self.sel == num then
		self:item_leave(self.sel)
		self.sel = nil
	end

	self.layout:reset()

	for _, i in ipairs(self.items) do
		self.layout:add(i._background)
	end

	if self.child[num] then
		 self.child[num]:hide()
		if self.active_child == self.child[num] then
			self.active_child = nil
		end
		table.remove(self.child, num)
	end

	if self.wibox then
		set_size(self)
	end
end

--- Default awful.menu.entry constructor.
-- @param parent The parent menu (TODO: This is apparently unused)
-- @param args The item params
-- @return table With 'widget', 'cmd', 'akey' and all the properties the user wants to change
-- @constructorfct awful.menu.entry
function menu.entry(parent, args) -- luacheck: no unused args
	args = args or {}
	args.text = args[1] or args.text or ""
	args.cmd = args[2] or args.cmd
	args.icon = args[3] or args.icon
	local ret = {}

	-- Create the item label widget
	local label = wibox.widget.textbox()
	local key = ''
	label:set_font(args.theme.font)
	label:set_markup(string.gsub(
		gstring.xml_escape(args.text), "&amp;(%w)",
		function (l)
			key = string.lower(l)
			return "<u>" .. l .. "</u>"
		end, 1))

	-- Set icon if needed
	local icon, iconbox
	local margin = wibox.container.margin()
	margin:set_widget(label)

	if args.icon then
		icon = surface.load(args.icon)
	end

	if icon then
		local iw = icon:get_width()
		local ih = icon:get_height()

		if iw > args.theme.width or ih > args.theme.height then
			local w, h

			if ((args.theme.height / ih) * iw) > args.theme.width then
				w, h = args.theme.height, (args.theme.height / iw) * ih
			else
				w, h = (args.theme.height / ih) * iw, args.theme.height
			end

			-- We need to scale the image to size w x h
			local img = cairo.ImageSurface(cairo.Format.ARGB32, w, h)
			local cr = cairo.Context(img)
			cr:scale(w / iw, h / ih)
			cr:set_source_surface(icon, 0, 0)
			cr:paint()
			icon = img
		end

		iconbox = wibox.widget.imagebox()
		if iconbox:set_image(icon) then
			margin:set_left(dpi(2))
		else
			iconbox = nil
		end
	end

	if not iconbox then
		margin:set_left(args.theme.height + dpi(2))
	end

	-- Create the submenu icon widget
	local submenu
	if type(args.cmd) == "table" then
		if args.theme.submenu_icon then
			submenu = wibox.widget.imagebox()
			submenu:set_image(args.theme.submenu_icon)
		else
			submenu = wibox.widget.textbox()
			submenu:set_font(args.theme.font)
			submenu:set_text(args.theme.submenu)
		end
	end

	-- Add widgets to the wibox
	local left = wibox.layout.fixed.horizontal()
	if iconbox then
		left:add(iconbox)
	end

	-- This contains the label
	left:add(margin)

	local layout = wibox.layout.align.horizontal()
	layout:set_left(left)
	if submenu then
		layout:set_right(submenu)
	end

	return table_update(ret, {
		label = label,
		sep = submenu,
		icon = iconbox,
		widget = layout,
		cmd = args.cmd,
		akey = key,
	})
end

--- Create a menu popup.
--
-- @tparam table args Table containing the menu information.
-- @tparam[opt=true] boolean args.auto_expand Controls the submenu auto expand behaviour.
-- @tparam table args.items Table containing the displayed items. Each element is a
--   table by default (when element 'new' is awful.menu.entry) containing: item
--   name, triggered action (submenu table or function), item icon (optional).
-- @tparam table args.theme
-- @tparam[opt=beautiful.menu_fg_normal] color args.theme.fg_normal
-- @tparam[opt=beautiful.menu_bg_normal] color args.theme.bg_normal
-- @tparam[opt=beautiful.menu_fg_focus] color args.theme.fg_focus
-- @tparam[opt=beautiful.menu_bg_focus] color args.theme.bg_focus
-- @tparam[opt=beautiful.menu_border_color] color args.theme.border
-- @tparam[opt=beautiful.menu_border_width] integer args.theme.border_width
-- @tparam[opt=beautiful.menu_height] integer args.theme.height
-- @tparam[opt=beautiful.menu_width] integer args.theme.width
-- @tparam[opt=beautiful.menu_font] string args.theme.font
-- @tparam[opt=beautiful.menu_submenu_icon] gears.surface|string args.theme.submenu_icon
-- @tparam[opt=beautiful.menu_submenu] string args.theme.submenu
-- @param parent Specify the parent menu if we want to open a submenu, this value should never be set by the user.
-- @constructorfct awful.menu
-- @usage -- The following function builds and shows a menu of clients that match
-- -- a particular rule.
-- -- Bound to a key, it can be used to select from dozens of terminals open on
-- -- several tags.
-- -- When using @{ruled.client.match_any} instead of @{ruled.client.match},
-- -- a menu of clients with different classes could be built.
--
-- function terminal_menu ()
--   terms = {}
--   for i, c in pairs(client.get()) do
--	 if ruled.client.match(c, {class = "URxvt"}) then
--	   terms[i] =
--		 {c.name,
--		  function()
--			c.first_tag:view_only()
--			client.focus = c
--		  end,
--		  c.icon
--		 }
--	 end
--   end
--   awful.menu(terms):show()
-- end
function menu.new(args, parent)
	args = args or {}
	args.layout = args.layout or wibox.layout.flex.vertical

	local _menu = table_update(object(), {
		item_enter = menu.item_enter,
		item_leave = menu.item_leave,
		get_root = menu.get_root,
		delete = menu.delete,
		update = menu.update,
		toggle = menu.toggle,
		hide = menu.hide,
		show = menu.show,
		exec = menu.exec,
		add = menu.add,
		child = {},
		items = {},
		parent = parent,
		layout = args.layout(),
		theme = load_theme(args.theme or {}, parent and parent.theme)
	})

	if parent then
		_menu.auto_expand = parent.auto_expand
	elseif args.auto_expand ~= nil then
		_menu.auto_expand = args.auto_expand
	else
		_menu.auto_expand = true
	end

	-- Create items
	for _, v in ipairs(args) do
		_menu:add(v)
	end

	if args.items then
		for _, v in pairs(args.items) do
			_menu:add(v)
		end
	end

	_menu._keygrabber = function (...)
		grabber(_menu, ...)
	end

	_menu.wibox = wibox {
		ontop = true,
		fg = _menu.theme.fg_normal,
		bg = _menu.theme.bg_normal,
		border_color = _menu.theme.border,
		border_width = _menu.theme.border_width,
		shape = _menu.theme.shape,
		type = "popup_menu"
	}

	_menu.wibox.visible = false
	_menu.wibox:set_widget(_menu.layout)
	set_size(_menu)

	_menu.x = _menu.wibox.x
	_menu.y = _menu.wibox.y

	return _menu
end

function menu.mt:__call(...)
	return menu.new(...)
end

return setmetatable(menu, menu.mt)
