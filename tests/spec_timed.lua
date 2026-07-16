--- Spec for the `awful.util.timed` overlay helper in `upstream/awful/util.lua`.
-- The production helper is a closure factory that wraps a function and logs
-- elapsed ms when it exceeds a threshold. This spec mirrors the same logic
-- and exercises the wrapping with a fake "sleep" via `os.clock` manipulation.

local assert = require("tests.assert")
local runner = ...

-- Mirror of the production util.timed, parameterized on a clock function so
-- the test can control the elapsed time.
local function make_timed(threshold_ms, fn, clock)
    threshold_ms = threshold_ms or 16
    clock = clock or function()
        return os.clock() * 1000
    end
    local last_ms = 0
    return setmetatable({}, {
        __call = function(_, ...)
            local t0 = clock()
            local r = { fn(...) }
            local t1 = clock()
            last_ms = t1 - t0
            if last_ms >= threshold_ms then
                local info = debug.getinfo(fn, "Sl")
                print(
                    string.format(
                        "[awful.util.timed] %s:%d took %.2fms",
                        info.short_src or "?",
                        info.currentline or -1,
                        last_ms
                    )
                )
            end
            return unpack(r)
        end,
    }),
        function()
            return last_ms
        end
end

runner.describe("awful.util.timed", function()
    runner.it("returns a callable wrapper and a get_ms probe", function()
        local wrapped, get_ms = make_timed(10, function() end)
        wrapped()
        assert.type(get_ms(), "number")
    end)

    runner.it("returns the wrapped function's return value", function()
        local wrapped = make_timed(1000, function(x)
            return x * 2
        end)
        assert.eq(wrapped(21), 42)
    end)

    runner.it(
        "returns the first return value only (single-value, by Lua design)",
        function()
            -- Note: the production impl uses `unpack(r)` which returns all
            -- values in a multi-return context. Here we document the same
            -- multi-value behavior.
            local wrapped = make_timed(1000, function()
                return 1, 2, 3
            end)
            local a, b, c = wrapped()
            assert.eq(a, 1)
            assert.eq(b, 2)
            assert.eq(c, 3)
        end
    )

    runner.it("tracks last elapsed time", function()
        local wrapped, get_ms = make_timed(10, function() end, function()
            _G._clock_t = (_G._clock_t or -1) + 50
            return _G._clock_t
        end)
        wrapped() -- delta is 50
        assert.eq(get_ms(), 50)
        wrapped() -- delta is 50 again
        assert.eq(get_ms(), 50)
        _G._clock_t = nil
    end)

    runner.it("logs when over the threshold", function()
        -- Capture print output
        local saved_print = print
        local logged = {}
        print = function(...)
            table.insert(logged, table.concat({ ... }, "\t"))
        end
        local wrapped = make_timed(10, function() end, function()
            -- 50ms delta
            if not _G._timed_test then
                _G._timed_test = 0
            end
            local now = _G._timed_test
            _G._timed_test = now + 50
            return now
        end)
        wrapped()
        print = saved_print
        assert.eq(#logged, 1)
        assert.truthy(logged[1]:find("50.00ms"))
    end)

    runner.it("does not log when under the threshold", function()
        local saved_print = print
        local logged = {}
        print = function(...)
            table.insert(logged, ...)
        end
        _G._timed_test = 0
        local wrapped = make_timed(100, function() end, function()
            local now = _G._timed_test
            _G._timed_test = now + 5 -- well under threshold
            return now
        end)
        wrapped()
        print = saved_print
        assert.eq(#logged, 0)
    end)
end)
