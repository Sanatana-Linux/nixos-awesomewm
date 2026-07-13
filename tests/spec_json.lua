--- Spec for `lib.json` encoder/decoder.
-- The vendored JSON library has 2 public functions: `encode(value)` and
-- `decode(string)`. We test the round-trip and a variety of value types.

local assert = require("tests.assert")
local runner = ...

local json = require("lib.json")

runner.describe("json.encode", function()
    runner.it("encodes nil as null", function()
        assert.eq(json.encode(nil), "null")
    end)

    runner.it("encodes booleans", function()
        assert.eq(json.encode(true), "true")
        assert.eq(json.encode(false), "false")
    end)

    runner.it("encodes integers", function()
        assert.eq(json.encode(42), "42")
        assert.eq(json.encode(-7), "-7")
        assert.eq(json.encode(0), "0")
    end)

    runner.it("encodes floats", function()
        assert.eq(json.encode(3.14), "3.14")
    end)

    runner.it("encodes empty string", function()
        -- Empty strings are encoded as "" (quoted)
        local out = json.encode("")
        assert.truthy(out:find('""', 1, true))
    end)

    runner.it("encodes a string with special characters", function()
        -- Control characters, quotes, backslashes should be escaped
        local out = json.encode('hello "world"\n')
        assert.truthy(out:find("\\\"world\\\"", 1, true))
        assert.truthy(out:find("\\n", 1, true))
    end)

    runner.it("encodes empty table as empty array (no way to disambiguate)", function()
        -- Lua's empty table is ambiguous: this library defaults to array.
        assert.eq(json.encode({}), "[]")
    end)

    runner.it("encodes a sequential table as array", function()
        assert.eq(json.encode({ 1, 2, 3 }), "[1,2,3]")
    end)

    runner.it("encodes a map table as object (key order is not stable)", function()
        local out = json.encode({ a = 1, b = 2 })
        -- Lua table iteration order is not guaranteed; parse back to verify
        local decoded = json.decode(out)
        assert.eq(decoded.a, 1)
        assert.eq(decoded.b, 2)
    end)
end)

runner.describe("json.decode", function()
    runner.it("decodes null as nil", function()
        assert.eq(json.decode("null"), nil)
    end)

    runner.it("decodes booleans", function()
        assert.eq(json.decode("true"), true)
        assert.eq(json.decode("false"), false)
    end)

    runner.it("decodes integers", function()
        assert.eq(json.decode("42"), 42)
        assert.eq(json.decode("-7"), -7)
    end)

    runner.it("decodes floats", function()
        assert.eq(json.decode("3.14"), 3.14)
    end)

    runner.it("decodes strings", function()
        assert.eq(json.decode('"hello"'), "hello")
        assert.eq(json.decode('""'), "")
    end)

    runner.it("decodes empty array", function()
        local t = json.decode("[]")
        assert.type(t, "table")
        assert.eq(#t, 0)
    end)

    runner.it("decodes non-empty array", function()
        local t = json.decode("[1,2,3]")
        assert.eq(t[1], 1)
        assert.eq(t[2], 2)
        assert.eq(t[3], 3)
    end)

    runner.it("decodes empty object", function()
        local t = json.decode("{}")
        assert.type(t, "table")
        -- Empty object has no keys
        local count = 0
        for _ in pairs(t) do
            count = count + 1
        end
        assert.eq(count, 0)
    end)

    runner.it("decodes an object with keys", function()
        local t = json.decode('{"a":1,"b":"hello","c":true}')
        assert.eq(t.a, 1)
        assert.eq(t.b, "hello")
        assert.eq(t.c, true)
    end)

    runner.it("decodes nested structures", function()
        local t = json.decode('{"items":[1,2,3],"meta":{"count":3}}')
        assert.eq(t.items[1], 1)
        assert.eq(t.items[3], 3)
        assert.eq(t.meta.count, 3)
    end)

    runner.it("errors on non-string input", function()
        assert.errors(function()
            json.decode(42)
        end)
    end)

    runner.it("errors on trailing garbage", function()
        assert.errors(function()
            json.decode("{}garbage")
        end)
    end)
end)

runner.describe("json round-trip", function()
    runner.it("survives a simple object", function()
        local orig = { a = 1, b = "hello", c = true, d = nil }
        local encoded = json.encode(orig)
        local decoded = json.decode(encoded)
        assert.eq(decoded.a, 1)
        assert.eq(decoded.b, "hello")
        assert.eq(decoded.c, true)
    end)

    runner.it("survives a nested structure", function()
        local orig = {
            service = { navigator = { active = true } },
            items = { 1, 2, 3 },
            name = "test",
        }
        local encoded = json.encode(orig)
        local decoded = json.decode(encoded)
        assert.eq(decoded.service.navigator.active, true)
        assert.eq(decoded.items[1], 1)
        assert.eq(decoded.items[3], 3)
        assert.eq(decoded.name, "test")
    end)
end)
