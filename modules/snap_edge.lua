--  _______                         _______     __
-- |     __|.-----.---.-.-----.    |    ___|.--|  |.-----.-----.
-- |__     ||     |  _  |  _  |    |    ___||  _  ||  _  |  -__|
-- |_______||__|__|___._|   __|    |_______||_____||___  |_____|
--                      |__|                       |_____|
-- -------------------------------------------------------------------------- --
-- originally from https://www.reddit.com/r/awesomewm/comments/kw1kr7/awesomewm_question_snap_to_leftright/
-- -------------------------------------------------------------------------- --
-- where can be 'left' 'right' 'top' 'bottom' 'center' 'topleft' 'topright' 'bottomleft' 'bottomright' nil
--
return function(c, where, geom)
	local sg = screen[c.screen].geometry --screen geometry
	local sw = screen[c.screen].workarea --screen workarea
	local workarea = { x_min = sw.x, x_max = sw.x + sw.width, y_min = sw.y, y_max = sw.y + sw.height }
	local cg = geom or c:geometry()
	local border = c.border_width
	local cs = c:struts()
	cs["left"] = 0
	cs["top"] = 0
	cs["bottom"] = 0
	cs["right"] = 0
	if where ~= nil then
		c:struts(cs) -- cancel struts when snapping to edge
	end
	if where == "right" then
		cg.width = sw.width / 2 - 2 * border
		cg.height = sw.height
		cg.x = workarea.x_max - cg.width
		cg.y = workarea.y_min
	elseif where == "left" then
		cg.width = sw.width / 2 - 2 * border
		cg.height = sw.height
		cg.x = workarea.x_min
		cg.y = workarea.y_min
	elseif where == "bottom" then
		cg.width = sw.width
		cg.height = sw.height / 2 - 2 * border
		cg.x = workarea.x_min
		cg.y = workarea.y_max - cg.height
		awful.placement.center_horizontal(c)
	elseif where == "top" then
		cg.width = sw.width
		cg.height = sw.height / 2 - 2 * border
		cg.x = workarea.x_min
		cg.y = workarea.y_min
		awful.placement.center_horizontal(c)
	elseif where == "topright" then
		cg.width = sw.width / 2 - 2 * border
		cg.height = sw.height / 2 - 2 * border
		cg.x = workarea.x_max - cg.width
		cg.y = workarea.y_min
	elseif where == "topleft" then
		cg.width = sw.width / 2 - 2 * border
		cg.height = sw.height / 2 - 2 * border
		cg.x = workarea.x_min
		cg.y = workarea.y_min
	elseif where == "bottomright" then
		cg.width = sw.width / 2 - 2 * border
		cg.height = sw.height / 2 - 2 * border
		cg.x = workarea.x_max - cg.width
		cg.y = workarea.y_max - cg.height
	elseif where == "bottomleft" then
		cg.width = sw.width / 2 - 2 * border
		cg.height = sw.height / 2 - 2 * border
		cg.x = workarea.x_min
		cg.y = workarea.y_max - cg.height
	elseif where == "center" then
		awful.placement.centered(c)
		return
	elseif where == nil then
		c:struts(cs)
		c:geometry(cg)
		return
	end
	c.floating = true
	if c.maximized then c.maximized = false end
	c:geometry(cg)
	awful.placement.no_offscreen(c)
	return
end
