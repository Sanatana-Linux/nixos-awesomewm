---@diagnostic disable: undefined-global
---------------------------------------------------------------------------
--- Display the current client layout (`awful.layout`) icon or name.
--
-- @DOC_awful_widget_layoutbox_default_EXAMPLE@
--
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @widgetmod awful.widget.layoutbox
-- @supermodule wibox.layout.fixed
---------------------------------------------------------------------------

local setmetatable = setmetatable
local capi = { screen = screen, tag = tag }
local layout = require("awful.layout")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gdebug = require("gears.debug")
local gtable = require("gears.table")

local function get_screen(s)
	return s and capi.screen[s]
end

local layoutbox = { mt = {} }

local boxes = nil

local function update(w, screen)
	screen = get_screen(screen)
	local name = layout.getname(layout.get(screen))
	local image_name = "layout_" .. name
	local theme_image = beautiful[image_name]
	local success = false
	if theme_image ~= nil then
		success = w.imagebox:set_image(beautiful[image_name])
	end
	w.textbox.text = success and "" or name
end

local function update_from_tag(t)
	local screen = get_screen(t.screen)
	local w = boxes and boxes[screen]
	if w then
		update(w, screen)
	end
end

--- Create a layoutbox widget. It draws a picture with the current layout
-- symbol of the current tag.
-- @constructorfct awful.widget.layoutbox
-- @tparam table args The arguments.
-- @tparam screen args.screen The screen number that the layout will be represented for.
-- @tparam table args.buttons The `awful.button`s for this layoutbox.
-- @return The layoutbox.
function layoutbox.new(args)
	args = args or {}
	local screen = args.screen

	if type(args) == "number" or type(args) == "screen" or args.fake_remove then
		screen, args = args, {}

		gdebug.deprecate(
			"Use awful.widget.layoutbox{screen=s} instead of awful.widget.layoutbox(screen)",
			{deprecated_in=5}
		)
	end

	assert(type(args) == "table")

	screen = get_screen(screen or 1)

	-- Do we already have the update callbacks registered?
	if boxes == nil then
		boxes = setmetatable({}, { __mode = "kv" })
		capi.tag.connect_signal("property::selected", update_from_tag)
		capi.tag.connect_signal("property::layout", update_from_tag)
		capi.tag.connect_signal("property::screen", function()
			for s, w in pairs(boxes) do
				if s.valid then
					update(w, s)
				end
			end
		end)
		layoutbox.boxes = boxes
	end

	-- Do we already have a layoutbox for this screen?
	local w = boxes[screen]
	if not w then
		w = wibox.widget {
			{
				id	 = "imagebox",
				widget = wibox.widget.imagebox
			},
			{
				id	 = "textbox",
				widget = wibox.widget.textbox
			},
			layout = wibox.layout.fixed.horizontal
		}

		-- Apply the buttons, visible, forced_width and so on
		gtable.crush(w, args)

		update(w, screen)
		boxes[screen] = w
	end

	return w
end

function layoutbox.mt:__call(...)
	return layoutbox.new(...)
end

return setmetatable(layoutbox, layoutbox.mt)
