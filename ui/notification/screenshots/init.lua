local lgi = require("lgi")
local Gio = lgi.Gio
local awful = require("awful")
local naughty = require("naughty")
local screenshot = require("service.screenshot").get_default()

screenshot:connect_signal("saved", function(_, dir, name)
    local path = dir .. name
    local notification

    -- Define the actions with improved names and tooltips
    local view_file = naughty.action({ name = "👁 View", tooltip = "Open screenshot in image viewer" })
    local open_dir = naughty.action({ name = "📁 Folder", tooltip = "Open containing folder" })
    local copy = naughty.action({ name = "📋 Copy", tooltip = "Copy image to clipboard" })
    local annotate = naughty.action({ name = "✏️ Annotate", tooltip = "Edit screenshot with Satty" })
    local delete = naughty.action({ name = "🗑️ Delete", tooltip = "Remove screenshot file" })

    -- Connect signals to the actions
    view_file:connect_signal("invoked", function()
        local status, app = pcall(function()
            return Gio.AppInfo.get_default_for_type("image/png")
        end)
        if status and app then
            awful.spawn(string.format("%s %s", app:get_executable(), path))
        end
    end)

    open_dir:connect_signal("invoked", function()
        local status, app = pcall(function()
            return Gio.AppInfo.get_default_for_type("inode/directory")
        end)
        if status and app then
            awful.spawn(string.format("%s %s", app:get_executable(), dir))
        end
    end)

    copy:connect_signal("invoked", function()
        screenshot:copy_screenshot(path)
    end)

    annotate:connect_signal("invoked", function()
        screenshot:annotate(path)
        -- We can optionally dismiss the notification after starting annotation
        if notification then
            notification:destroy()
        end
    end)

    delete:connect_signal("invoked", function()
        screenshot:delete(path)
        -- Dismiss the notification once the file is deleted
        if notification then
            notification:destroy()
        end
    end)

    local display_dir = dir:gsub(tostring(os.getenv("HOME")), "~")

    notification = naughty.notification({
        app_name = "Screenshot", -- Use a specific app_name for the rule
        title = "Screenshot taken",
        text = "Saved to: " .. display_dir,
        icon = path,
        actions = { view_file, open_dir, copy, annotate, delete },
    })
end)
