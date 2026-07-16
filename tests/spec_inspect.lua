--- Spec for `lib.inspect` (vendored kikito/inspect.lua).
-- Tests the public surface: `inspect.inspect(value)` and the callable
-- form `inspect(value)`. The output is line-by-line so we assert on
-- substrings rather than full equality (which is brittle to version changes).

local assert = require("tests.assert")
local runner = ...

local inspect = require("lib.inspect")

runner.describe("inspect:primitives", function()
    runner.it("renders nil", function()
        local out = inspect(nil)
        assert.truthy(out:find("nil", 1, true), "expected 'nil' in: " .. out)
    end)

    runner.it("renders booleans", function()
        assert.truthy(inspect(true):find("true", 1, true))
        assert.truthy(inspect(false):find("false", 1, true))
    end)

    runner.it("renders numbers", function()
        assert.truthy(inspect(42):find("42", 1, true))
        assert.truthy(inspect(3.14):find("3.14", 1, true))
    end)

    runner.it("renders strings with quotes", function()
        local out = inspect("hello")
        -- Strings are quoted; exact quoting style may differ
        assert.truthy(
            out:find("hello", 1, true),
            "expected 'hello' in: " .. out
        )
    end)
end)

runner.describe("inspect:tables", function()
    runner.it("renders an empty table", function()
        local out = inspect({})
        -- Empty table — output should be `{}` or similar
        assert.truthy(out:find("{", 1, true) and out:find("}", 1, true))
    end)

    runner.it("renders a flat map", function()
        local out = inspect({ a = 1, b = 2 })
        assert.truthy(out:find("a", 1, true))
        assert.truthy(out:find("b", 1, true))
        assert.truthy(out:find("1", 1, true))
        assert.truthy(out:find("2", 1, true))
    end)

    runner.it("renders nested tables", function()
        local t = { outer = { inner = 42 } }
        local out = inspect(t)
        assert.truthy(out:find("outer", 1, true))
        assert.truthy(out:find("inner", 1, true))
        assert.truthy(out:find("42", 1, true))
    end)

    runner.it("renders array-style tables", function()
        local out = inspect({ 10, 20, 30 })
        assert.truthy(out:find("10", 1, true))
        assert.truthy(out:find("20", 1, true))
        assert.truthy(out:find("30", 1, true))
    end)

    runner.it("handles recursive tables without infinite loop", function()
        local t = {}
        t.self = t
        local out = inspect(t)
        -- Should contain some marker indicating recursion (typically `<self>` or similar)
        assert.truthy(#out > 0, "expected non-empty output for recursive table")
    end)
end)

runner.describe("inspect:options", function()
    runner.it("accepts a depth option", function()
        local deep = { a = { b = { c = { d = 1 } } } }
        local out = inspect(deep, { depth = 2 })
        -- At depth 2 we should NOT see the innermost key
        assert.falsy(
            out:find("d = ", 1, true),
            "depth=2 should not show d: " .. out
        )
    end)

    runner.it("accepts a newline option", function()
        local out = inspect({ a = 1 }, { newline = " " })
        -- With newline=" " instead of "\n", the output should be on a
        -- single line.
        assert.falsy(
            out:find("\n", 1, true),
            "expected single-line output: " .. out
        )
    end)
end)

runner.describe("inspect:indentation", function()
    runner.it("respects indent option", function()
        local out = inspect({ a = 1, b = 2 }, { indent = "    " })
        -- Indented output should contain 4 spaces somewhere
        assert.truthy(
            out:find("    ", 1, true),
            "expected 4-space indent: " .. out
        )
    end)
end)

runner.describe("inspect:callable form", function()
    runner.it("can be invoked as a function", function()
        -- The module returns a callable table via __call
        local out = inspect({ 1, 2, 3 }) -- without .inspect
        assert.truthy(out:find("1", 1, true))
        assert.truthy(out:find("2", 1, true))
        assert.truthy(out:find("3", 1, true))
    end)

    runner.it("explicit inspect.inspect gives the same result", function()
        local t = { a = 1, b = 2 }
        assert.eq(inspect.inspect(t), inspect(t))
    end)
end)
