-- Backdrop component for popup windows
-- Creates a semi-transparent overlay with blur effect using surface_filters

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local backdrop = {}

-- Try to load surface_filters for blur effect
local has_surface_filters, surface_filters = pcall(function()
	return require("lib.surface_filters")
end)

-- Backdrop instance tracking (per screen)
local backdrop_wiboxes = {}
local backdrop_visible = false
local associated_popup = nil

-- Configuration
local backdrop_color_base = beautiful.backdrop_color or "#000000"
local backdrop_opacity = beautiful.backdrop_opacity or 0.4
local backdrop_blur_radius = beautiful.backdrop_blur_radius or 8
local backdrop_blur_enabled = beautiful.backdrop_blur_enabled ~= false
local backdrop_dual_pass = beautiful.backdrop_dual_pass ~= false

-- Convert opacity (0-1) to hex alpha (00-FF)
local function opacity_to_hex(opacity)
	local alpha = math.floor(opacity * 255 + 0.5)
	return string.format("%02x", math.min(255, math.max(0, alpha)))
end

-- Combine base color with opacity for 8-character hex
local backdrop_color = backdrop_color_base .. opacity_to_hex(backdrop_opacity)

-- Create backdrop wibox for a specific screen
local function create_backdrop_for_screen(s)
	if backdrop_wiboxes[s] then
		return backdrop_wiboxes[s]
	end

	local bw = wibox({
		visible = false,
		ontop = true,
		type = "dock",
		bg = backdrop_color,
		input_passthrough = false,
		screen = s,
	})

	-- Position and size
	bw.x = s.geometry.x
	bw.y = s.geometry.y
	bw.width = s.geometry.width
	bw.height = s.geometry.height

	backdrop_wiboxes[s] = bw
	return bw
end

-- Show backdrop for a popup
function backdrop.show(popup, options)
	options = options or {}

	if backdrop_visible and associated_popup == popup then
		return
	end

	backdrop.hide()

	-- Create backdrop for all screens
	for s in screen do
		local bw = create_backdrop_for_screen(s)
		bw.visible = true
	end

	associated_popup = popup
	backdrop_visible = true
end

-- Hide backdrop
function backdrop.hide()
	if not backdrop_visible then
		return
	end

	backdrop_visible = false
	associated_popup = nil

	for s, bw in pairs(backdrop_wiboxes) do
		if bw then
			bw.visible = false
		end
	end
end

-- Check if backdrop is visible
function backdrop.is_visible()
	return backdrop_visible
end

-- Get the associated popup
function backdrop.get_popup()
	return associated_popup
end

-- Update backdrop properties
function backdrop.update_properties(properties)
	if properties.color or properties.opacity then
		local color = properties.color or backdrop_color_base
		local opacity = properties.opacity or backdrop_opacity
		local new_color = color .. opacity_to_hex(opacity)

		for s, bw in pairs(backdrop_wiboxes) do
			if bw then
				bw.bg = new_color
			end
		end
	end

	if properties.blur_radius then
		backdrop_blur_radius = properties.blur_radius
	end
end

-- Enable/disable blur (for future use when blur is properly implemented)
function backdrop.set_blur_enabled(enabled)
	backdrop_blur_enabled = enabled
end

-- Clean up backdrop
function backdrop.cleanup()
	for s, bw in pairs(backdrop_wiboxes) do
		if bw then
			bw.visible = false
			backdrop_wiboxes[s] = nil
		end
	end
	backdrop_visible = false
	associated_popup = nil
end

return backdrop
