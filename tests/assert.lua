--- Minimal assertion library for AwesomeWM config tests.
-- Native Lua, no external dependencies. Run with `lua tests/run.lua`.
-- @module tests.assert

local M = {}

local function fail(msg, level)
    error(msg or "assertion failed", (level or 1) + 1)
end

--- Assert that `actual` equals `expected`.
-- @tparam any actual
-- @tparam any expected
-- @tparam[opt] string msg
function M.eq(actual, expected, msg)
    if actual ~= expected then
        fail(
            (msg or "eq")
                .. ": expected "
                .. tostring(expected)
                .. ", got "
                .. tostring(actual),
            2
        )
    end
end

--- Assert that `value` is truthy.
-- @tparam any value
-- @tparam[opt] string msg
function M.truthy(value, msg)
    if not value then
        fail((msg or "truthy") .. ": value is falsy: " .. tostring(value), 2)
    end
end

--- Assert that `value` is falsy.
-- @tparam any value
-- @tparam[opt] string msg
function M.falsy(value, msg)
    if value then
        fail((msg or "falsy") .. ": value is truthy: " .. tostring(value), 2)
    end
end

--- Assert that `fn` raises an error matching `pattern` (or any error if pattern is nil).
-- @tparam function fn
-- @tparam[opt] string pattern Lua pattern to match against the error message
-- @tparam[opt] string msg
function M.errors(fn, pattern, msg)
    local ok, err = pcall(fn)
    if ok then
        fail((msg or "errors") .. ": expected error, got success", 2)
    end
    if pattern and not tostring(err):find(pattern) then
        fail(
            (msg or "errors")
                .. ": error '"
                .. tostring(err)
                .. "' does not match pattern '"
                .. pattern
                .. "'",
            2
        )
    end
end

--- Assert that `value` is of the given Lua type.
-- @tparam any value
-- @tparam string type Expected type name (e.g. "string", "table")
-- @tparam[opt] string msg
function M.type(value, expected_type, msg)
    if type(value) ~= expected_type then
        fail(
            (msg or "type")
                .. ": expected "
                .. expected_type
                .. ", got "
                .. type(value),
            2
        )
    end
end

--- Assert that table `t` has key `k`.
-- @tparam table t
-- @param k
-- @tparam[opt] string msg
function M.has(t, k, msg)
    if type(t) ~= "table" then
        fail(
            (msg or "has") .. ": first argument is not a table: " .. type(t),
            2
        )
    end
    if t[k] == nil then
        fail((msg or "has") .. ": key '" .. tostring(k) .. "' is missing", 2)
    end
end

return M
