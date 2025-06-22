-- This module provides a reusable text input widget for AwesomeWM.
-- It handles text entry, cursor movement, selection, and clipboard operations.
-- Text handling and key event processing now use standard Lua 5.1 string
-- functions, operating on bytes rather than UTF-8 characters.
-- It provides hooks for various events (input changed, executed, focused, etc.).

local lgi = require("lgi")
-- local Gtk = lgi.require("Gtk", "3.0")
-- local Gdk = lgi.require("Gdk", "3.0")
local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local gstring = require("gears.string") -- Used for xml_escape
local gcolor = require("gears.color")
local beautiful = require("beautiful")

local text_input = {}

-- Creates the pango markup for the text input, including the cursor and placeholder.
-- Operations are byte-based.
-- @param args A table containing:
--   - text (string): The current input text.
--   - cursor_pos (number): The current byte position of the cursor (1-based).
--   - selectall (boolean): Whether all text is selected.
--   - placeholder (string): The placeholder text to show when input is empty.
--   - obscure (boolean): Whether to obscure the text (e.g., for passwords).
--   - obscure_char (string): The character to use for obscuring.
--   - highlighter (function, optional): A function to apply custom markup to text.
--   - cursor_bg (string): Background color for the cursor.
--   - cursor_fg (string): Foreground color for the cursor.
--   - placeholder_fg (string): Foreground color for the placeholder text.
-- @return string The pango markup string.
local function create_markup(args)
	local text = args.text or ""
	local cursor_pos = args.cursor_pos or 1
	local selectall = args.selectall or false
	local placeholder = args.placeholder or ""
	local obscure = args.obscure or false
	local obscure_char = args.obscure_char or "*"
	local highlighter = args.highlighter or nil
	local cursor_char_display, spacer, text_start_display, text_end_display, markup -- Renamed to avoid confusion with actual char

	local display_text = text
	if obscure and text ~= "" then
		-- Create a string of obscure_char with the same byte length as original text
		-- This might not be visually one-to-one if obscure_char is multi-byte
		-- and original text contains multi-byte chars, but matches the obscure intent.
		-- A common approach is to count characters if possible, but we're byte-based here.
		-- For simplicity, we'll use #text which is byte length.
		display_text = string.rep(obscure_char, #text)
	end

	local display_len = #display_text -- Byte length
	local placeholder_len = #placeholder -- Byte length

	if display_len == 0 and placeholder ~= "" then
		-- Show placeholder
		text_start_display = ""
		-- Cursor is effectively before the first char of placeholder
		-- Display the first byte/char of placeholder highlighted as cursor
		cursor_char_display = gstring.xml_escape(string.sub(placeholder, 1, 1) or " ") -- Highlight first byte or a space
		text_end_display = gstring.xml_escape(string.sub(placeholder, 2) or "") -- Rest of placeholder
		spacer = ""
	elseif selectall then
		-- Highlight the entire text or a space if empty
		text_start_display = ""
		cursor_char_display = display_text == "" and " " or gstring.xml_escape(display_text)
		text_end_display = ""
		spacer = " " -- Spacer ensures highlight is visible even if text is empty
	elseif cursor_pos > display_len then
		-- Cursor is at the very end of the text (after last byte)
		text_start_display = gstring.xml_escape(display_text)
		cursor_char_display = " " -- Cursor is a space after the text
		text_end_display = ""
		spacer = ""
	else
		-- Cursor is within or at the start of the text
		text_start_display = gstring.xml_escape(string.sub(display_text, 1, cursor_pos - 1) or "")
		cursor_char_display = gstring.xml_escape(string.sub(display_text, cursor_pos, cursor_pos) or " ") -- Highlight the byte AT the cursor position
		text_end_display = gstring.xml_escape(string.sub(display_text, cursor_pos + 1) or "") -- Rest of the text after the cursor byte
		spacer = " "
	end

	local cursor_bg_pango = gcolor.ensure_pango_color(args.cursor_bg)
	local cursor_fg_pango = gcolor.ensure_pango_color(args.cursor_fg)
	local placeholder_fg_pango = gcolor.ensure_pango_color(args.placeholder_fg)

	-- Apply custom highlighting if provided
	if text ~= "" and highlighter then
		text_start_display, text_end_display = highlighter(text_start_display, text_end_display)
	end

	-- Build the final markup string
	markup = text_start_display
		.. "<span foreground='"
		.. cursor_fg_pango
		.. "' background='"
		.. cursor_bg_pango
		.. "'>"
		.. cursor_char_display
		.. "</span>"
		.. (display_len == 0 and placeholder ~= "" and "<span foreground='" .. placeholder_fg_pango .. "'>" .. text_end_display .. "</span>" or text_end_display)
		.. spacer

	return markup
end

-- Checks if a key is in the exclusion list (non-printable/control keys).
-- Adapted from the provided launcher snippet.
-- @param key string The name of the key.
-- @return boolean True if the key should be excluded from text input.
local function is_excluded_key(key)
	local exclude = {
		"Shift_R",
		"Shift_L",
		"Super_R",
		"Super_L",
		"Tab",
		"Alt_R",
		"Alt_L",
		"Control_L",
		"Control_R",
		"Caps_Lock",
		"Num_Lock",
		"Home",
		"End",
		"Left",
		"Right",
		"Up",
		"Down",
		"Prior",
		"Next",
		"Delete",
		"BackSpace",
		"Return",
		"KP_Enter",
		"Escape",
		"F1",
		"F2",
		"F3",
		"F4",
		"F5",
		"F6",
		"F7",
		"F8",
		"F9",
		"F10",
		"F11",
		"F12",
		"Print",
		"Scroll_Lock",
		"Pause",
		"Insert",
	}
	for _, excluded_key in ipairs(exclude) do
		if key == excluded_key then
			return true
		end
	end
	return false
end

-- Starts the keygrabber to capture keyboard input for the text_input widget.
-- Handles various key presses for text manipulation, navigation, and control.
-- Operations are byte-based.
-- @param self The text_input widget instance.
local function run_keygrabber(self)
	local wp = self._private
	wp.keygrabber = awful.keygrabber.run(function(mods, key, event)
		if event ~= "press" then
			if wp.on_key_released then
				wp.on_key_released(self, mods, key)
			end
			return
		end

		if wp.on_key_pressed then
			wp.on_key_pressed(self, mods, key)
		end

		local input_len = #wp.input -- Byte length
		local current_input = wp.input
		local new_cursor_index = wp.cursor_index -- Byte index
		local input_changed = false

		if key == "Escape" then
			wp.selectall = false
			self:unfocus()
			return
		elseif key == "Return" or key == "KP_Enter" then
			wp.selectall = false
			local input_to_execute = wp.input
			if wp.on_executed then
				wp.on_executed(self, input_to_execute)
			end
			self:unfocus()
			return
		elseif key == "BackSpace" then
			if wp.selectall then
				current_input = ""
				new_cursor_index = 1
				wp.selectall = false
				input_changed = true
			elseif wp.cursor_index > 1 then
				-- Delete byte before cursor
				current_input = string.sub(current_input, 1, wp.cursor_index - 2)
					.. string.sub(current_input, wp.cursor_index)
				new_cursor_index = wp.cursor_index - 1
				input_changed = true
			end
		elseif key == "Delete" then
			if wp.selectall then
				current_input = ""
				new_cursor_index = 1
				wp.selectall = false
				input_changed = true
			elseif wp.cursor_index <= input_len then
				-- Delete byte at cursor
				current_input = string.sub(current_input, 1, wp.cursor_index - 1)
					.. string.sub(current_input, wp.cursor_index + 1)
				input_changed = true
			end
		elseif key == "Left" then
			wp.selectall = false
			if wp.cursor_index > 1 then
				new_cursor_index = wp.cursor_index - 1
			end
		elseif key == "Right" then
			if wp.selectall then
				wp.selectall = false
				new_cursor_index = input_len + 1 -- Move to end after deselecting
			elseif wp.cursor_index <= input_len then
				new_cursor_index = wp.cursor_index + 1
			end
		elseif key == "Home" then
			wp.selectall = false
			new_cursor_index = 1
		elseif key == "End" then
			wp.selectall = false
			new_cursor_index = input_len + 1
		elseif mods.Control and key == "a" then -- Ctrl+A: Select All
			if input_len > 0 then
				wp.selectall = true
				new_cursor_index = 1
			end
		elseif mods.Control and key == "c" then -- Ctrl+C: Copy
			if wp.selectall then
				wp.clipboard:set_text(wp.input, -1)
			end

		-- elseif mods.Control and key == "x" then -- Ctrl+X: Cut
		--     if wp.selectall then
		--         wp.clipboard:set_text(wp.input, -1)
		--         current_input = ""
		--         new_cursor_index = 1
		--         wp.selectall = false
		--         input_changed = true
		--     end
		elseif mods.Control and key == "v" then -- Ctrl+V: Paste
			wp.clipboard:request_text(function(_, text_to_paste)
				if text_to_paste then
					local paste_len = #text_to_paste -- Byte length
					if wp.selectall then
						wp.input = text_to_paste
						new_cursor_index = paste_len + 1
						wp.selectall = false
					else
						wp.input = (string.sub(wp.input, 1, wp.cursor_index - 1) or "")
							.. text_to_paste
							.. (string.sub(wp.input, wp.cursor_index) or "")
						new_cursor_index = wp.cursor_index + paste_len
					end
					if wp.on_input_changed then
						wp.on_input_changed(self, wp.input)
					end
					wp.cursor_index = new_cursor_index
					self:update_textbox()
				end
			end)
			return
			-- Check if it's a single-byte key (heuristic) and not excluded
		elseif
			#key == 1
			and not mods.Control
			and not mods.Alt
			and not mods.Mod1
			and not mods.Mod4
			and not is_excluded_key(key)
		then
			local char_to_insert = key -- This is the raw key string, could be multi-byte if IME used
			local char_len = #char_to_insert -- Byte length of inserted key string

			if wp.selectall then
				current_input = char_to_insert
				new_cursor_index = char_len + 1
				wp.selectall = false
			else
				current_input = (string.sub(current_input, 1, wp.cursor_index - 1) or "")
					.. char_to_insert
					.. (string.sub(current_input, wp.cursor_index) or "")
				new_cursor_index = wp.cursor_index + char_len
			end
			input_changed = true
		else
			return
		end

		if input_changed then
			wp.input = current_input
			if wp.on_input_changed then
				wp.on_input_changed(self, wp.input)
			end
		end

		if new_cursor_index ~= wp.cursor_index then
			wp.cursor_index = new_cursor_index
		end

		self:update_textbox()
	end)
end

-- Updates the underlying textbox widget's markup based on the current state.
function text_input:update_textbox()
	local wp = self._private
	self:set_markup(create_markup({
		text = wp.input,
		cursor_pos = wp.cursor_index,
		selectall = wp.selectall,
		obscure = wp.obscure,
		cursor_bg = wp.cursor_bg,
		cursor_fg = wp.cursor_fg,
		placeholder_fg = wp.placeholder_fg,
		obscure_char = wp.obscure_char,
		placeholder = wp.placeholder,
		highlighter = wp.highlighter,
	}))
end

-- Checks if the text input is currently focused.
-- @return boolean True if focused, false otherwise.
function text_input:get_focused()
	return self._private.focused
end

-- Sets focus to the text input.
-- Starts the keygrabber and calls the on_focused callback if set.
function text_input:focus()
	local wp = self._private
	if wp.focused then
		return
	end
	wp.focused = true
	run_keygrabber(self)
	self:update_textbox()
	if wp.on_focused then
		wp.on_focused(self)
	end
end

-- Removes focus from the text input.
-- Stops the keygrabber and calls the on_unfocused callback if set.
function text_input:unfocus()
	local wp = self._private
	if not wp.focused then
		return
	end
	wp.focused = false
	if wp.keygrabber then
		awful.keygrabber.stop(wp.keygrabber)
		wp.keygrabber = nil
	end
	if wp.on_unfocused then
		wp.on_unfocused(self)
	end
end

-- Gets the current input string.
-- @return string The current input text.
function text_input:get_input()
	return self._private.input
end

-- Sets the input string and updates the textbox.
-- Also resets cursor (to end, byte-based) and selection.
-- @param input string The new text to set.
function text_input:set_input(input)
	local wp = self._private
	wp.input = input or ""
	local text_len = #wp.input -- Byte length
	wp.cursor_index = text_len + 1
	wp.selectall = false
	self:update_textbox()
end

-- Gets the current cursor (byte) position (1-based).
-- @return number The cursor position.
function text_input:get_cursor_index()
	return self._private.cursor_index
end

-- Sets the cursor (byte) position (1-based).
-- Clamps the index to be within the valid range (1 to byte_len+1).
-- @param index number The new cursor position.
function text_input:set_cursor_index(index)
	local wp = self._private
	local text_len = #wp.input -- Byte length
	wp.cursor_index = math.max(1, math.min(index, text_len + 1))
	self:update_textbox()
end

-- Checks if all text is selected.
-- @return boolean True if all text is selected.
function text_input:get_selectall()
	return self._private.selectall
end

-- Sets the "select all" state.
-- If setting to true, also sets cursor to the start.
-- @param selectall boolean Whether to select all text.
function text_input:set_selectall(selectall)
	local wp = self._private
	wp.selectall = selectall
	if selectall then
		wp.cursor_index = 1
	end
	self:update_textbox()
end

-- Checks if the input is obscured.
-- @return boolean True if obscured.
function text_input:get_obscure()
	return self._private.obscure
end

-- Sets the obscure state for the input (e.g., for passwords).
-- @param obscure boolean Whether to obscure the text.
function text_input:set_obscure(obscure)
	self._private.obscure = obscure
	self:update_textbox()
end

-- Sets a callback function to be called when the input gains focus.
-- @param callback function The callback function, receives `self` as argument.
function text_input:on_focused(callback)
	self._private.on_focused = callback
end

-- Sets a callback function to be called when the input loses focus.
-- @param callback function The callback function, receives `self` as argument.
function text_input:on_unfocused(callback)
	self._private.on_unfocused = callback
end

-- Sets a callback function to be called when the input text changes.
-- @param callback function The callback function, receives `self` and `new_input` as arguments.
function text_input:on_input_changed(callback)
	self._private.on_input_changed = callback
end

-- Sets a callback function to be called when the input is "executed" (e.g., Enter is pressed).
-- @param callback function The callback function, receives `self` and `current_input` as arguments.
function text_input:on_executed(callback)
	self._private.on_executed = callback
end

-- Sets a callback function to be called when a key is pressed while focused.
-- @param callback function The callback function, receives `self`, `modifiers_table`, and `key_name` as arguments.
function text_input:on_key_pressed(callback)
	self._private.on_key_pressed = callback
end

-- Sets a callback function to be called when a key is released while focused.
-- @param callback function The callback function, receives `self`, `modifiers_table`, and `key_name` as arguments.
function text_input:on_key_released(callback)
	self._private.on_key_released = callback
end

-- Constructor for a new text_input widget.
-- @param args A table of arguments to configure the text_input and underlying textbox:
--   - font (string, optional): Font for the text.
--   - halign, valign, wrap, justify, ellipsize (optional): Standard wibox.widget.textbox properties.
--   - obscure (boolean, optional): Initial obscure state. Defaults to false.
--   - placeholder (string, optional): Placeholder text. Defaults to "".
--   - obscure_char (string, optional): Character for obscuring. Defaults to "*".
--   - cursor_bg, cursor_fg, placeholder_fg (string, optional): Colors for cursor and placeholder.
--   - highlighter (function, optional): Custom markup highlighter function.
--   - on_focused, on_unfocused, on_input_changed, on_executed, on_key_pressed, on_key_released (function, optional): Callbacks.
-- @return widget The new text_input widget.
local function new(args)
	args = args or {}
	local ret = wibox.widget({
		widget = wibox.widget.textbox,
		font = args.font,
		halign = args.halign,
		valign = args.valign,
		wrap = args.wrap,
		justify = args.justify,
		ellipsize = args.ellipsize or "start",
	})

	gtable.crush(ret, text_input, true)
	local wp = ret._private

	wp.focused = false
	wp.input = ""
	wp.cursor_index = 1 -- Byte index
	wp.selectall = false
	-- wp.clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)

	wp.placeholder = args.placeholder or ""
	wp.obscure_char = args.obscure_char or "*"
	wp.obscure = args.obscure or false
	wp.cursor_bg = args.cursor_bg or beautiful.fg or "#ffffff"
	wp.cursor_fg = args.cursor_fg or beautiful.bg or "#000000"
	wp.placeholder_fg = args.placeholder_fg or beautiful.fg_alt or "#777777"
	wp.highlighter = args.highlighter

	wp.on_focused = args.on_focused
	wp.on_unfocused = args.on_unfocused
	wp.on_input_changed = args.on_input_changed
	wp.on_executed = args.on_executed
	wp.on_key_pressed = args.on_key_pressed
	wp.on_key_released = args.on_key_released

	ret:update_textbox()

	return ret
end

return setmetatable({
	new = new,
}, {
	__call = function(_, ...)
		return new(...)
	end,
})
