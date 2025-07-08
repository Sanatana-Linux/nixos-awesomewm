local Gio = require("lgi").require("Gio")
local awful = require("awful")
local naughty = require("naughty")
local screenshot = require("service.screenshot").get_default()

screenshot:connect_signal("saved", function(_, dir, name)
	local path = dir .. name
	local notification

	-- Define the actions
	local view_file = naughty.action { name = "View" }
	local open_dir = naughty.action { name = "Folder" }
	local copy = naughty.action { name = "Copy" }
	local annotate = naughty.action { name = "Annotate" }
	local delete = naughty.action { name = "Delete" }

	-- Connect signals to the actions
	view_file:connect_signal("invoked", function()
		local app = Gio.AppInfo.get_default_for_type("image/png")
		if app then awful.spawn(string.format("%s %s", app:get_executable(), path)) end
	end)

	open_dir:connect_signal("invoked", function()
		local app = Gio.AppInfo.get_default_for_type("inode/directory")
		if app then awful.spawn(string.format("%s %s", app:get_executable(), dir)) end
	end)

	copy:connect_signal("invoked", function()
		screenshot:copy_screenshot(path)
	end)

	annotate:connect_signal("invoked", function()
		screenshot:annotate(path)
		-- We can optionally dismiss the notification after starting annotation
		if notification then notification:destroy() end
	end)

	delete:connect_signal("invoked", function()
		screenshot:delete(path)
		-- Dismiss the notification once the file is deleted
		if notification then notification:destroy() end
	end)


	local display_dir = dir:gsub(tostring(os.getenv("HOME")), "~")

	notification = naughty.notification {
		app_name = "Screenshot", -- Use a specific app_name for the rule
		title = "Screenshot taken",
		text = "Saved to: " .. display_dir,
		icon = path,
		actions = { view_file, open_dir, copy, annotate, delete }
	}
end)