
return function (widget)
	--local oldcursor, oldwibox, oldbg
	local oldcursor, oldwibox
	widget:connect_signal("mouse::enter", function()
		local wb = mouse.current_wibox
		if wb == nil then return end
		--oldcursor, oldwibox, oldbg = wb.cursor, wb, wb.bg
		oldcursor, oldwibox = wb.cursor, wb
		wb.cursor = "hand2"
		--widget.bg = beautiful.fg .. "20"
	end)
	widget:connect_signal("mouse::leave", function()
		if oldwibox then
			oldwibox.cursor = oldcursor
			--widget.bg = oldbg
			oldwibox = nil
		end
	end)
	return widget
end
