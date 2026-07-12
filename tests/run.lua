#!/usr/bin/env lua
--- Minimal test runner for the AwesomeWM config.
-- Discovers and runs all `tests/spec_*.lua` files in this directory.
-- Each spec file is expected to call `runner.describe(name, function() ... end)`.
-- Tests are pure Lua — they do NOT require an X server or running awesome instance.

local runner = {}
local results = { passed = 0, failed = 0, total = 0 }
local current_suite = "(none)"

--- Register a test suite.
-- @tparam string name Human-readable name
-- @tparam function fn Function that calls `runner.it()` for each test
function runner.describe(name, fn)
    current_suite = name
    print("\n  " .. name)
    fn()
    current_suite = "(none)"
end

--- Register a test case within the current suite.
-- @tparam string name Human-readable test name
-- @tparam function fn Function containing the test body
function runner.it(name, fn)
    results.total = results.total + 1
    local ok, err = pcall(fn)
    if ok then
        results.passed = results.passed + 1
        print("    \27[32m✓\27[0m " .. name)
    else
        results.failed = results.failed + 1
        print("    \27[31m✗\27[0m " .. name)
        print("      " .. tostring(err):gsub("\n", "\n      "))
    end
end

-- Discover and run all spec files
local function discover_specs(dir)
    local handle = io.popen('ls -1 "' .. dir .. '" 2>/dev/null | grep "^spec_" | grep "\\.lua$"')
    if not handle then
        return {}
    end
    local files = {}
    for line in handle:lines() do
        table.insert(files, dir .. "/" .. line)
    end
    handle:close()
    return files
end

-- Find the project root (parent of the tests directory) for module requires.
-- Falls back to a known relative path if `debug.getinfo` returns a relative source.
local function project_root()
    local source = debug.getinfo(1, "S").source
    if source:sub(1, 1) == "@" then
        source = source:sub(2)
    end
    local dir = source:match("(.*/)") or ""
    -- If still relative, prepend the current working dir
    if dir:sub(1, 1) ~= "/" then
        local cwd = (io.popen and io.popen("pwd"):read("*l")) or ""
        dir = cwd .. "/" .. dir
    end
    -- Strip trailing "tests/" to get project root
    return (dir:gsub("/tests/?$", "/"))
end

print("== AwesomeWM config tests ==")
local spec_dir = project_root() .. "tests"
local root = project_root()

-- Make `require("tests.assert")` and `require("modules.foo")` resolvable
package.path = spec_dir .. "/?.lua;" .. root .. "?.lua;" .. root .. "?/init.lua;" .. package.path

local specs = discover_specs(spec_dir)
print(string.format("(scanning %d spec files in %s)", #specs, spec_dir))
for _, spec in ipairs(specs) do
    -- Each spec file is its own scope; we run them sequentially in fresh env
    local fn, err = loadfile(spec)
    if fn then
        local ok, run_err = pcall(fn, runner)
        if not ok then
            print("\27[31mload error in " .. spec .. ":\27[0m " .. tostring(run_err))
        end
    else
        print("\27[31mcannot load " .. spec .. ":\27[0m " .. tostring(err))
    end
end

print(string.format(
    "\n== %d passed, %d failed, %d total ==\n",
    results.passed,
    results.failed,
    results.total
))
os.exit(results.failed > 0 and 1 or 0)
