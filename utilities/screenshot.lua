--  _______                                     __           __   
-- |     __|.----.----.-----.-----.-----.-----.|  |--.-----.|  |_ 
-- |__     ||  __|   _|  -__|  -__|     |__ --||     |  _  ||   _|
-- |_______||____|__| |_____|_____|__|__|_____||__|__|_____||____|
-- -------------------------------------------------------------------------- --
-- provides a means of taking and automatically handling the naming and saving of a screenshot]
-- Dependencies: maim, xclip
--  
-- Thanks to @AlphaTechnolog (https://github.com/AlphaTechnolog) for the inspiration and boilerplate
-- AwesomeWM Library
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
-- -------------------------------------------------------------------------- --
local M = {}
-- -------------------------------------------------------------------------- --
-- just uses the tmp name of the os module and remove the tmp section
-- to get an unique id lol
local function random_id()
  return os.tmpname():gsub("/tmp/lua_", "")
end
-- -------------------------------------------------------------------------- --
-- returns an unique path for the screenshot inside the 'Pictures' folder.
local function get_path()
  return os.getenv("HOME") .. "/Pictures/screenshot-" .. random_id() .. ".png"
end
-- -------------------------------------------------------------------------- --
-- creates a dynamic/useful notification that should be showed after the
-- screenshot taking process.
function M.do_notify(tmp_path)
  local copy = naughty.action {name = "Copy"}
  local delete = naughty.action {name = "Delete"}
  -- -------------------------------------------------------------------------- --
  -- copy to clipboard button
  copy:connect_signal("invoked", function()
    awful.spawn.with_shell("xclip -sel clip -target image/png \"" .. tmp_path ..
                               "\"")
    -- -------------------------------------------------------------------------- --
    -- don't wait for xclip :/
    naughty.notify {
      app_name = "Screenshot",
      title = "Screenshot",
      text = "Screenshot copied successfully."
    }
  end)
  -- -------------------------------------------------------------------------- --
  -- delete
  delete:connect_signal("invoked", function()
    awful.spawn.easy_async_with_shell("rm " .. tmp_path, function()
      naughty.notify {
        app_name = "Screenshot",
        title = "Screenshot",
        text = "Screenshot removed successfully."
      }
    end)
  end)
  -- -------------------------------------------------------------------------- --
  -- Show the notification.
  naughty.notify {
    app_name = "Screenshot",
    app_icon = tmp_path,
    icon = tmp_path,
    title = "Screenshot is ready!",
    text = "Screenshot saved successfully",
    actions = {copy, delete}
  }
end
-- -------------------------------------------------------------------------- --
-- returns defaults properties
local function with_defaults(given_opts)
  return {notify = given_opts == nil and false or given_opts.notify}
end
-- -------------------------------------------------------------------------- --
-- takes a full-screen screenshot and depending on notify parameter, notifies the user the screenshot was taken
function M.full(opts)
  -- screenshot path.
  local tmp_path = get_path()
  -- -------------------------------------------------------------------------- --
  -- waiting a bit of time to wait the hidding of some visual elements
  -- that could be already rendered.
  gears.timer {
    timeout = 0.55,
    call_now = false,
    autostart = true,
    single_shot = true,
    callback = function()
      -- after maim, if do_notify is present it uses the emit to push the notification
      awful.spawn.easy_async_with_shell("maim \"" .. tmp_path .. "\"",
                                        function()
        ---@diagnostic disable-next-line: undefined-global
        awesome.emit_signal("screenshot::done")
        if with_defaults(opts).notify then
          M.do_notify(tmp_path)
        end
      end)
    end
  }
end
-- -------------------------------------------------------------------------- --
-- area screenshot function
function M.area(opts)
  -- screenshot path.
  local tmp_path = get_path()
  -- -------------------------------------------------------------------------- --
  -- calls maim, also checks if `do_notify` should be called using `opts.notify`.
  awful.spawn.easy_async_with_shell("maim --select \"" .. tmp_path .. "\"",
                                    function()
    ---@diagnostic disable-next-line: undefined-global
    awesome.emit_signal("screenshot::done")
    if with_defaults(opts).notify then
      M.do_notify(tmp_path)
    end
  end)
end
-- -------------------------------------------------------------------------- --
-- here are some default values for the opts object
function M.with_options(opts)
  opts = {
    -- if no type given, provide area as its type
    type = opts.type ~= nil and opts.type or "area",
    -- if no timeout is given, set the timeout to none 
    timeout = opts.timeout ~= nil and opts.timeout or 0,
    -- notify the user of the screenshot being taken by default
    notify = opts.notify ~= nil and opts.notify or true
  }
  -- -------------------------------------------------------------------------- --
  -- the callback which verifies an appropiate type is being provided
  local function core()
    if opts.type == "full" then
      M.full({notify = opts.notify})
    elseif opts.type == "area" then
      M.area({notify = opts.notify})
    else
      error("Invalid `opts.type` in `screenshot.with_options` (" .. opts.type ..
                "), valid ones are: full and area")
    end
  end
-- -------------------------------------------------------------------------- --
-- here we insure we have a timeout that represents either no timeout or a positive number
  if opts.timeout <= 0 then
    return core()
  end
-------------------------------------------------------------------------- --
-- the timer that runs the whole kit and kaboodle ;]
  gears.timer {
    timeout = opts.timeout,
    call_now = false,
    autostart = true,
    single_shot = true,
    callback = core
  }
end

-- -------------------------------------------------------------------------- --
return M
