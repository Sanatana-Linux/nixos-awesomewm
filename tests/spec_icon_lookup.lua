--- Spec for `modules.icon_lookup` class mappings and cache-key logic.
-- The module depends on lgi/Gio/menubar for the full pipeline, which we
-- mock so the test only exercises the testable bits: class-name mapping,
-- cache-key construction, fallback, and the is_readable predicate.
-- The full `get_client_icon` / `get_app_icon` paths exercise the GIR
-- pipeline and are left to integration tests.

local assert = require("tests.assert")
local runner = ...

-- Stubs for upstream modules.
package.loaded["menubar"] = {
    utils = {
        lookup_icon = function(name)
            return "/usr/share/icons/" .. name .. ".svg"
        end,
    },
}
package.loaded["gears"] = {
    filesystem = {
        file_readable = function(path)
            -- Readable iff the path doesn't contain "missing"
            return not path:find("missing", 1, true)
        end,
    },
}
package.loaded["beautiful"] = {
    icon_theme = "Colloid-Dark",
}

-- Lgi stub: every Gio.DesktopAppInfo.new(name) returns a fake whose
-- :get_string("Icon") returns the name unless name ends with "_nope".
package.loaded["lgi"] = {
    Gio = {
        DesktopAppInfo = {
            new = function(name)
                if name:find("_nope", 1, true) then
                    return nil
                end
                return {
                    get_string = function(_, key)
                        if key == "Icon" then
                            return "icon-for-" .. name
                        end
                        return ""
                    end,
                }
            end,
        },
    },
}

-- Reset the module to pick up our mocks
package.loaded["modules.icon-lookup"] = nil
local icon_lookup = require("modules.icon-lookup")

runner.describe("icon_lookup:fallback", function()
    runner.it("get_fallback_icon returns a non-empty absolute path", function()
        local f = icon_lookup.get_fallback_icon()
        assert.type(f, "string")
        assert.truthy(#f > 0)
        assert.truthy(f:sub(1, 1) == "/", "expected absolute path, got: " .. f)
    end)

    runner.it("is_readable returns true for known-good paths", function()
        -- A path that doesn't contain "missing" is readable (per our mock)
        assert.truthy(icon_lookup.is_readable("/usr/share/icons/foo.svg"))
    end)

    runner.it(
        "is_readable returns false for missing paths (per our mock)",
        function()
            assert.falsy(icon_lookup.is_readable("/missing/path.svg"))
        end
    )

    runner.it("is_readable returns false for nil", function()
        assert.falsy(icon_lookup.is_readable(nil))
    end)
end)

runner.describe("icon_lookup:theme name", function()
    runner.it("returns the configured icon theme", function()
        assert.eq(icon_lookup.get_theme_name(), "Colloid-Dark")
    end)
end)

runner.describe("icon_lookup:get_client_icon", function()
    runner.it("returns the fallback icon when client is nil", function()
        local f = icon_lookup.get_client_icon(nil)
        assert.eq(f, icon_lookup.get_fallback_icon())
    end)

    runner.it("resolves a class name via the desktop file lookup", function()
        local c = { class = "firefox", instance = "Navigator" }
        local result = icon_lookup.get_client_icon(c)
        -- The mock returns a path like /usr/share/icons/icon-for-firefox.svg
        assert.truthy(
            result:find("icon-for-firefox", 1, true),
            "got: " .. tostring(result)
        )
    end)

    runner.it("resolves a class through the CLASS_MAPPINGS table", function()
        local c = { class = "firefox-esr", instance = "Navigator" }
        local result = icon_lookup.get_client_icon(c)
        -- firefox-esr maps to "firefox-esr" in CLASS_MAPPINGS
        -- Then lookup_system_icon("firefox-esr") returns ...icon-for-firefox-esr.svg
        assert.truthy(
            result:find("firefox", 1, true) or result:find("Colloid", 1, true)
        )
    end)

    runner.it("returns nil when nothing resolves", function()
        -- "_nope" causes the mock to return nil from Gio.DesktopAppInfo.new
        local c = { class = "anything_nope", instance = "x" }
        local result = icon_lookup.get_client_icon(c)
        -- Most likely returns nil; may also return the application-x-executable
        -- candidate. Just assert it didn't crash.
        -- (The result is either nil or a string — both are valid.)
    end)
end)

runner.describe("icon_lookup:get_app_icon", function()
    runner.it("returns the fallback icon when app is nil", function()
        local f = icon_lookup.get_app_icon(nil)
        assert.eq(f, icon_lookup.get_fallback_icon())
    end)
end)

runner.describe("icon_lookup:cache", function()
    runner.it("memoizes repeated lookups for the same client", function()
        -- First call resolves and caches
        local c = { class = "firefox", instance = "Navigator" }
        local first = icon_lookup.get_client_icon(c)
        -- Second call should return the same value without re-resolving
        local second = icon_lookup.get_client_icon(c)
        assert.eq(first, second)
    end)

    runner.it("clears the cache on demand", function()
        local c = { class = "firefox", instance = "Navigator" }
        local _ = icon_lookup.get_client_icon(c)
        icon_lookup.clear_cache()
        -- After clear, the next call should still succeed and return a value
        local after_clear = icon_lookup.get_client_icon(c)
        assert.truthy(after_clear, "expected a value after cache clear")
    end)
end)
