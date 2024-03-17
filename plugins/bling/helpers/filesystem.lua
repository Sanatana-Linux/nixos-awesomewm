local Gio = require("lgi").Gio
local awful = require("awful")
local gears = require("gears")
local string = string

--- A module that provides filesystem utilities for AwesomeWM.
-- @module bling.helpers.filesystem
local _filesystem = {}

--- Get a list of files from a given directory.
-- This function will return a table of file names from the specified directory.
-- If extensions are provided, it will only list files with those extensions.
-- @tparam string path The directory to search.
-- @tparam[opt] table exts A table of specific extensions to limit the search to, e.g., `{ "jpg", "png" }`.
-- If omitted, all files are considered.
-- @tparam[opt=false] boolean recursive Whether to list files from subdirectories.
-- @treturn table A table containing the file names.
-- @staticfct bling.helpers.filesystem.list_directory_files
function _filesystem.list_directory_files(path, exts, recursive)
    recursive = recursive or false
    local files, valid_exts = {}, {}

    -- Transforms { "jpg", ... } into { [jpg] = true, ... }
    if exts then
        for _, ext in ipairs(exts) do
            valid_exts[ext:lower()] = true
        end
    end

    -- Helper function to add files to the list
    local function add_files_from_path(file_path)
        local file_list = Gio.File.new_for_path(file_path):enumerate_children("standard::*", 0)
        if file_list then
            for file in function() return file_list:next_file() end do
                local file_type = file:get_file_type()
                local file_name = file:get_display_name()
                if file_type == "REGULAR" then
                    if not exts or valid_exts[file_name:lower():match(".+%.(.*)$") or ""] then
                        table.insert(files, file_name)
                    end
                elseif recursive and file_type == "DIRECTORY" then
                    add_files_from_path(file_name)
                end
            end
        end
    end

    -- Start adding files from the initial path
    add_files_from_path(path)

    return files
end

--- Asynchronously save an image from a URL to a file.
-- This function will download an image from the given URL and save it to the specified filepath.
-- A callback is called upon completion.
-- @tparam string url The URL of the image to download.
-- @tparam string filepath The path where the image should be saved.
-- @tparam function callback The function to call when the download is complete.
-- @staticfct bling.helpers.filesystem.save_image_async_curl
function _filesystem.save_image_async_curl(url, filepath, callback)
    awful.spawn.with_line_callback(
        string.format("curl -L -s '%s' -o '%s'", url, filepath),
        {
            exit = function(...) callback(...) end,
        }
    )
end

return _filesystem