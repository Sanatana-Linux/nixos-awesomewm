local beautiful = require("beautiful")
local wibox = require("wibox")
local icon_theme = modules.icon_theme(beautiful.icon_theme)

return function()
    local elems = wibox.widget({
        layout = modules.overflow.horizontal(),
        spacing = 20,
        id = "switcher",
    })

    local curr = 0
    local extract_icon = function(c)
        -- exceptions (add support for simple terminal and many mores).
        if c.class then
            if string.lower(c.class) == "st" then
                return icon_theme:get_icon_path(string.lower(c.class))
            end
        end

        -- has support for some others apps like spotify
        return icon_theme:get_client_icon_path(c)
    end

    local function createElement(fn)
        fn = fn or ""
        elems:reset()

        local clients = client.get()
        local sortedClients = {}

        if client.focus then
            sortedClients[1] = client.focus
        end

        for _, client in ipairs(clients) do
            if client ~= sortedClients[1] then
                table.insert(sortedClients, client)
            end
        end

        curr = curr
        for _, client in ipairs(sortedClients) do
            local widget = wibox.widget({
                {
                    {
                        {
                            {
                                id = "icon",
                                valign = "center",
                                halign = "center",

                                image = client.icon or extract_icon(client),
                                widget = wibox.widget.imagebox,
                            },
                            widget = wibox.container.margin,
                            margins = dpi(2),
                            forced_height = dpi(48),
                            forced_width = dpi(48),
                        },
                        {
                            {
                                id = "name",
                                halign = "center",
                                text = client.name,
                                widget = wibox.widget.textbox,
                            },
                            widget = wibox.container.constraint,
                            width = dpi(84),
                            height = dpi(24),
                        },
                        spacing = 5,
                        layout = wibox.layout.fixed.vertical,
                    },
                    widget = wibox.container.margin,
                    margins = dpi(20),
                },
                -- forced_height = dpi(96),
                -- forced_width = dpi(108),
                shape = utilities.widgets.mkroundedrect(),
                widget = wibox.container.background,
                bg = beautiful.dimblack .. "66",
            })
            elems:add(widget)
        end

        if fn == "next" then
            if curr >= #sortedClients then
                curr = 1
            else
                curr = curr + 1
            end
            for i, element in ipairs(elems.children) do
                if i == curr then
                    element.bg = beautiful.grey .. "88"
                else
                    element.bg = beautiful.dimblack .. "00"
                end
            end
        elseif fn == "raise" then
            local c = sortedClients[curr]
            if c ~= nil then
                if not c:isvisible() and c.first_tag then
                    c.first_tag:view_only()
                end
                c:emit_signal("request::activate")
                c:raise()
            end
            curr = 0
        end

        return elems
    end

    elems = createElement()

    awesome.connect_signal("window_switcher::next", function()
        elems = createElement("next")
    end)

    awesome.connect_signal("window_switcher::raise", function()
        elems = createElement("raise")
    end)

    awesome.connect_signal("window_switcher::update", function()
        elems = createElement("raise")
    end)

    client.connect_signal("manage", function()
        elems = createElement()
    end)

    client.connect_signal("unmanage", function()
        elems = createElement()
    end)

    return elems
end
