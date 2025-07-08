local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")
local Gdk = lgi.require("Gdk", "3.0")
local GdkPixbuf = lgi.require("GdkPixbuf")
local awful = require("awful")
local naughty = require("naughty") -- Added for error notifications
local gobject = require("gears.object")
local gtable = require("gears.table")
local file_exists = require("lib").file_exists

local screenshot = {}

function screenshot:take(args)
    -- Capture self in a local variable to be used in the async callback
    local self_ref = self
    -- The screenshot folder is now hardcoded to the user's Pictures directory.
    local folder = os.getenv("HOME") .. "/Pictures"
    local dir = string.match(folder, "/$") and folder or folder .. "/"
    local name = "satty-" .. os.date("%Y%m%d-%H:%M:%S") .. ".png"
    local outpath = dir .. name

    -- The command now only runs maim to capture the screenshot.
    local cmd = string.format("maim %s '%s'", args or "", outpath)

    awful.spawn.easy_async_with_shell(
        cmd,
        function(stdout, stderr, reason, exit_code)
            -- Check if the command was successful
            if exit_code == 0 and file_exists(outpath) then
                self_ref:emit_signal("saved", dir, name)
            else
                -- If the command fails, create a notification to show the error
                naughty.notification({
                    app_name = "Screenshot",
                    urgency = "critical",
                    title = "Screenshot Failed",
                    message = "Could not take screenshot. Error: "
                        .. (stderr or "Unknown error"),
                    timeout = 0,
                })
                self_ref:emit_signal("canceled")
            end
        end
    )
end

function screenshot:take_full()
    self:take("")
end

function screenshot:take_delay(delay)
    delay = delay or 1
    self:take("-u -d " .. delay)
end

function screenshot:take_select()
    self:take("-s")
end

-- New function to annotate an existing screenshot
function screenshot:annotate(path)
    if not file_exists(path) then
        return
    end
    local self_ref = self
    -- The satty command now opens the existing file for annotation.
    local cmd = string.format(
        "satty --filename '%s' --fullscreen --output-filename '%s'",
        path,
        path
    )
    awful.spawn.easy_async_with_shell(cmd, function()
        -- You might want to emit a signal here if you need to know when annotation is done.
        self_ref:emit_signal("annotated", path)
    end)
end

-- New function to delete a screenshot file
function screenshot:delete(path)
    if not file_exists(path) then
        return
    end
    local self_ref = self
    local cmd = string.format("rm '%s'", path)
    awful.spawn.easy_async_with_shell(cmd, function()
        self_ref:emit_signal("deleted", path)
    end)
end

function screenshot:copy_screenshot(path)
    if not file_exists(path) then
        return
    end
    local image = GdkPixbuf.Pixbuf.new_from_file(path)
    if image then
        self._private.clipboard:set_image(image)
        self._private.clipboard:store()
    end
end

local function new()
    local ret = gobject({})
    gtable.crush(ret, screenshot, true)
    ret._private = {}
    ret._private.clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
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
