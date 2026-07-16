--- Screenshot service.
-- Thin wrapper over the `maim` capture utility and the `satty` annotator.
-- Captured PNGs land in `$HOME/Pictures/` (overridable via
-- `service.screenshot.OUTPUT_DIR`), and the service emits `saved` /
-- `canceled` / `annotated` / `deleted` signals as appropriate.
-- @module service.screenshot

local lgi = require("lgi")
local Gtk, Gdk, GdkPixbuf -- Loaded with a fallback below

local success = pcall(function()
    Gtk = lgi.require("Gtk", "3.0")
    Gdk = lgi.require("Gdk", "3.0")
    GdkPixbuf = lgi.require("GdkPixbuf")
end)
if not success then
    Gtk, Gdk, GdkPixbuf = nil, nil, nil
end

local awful = require("awful")
local naughty = require("naughty")
local gobject = require("gears.object")
local gtable = require("gears.table")
local file_exists = require("lib.util").file_exists

-- Default output directory. Callers can override `screenshot.OUTPUT_DIR`
-- before the first capture.
local DEFAULT_OUTPUT_DIR = (os.getenv("HOME") or "") .. "/Pictures"

local screenshot = {}
screenshot.OUTPUT_DIR = DEFAULT_OUTPUT_DIR

--- Quote a path for safe inclusion in a shell command.
-- Single-quote escaping with the standard `'…'\''` trick. Use this when
-- the path may contain spaces, `'` characters, or other shell metacharacters.
-- @tparam string path
-- @treturn string Safe-for-shell path
local function shell_quote(path)
    return "'" .. path:gsub("'", "'\\''") .. "'"
end

--- Build a shell-safe `maim` invocation.
-- The `args` parameter is passed through verbatim because it's only
-- ever populated by hardcoded flags (`-s`, `-u -d N`, or empty),
-- never user input. Paths are quoted via `shell_quote`.
-- @tparam string args Empty for full-screen, `-s` for select, `-u -d N` for delayed
-- @tparam string outpath Absolute path for the captured PNG
-- @treturn string Shell command
local function build_maim_cmd(args, outpath)
    return string.format("maim %s %s", args or "", shell_quote(outpath))
end

--- Capture a screenshot to a timestamped PNG in `OUTPUT_DIR`.
-- Emits `saved` (with the output directory and filename) on success
-- or `canceled` if `maim` returns non-zero. Surfaces a critical
-- naughty.notification on failure.
-- @tparam[opt] string args `maim` flags (e.g. `"-s"` for selection, `"-u -d 3"` for delay)
-- @treturn nil
function screenshot:take(args)
    local self_ref = self
    local folder = self.OUTPUT_DIR or DEFAULT_OUTPUT_DIR
    local dir = string.match(folder, "/$") and folder or folder .. "/"
    local name = "satty-" .. os.date("%Y%m%d-%H:%M:%S") .. ".png"
    local outpath = dir .. name

    awful.spawn.easy_async_with_shell(
        build_maim_cmd(args, outpath),
        function(stdout, stderr, reason, exit_code)
            if exit_code == 0 and file_exists(outpath) then
                self_ref:emit_signal("saved", dir, name)
            else
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

--- Capture a full-screen screenshot.
-- Wrapper around `take("")`.
function screenshot:take_full()
    self:take("")
end

--- Take a screenshot after a delay.
-- @tparam[opt=1] number delay Delay in seconds
function screenshot:take_delay(delay)
    delay = delay or 1
    self:take("-u -d " .. delay)
end

--- Take a screenshot of a region selected with the mouse.
function screenshot:take_select()
    self:take("-s")
end

--- Open an existing screenshot in the satty annotator.
-- No-op if `path` doesn't exist. Emits `annotated` when satty closes.
-- @tparam string path Path to the PNG to annotate
function screenshot:annotate(path)
    if not file_exists(path) then
        return
    end
    local self_ref = self
    local cmd = string.format(
        "satty --filename %s --fullscreen --output-filename %s",
        shell_quote(path),
        shell_quote(path)
    )
    awful.spawn.easy_async_with_shell(cmd, function()
        self_ref:emit_signal("annotated", path)
    end)
end

--- Delete a screenshot file via `rm`.
-- No-op if `path` doesn't exist. Emits `deleted` after the rm
-- completes.
-- @tparam string path Absolute path to delete
function screenshot:delete(path)
    if not file_exists(path) then
        return
    end
    local self_ref = self
    awful.spawn.easy_async_with_shell("rm " .. shell_quote(path), function()
        self_ref:emit_signal("deleted", path)
    end)
end

--- Copy a PNG to the system clipboard via GTK.
-- Requires the GIR bindings (loaded at module init). No-op + a
-- notification if GTK isn't available, or if the image fails to
-- load. Stores the image persistently (`clipboard:store()`).
-- @tparam string path Absolute path to the PNG to copy
function screenshot:copy_screenshot(path)
    if not file_exists(path) then
        return
    end
    if not GdkPixbuf then
        naughty.notification({
            app_name = "Screenshot",
            urgency = "normal",
            title = "Copy Failed",
            message = "GTK clipboard not available",
            timeout = 5,
        })
        return
    end
    local image = GdkPixbuf.Pixbuf.new_from_file(path)
    if image and self._private.clipboard then
        self._private.clipboard:set_image(image)
        self._private.clipboard:store()
    end
end

--- Construct a fresh screenshot service instance.
-- Initialises `_private` state and, if GTK is available, sets up
-- a clipboard reference.
-- @treturn table A gobject with the public methods of `screenshot`
local function new()
    local ret = gobject({})
    gtable.crush(ret, screenshot, true)
    ret._private = {}
    if Gtk and Gdk then
        ret._private.clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
    end
    return ret
end

--- Singleton accessor: returns (and lazily constructs) the screenshot service.
-- @treturn table Cached service instance (same object on every call)
local instance
local function get_default()
    if not instance then
        instance = new()
    end
    return instance
end

return {
    get_default = get_default,
}
