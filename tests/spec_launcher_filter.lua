--- Spec for `ui.popups.launcher` pure helper `filter_apps`.
-- `filter_apps` is a local function in the production code. We
-- extract it via the same source-rewriting technique used by
-- `spec_text_input.lua` and `spec_audio_poll.lua`. The launcher
-- itself depends on a live X server, lgi, and `awful.popup` — we
-- only test the pure filter algorithm here.

local asrt = require("tests.assert")
local runner = ...

-- ---------------------------------------------------------------------------
-- Module mocks
-- ---------------------------------------------------------------------------

-- lgi: Gio.AppInfo.get_all() is called at construction, but our
-- short-circuit source cut will prevent reaching that line. Stub it
-- anyway for safety.
package.loaded["lgi"] = {
    Gio = {
        AppInfo = {
            get_all = function()
                return {}
            end,
            get_default_for_uri_scheme = function()
                return nil
            end,
        },
        DesktopAppInfo = {
            new = function()
                return nil
            end,
        },
    },
}

-- awful: popup, spawn, placement, button, etc. — all stubbed.
package.loaded["awful"] = {
    popup = function(args)
        local ret = { visible = args and args.visible or false }
        function ret:get_children_by_id()
            return {}
        end
        function ret:connect_signal() end
        function ret:emit_signal() end
        function ret:buttons() end
        return ret
    end,
    spawn = function() end,
    spawn_with_shell = function() end,
    easy_async = function() end,
    placement = {
        bottom_left = function() end,
    },
    button = function()
        return {}
    end,
    keygrabber = {
        run = function() end,
        stop = function() end,
    },
    util = {
        color = {
            ensure_pango_color = function()
                return ""
            end,
        },
    },
    tag = {
        selected = function()
            return {}
        end,
    },
    mouse = {
        screen = {
            workarea = { x = 0, y = 0, width = 1920, height = 1080 },
            geometry = { x = 0, y = 0, width = 1920, height = 1080 },
        },
    },
    screen = {
        primary = {
            workarea = { x = 0, y = 0, width = 1920, height = 1080 },
            geometry = { x = 0, y = 0, width = 1920, height = 1080 },
        },
    },
    client = {},
}

-- wibox mock: only the methods the production code touches.
local function fake_wibox_widget(args)
    local ret = args or {}
    function ret:get_children_by_id()
        return {}
    end
    function ret:connect_signal() end
    function ret:set_markup() end
    function ret:set_text() end
    function ret:set_forced_height() end
    function ret:add() end
    function ret:reset() end
    function ret:buttons() end
    return ret
end
local function fake_wibox_container()
    return setmetatable({}, {
        __call = function()
            return fake_wibox_widget()
        end,
    })
end
package.loaded["wibox"] = {
    widget = setmetatable({
        textbox = function()
            return fake_wibox_widget()
        end,
        imagebox = function()
            return fake_wibox_widget()
        end,
        separator = function()
            return fake_wibox_widget()
        end,
    }, {
        __call = function()
            return fake_wibox_widget()
        end,
    }),
    container = {
        background = fake_wibox_container(),
        margin = fake_wibox_container(),
        place = fake_wibox_container(),
        constraint = fake_wibox_container(),
    },
    layout = {
        fixed = {
            vertical = function()
                return fake_wibox_widget()
            end,
            horizontal = function()
                return fake_wibox_widget()
            end,
        },
        align = {
            vertical = function()
                return fake_wibox_widget()
            end,
            horizontal = function()
                return fake_wibox_widget()
            end,
        },
        flex = {
            horizontal = function()
                return fake_wibox_widget()
            end,
        },
        stack = function()
            return fake_wibox_widget()
        end,
        grid = function()
            return fake_wibox_widget()
        end,
        overflow = {
            vertical = function()
                return fake_wibox_widget()
            end,
        },
    },
}

-- gears: surface, color, timer, table, filesystem, shape
package.loaded["gears"] = {
    surface = {
        load_uncached = function()
            return {}
        end,
        get_size = function()
            return 0, 0
        end,
    },
    color = {
        recolor_image = function()
            return ""
        end,
        ensure_pango_color = function()
            return ""
        end,
    },
    timer = {
        delayed_call = function() end,
        start_new = function()
            return {}
        end,
    },
    table = {
        join = function()
            return {}
        end,
        hasitem = function()
            return false
        end,
        clone = function(t)
            return t
        end,
        crush = function(t, m)
            for k, v in pairs(m) do
                t[k] = v
            end
            return t
        end,
    },
    filesystem = {
        file_readable = function()
            return true
        end,
        get_configuration_dir = function()
            return "/tmp/"
        end,
        dir_read_only = function()
            return {}
        end,
    },
    shape = {
        rounded_rect = function()
            return "rect"
        end,
        rounded_bar = function()
            return "bar"
        end,
        partially_rounded_rect = function()
            return "prrect"
        end,
        circle = function()
            return "circle"
        end,
    },
    string = {
        xml_escape = function(s)
            return s or ""
        end,
    },
    object = setmetatable({}, {
        __call = function()
            return {
                connect_signal = function() end,
                emit_signal = function() end,
            }
        end,
    }),
    matrix = {},
}

-- gears.timer (the gtimer local)
package.loaded["gears.timer"] = {
    delayed_call = function() end,
    start_new = function()
        return {
            start = function() end,
            stop = function() end,
            again = function() end,
        }
    end,
}

-- gears.table
package.loaded["gears.table"] = package.loaded["gears"].table

-- gears.filesystem
package.loaded["gears.filesystem"] = package.loaded["gears"].filesystem

-- gears.surface
package.loaded["gears.surface"] = package.loaded["gears"].surface

-- gears.color
package.loaded["gears.color"] = package.loaded["gears"].color

-- gears.string
package.loaded["gears.string"] = package.loaded["gears"].string

-- gears.object
package.loaded["gears.object"] = package.loaded["gears"].object

-- gears.shape
package.loaded["gears.shape"] = package.loaded["gears"].shape

-- beautiful
package.loaded["beautiful"] = {
    xresources = {
        apply_dpi = function(x)
            return x
        end,
    },
    bg = "#000000",
    bg_alt = "#111111",
    fg = "#ffffff",
    fg_alt = "#cccccc",
    border_width = 1,
    border_color_normal = "#333333",
    border_color_active = "#ff0000",
    red = "#ff0000",
    blue = "#0000ff",
    green = "#00ff00",
    bg_gradient_button = "#222222",
    bg_gradient_button_alt = "#333333",
    bg_gradient_recessed = "#111111",
    bg_urg = "#444444",
    accent_color = "#7aa2f7",
    accent = "#bb9af7",
    font = "Sans 10",
    font_name = "Sans",
    text_icons = {
        arrow_left = "<",
        arrow_right = ">",
        search = "S",
        lock = "L",
        power = "P",
    },
    useless_gap = 5,
    separator_thickness = 1,
    wallpaper_unbranded = "/tmp/wallpaper.png",
    border_radius = 8,
}

-- lib: only lua_escape is required.
package.loaded["lib"] = {
    lua_escape = function(s)
        s = s or ""
        s = s:gsub("[%[%]%(%)%.%-%+%?%*%^%$%%]", "%%%1")
        return s
    end,
    is_supported = function()
        return true
    end,
    table_to_file = function()
        return true
    end,
}

-- modules: the launcher requires many. Stub them all to no-op
-- constructors returning empty tables.
package.loaded["modules"] = {
    text_input = function()
        return fake_wibox_widget()
    end,
}
package.loaded["modules.animations"] = {
    animate = function()
        return { stop = function() end }
    end,
    easing = {
        quadratic = function(t)
            return t
        end,
    },
}
package.loaded["modules.shapes"] = {
    rrect = function()
        return function() end
    end,
    rrect_6 = function()
        return function() end
    end,
    rrect_8 = function()
        return function() end
    end,
    rbar = function()
        return function() end
    end,
    prrect = function()
        return function() end
    end,
    circle = function()
        return function() end
    end,
    squircle = function()
        return function() end
    end,
}
package.loaded["modules.shapes.init"] = package.loaded["modules.shapes"]
package.loaded["modules.icon-lookup"] = {
    get_fallback_icon = function()
        return "/tmp/fallback.svg"
    end,
    get_app_icon = function()
        return "/tmp/app.svg"
    end,
    get_client_icon = function()
        return "/tmp/client.svg"
    end,
}
package.loaded["modules.crop_surface"] = function()
    return {}
end
package.loaded["modules.click_to_hide"] = { popup = function() end }

-- ui.popups.powermenu — required at load time
package.loaded["ui.popups.powermenu"] = {
    get_default = function()
        return { show = function() end, hide = function() end }
    end,
}

-- ---------------------------------------------------------------------------
-- Source rewriting
-- ---------------------------------------------------------------------------

--- Load the production source and extract the `filter_apps` local
-- function. Same pattern as spec_text_input.lua.
local function load_helpers()
    local f = assert(io.open("ui/popups/launcher/init.lua", "r"))
    local source = f:read("*a")
    f:close()

    -- Rewrite `local function filter_apps(apps, query)` into an M assignment
    source = source:gsub(
        "local function filter_apps%(apps, query%)",
        "M.filter_apps = function(apps, query)"
    )

    -- Inject `local M = {}` after the last `local shapes = ...` line
    source = source:gsub(
        '(local shapes = require%(%s*"modules%.shapes%.init"%s*%))',
        "%1\nlocal M = {}"
    )

    -- Short-circuit: the filter_apps function ends with `return filtered\nend`.
    -- Match that exact pattern and cut the rest.
    local marker = "return filtered\nend\n"
    local pos = source:find(marker, 1, true)
    if not pos then
        error("could not find filter_apps end marker")
    end
    local cut = pos + #marker - 1
    source = source:sub(1, cut) .. "return M\n"

    -- The function calls `lua_escape(query)` — rewrite to a local stub
    -- so we don't need the lib.lua_escape here. The escape must
    -- match lib.lua_escape exactly:
    --   [ % [ ] % ( % ) % . % - % + % ? % * % ^ % $ %% ]   ->   "%%%1"
    source = source:gsub("lua_escape%(query%)", "_G.lua_escape(query)")
    source = "lua_escape = function(s) s = s or ''; return (s:gsub('[%[%]%(%)%.%-%+%?%*%^%$%%]', '%%%1')) end\n"
        .. source

    local chunk, err = load(source, "ui/popups/launcher/init.lua", "t")
    if not chunk then
        error("compile failed: " .. tostring(err))
    end
    local ok, result = pcall(chunk)
    if not ok then
        error("execution failed: " .. tostring(result))
    end
    return result
end

local helpers = load_helpers()
local filter_apps = helpers.filter_apps

-- ---------------------------------------------------------------------------
-- Tests
-- ---------------------------------------------------------------------------

-- Build fake app objects with the methods filter_apps uses.
local function fake_app(name, executable, should_show)
    return {
        get_name = function()
            return name
        end,
        get_executable = function()
            return executable or name
        end,
        get_description = function()
            return ""
        end,
        get_id = function()
            return name
        end,
        should_show = function()
            return should_show ~= false
        end,
    }
end

runner.describe("launcher:filter_apps", function()
    runner.it("returns an empty list for empty input", function()
        local r = filter_apps({}, "fire")
        asrt.eq(#r, 0)
    end)

    runner.it("returns all apps when query is empty", function()
        local apps = { fake_app("Firefox"), fake_app("Chrome") }
        local r = filter_apps(apps, "")
        asrt.eq(#r, 2)
    end)

    runner.it("matches by name prefix", function()
        local apps =
            { fake_app("Firefox"), fake_app("Chromium"), fake_app("Konsole") }
        local r = filter_apps(apps, "Fire")
        asrt.eq(#r, 1)
        asrt.eq(r[1].get_name(), "Firefox")
    end)

    runner.it("matches by name substring (fallback)", function()
        local apps = { fake_app("Firefox"), fake_app("Chromium") }
        local r = filter_apps(apps, "fox")
        asrt.eq(#r, 1)
        asrt.eq(r[1].get_name(), "Firefox")
    end)

    runner.it("matches by executable substring", function()
        local apps = {
            fake_app("SomeApp", "/usr/bin/firefox-bin"),
            fake_app("Other", "/usr/bin/ls"),
        }
        local r = filter_apps(apps, "firefox")
        asrt.eq(#r, 1)
        asrt.eq(r[1].get_name(), "SomeApp")
    end)

    runner.it("puts prefix matches before substring matches", function()
        local apps = {
            fake_app("FoxNews", "", false), -- hidden
            fake_app("Firefox"),
            fake_app("MyFox"),
        }
        local r = filter_apps(apps, "fox")
        -- Should include Firefox (prefix) and MyFox (substring); FoxNews hidden
        local names = {}
        for _, app in ipairs(r) do
            table.insert(names, app.get_name())
        end
        asrt.truthy(#names >= 1)
        asrt.eq(names[1], "Firefox")
    end)

    runner.it("skips apps where should_show returns false", function()
        local apps = {
            fake_app("Visible"),
            fake_app("Hidden", "/bin/h", false),
        }
        local r = filter_apps(apps, "")
        asrt.eq(#r, 1)
        asrt.eq(r[1].get_name(), "Visible")
    end)

    runner.it("sorts prefix matches alphabetically", function()
        local apps = {
            fake_app("Zoom"),
            fake_app("Firefox"),
            fake_app("AndroidStudio"),
        }
        local r = filter_apps(apps, "")
        -- All return name (empty query = prefix-match everything)
        asrt.eq(r[1].get_name(), "AndroidStudio")
        asrt.eq(r[2].get_name(), "Firefox")
        asrt.eq(r[3].get_name(), "Zoom")
    end)

    runner.it("handles case-insensitive matching", function()
        local apps = { fake_app("Firefox") }
        local r = filter_apps(apps, "FIREFOX")
        asrt.eq(#r, 1)
    end)

    runner.it("escapes lua pattern metacharacters in the query", function()
        -- If the query isn't escaped, "fire." would match "fireX" via
        -- pattern. The escape means only literal "fire." matches.
        local apps = {
            fake_app("fire.real"),
            fake_app("fireX"),
        }
        local r = filter_apps(apps, "fire.")
        -- "fire.real" has prefix "fire." — only the literal period.
        -- "fireX" only has the substring "fire" but no literal period
        -- in the prefix. With escaping, "." is a literal.
        asrt.eq(#r, 1)
        asrt.eq(r[1].get_name(), "fire.real")
    end)
end)
