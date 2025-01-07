-- Import necessary modules and set up an icon theme
local beautiful = require("beautiful")
local wibox = require("wibox")
local helpers = require("helpers")
local mods = require("mods")
local icon_theme = mods.icon_theme(beautiful.icon_theme)
local dpi = require("beautiful").xresources.apply_dpi
local overflow = require("mods.overflow")

-- Define the main function
return function()
    -- Create an empty widget with a horizontal layout and a specific spacing
    local elems = wibox.widget({
        layout = overflow.horizontal(),
        spacing = dpi(33),
        id = "switcher",
    })

    -- Initialize a variable to keep track of the currently selected client
    local curr = 0

    -- Define a helper function to get the icon for a client
    local extract_icon = function(c)
        -- Check if the client has a class and if it's "st", return the path to the icon for that class
        if c.class then
            if string.lower(c.class) == "st" then
                return icon_theme:get_icon_path(string.lower(c.class))
            end
        end

        -- If not, try to get the client's icon path
        return icon_theme:get_client_icon_path(c)
    end

    -- Define the main part of the function
    local function createElement(fn)
        -- Reset the widget and get all the clients
        fn = fn or ""
        elems:reset()

        local clients = client.get()
        local sortedClients = {}

        -- Sort the clients so that the currently focused client is first
        if client.focus then
            sortedClients[1] = client.focus
        end

        for _, client in ipairs(clients) do
            if client ~= sortedClients[1] then
                table.insert(sortedClients, client)
            end
        end

        -- For each client, create a widget that includes the client's icon and name
        curr = curr
        for _, client in ipairs(sortedClients) do
            local widget = wibox.widget({
                {
                    {
                        {
                            {
                                id = "clienticon",
                                valign = "center",
                                halign = "center",

                                image = client.icon or extract_icon(client),
                                widget = wibox.widget.imagebox,
                            },
                            widget = wibox.container.margin,
                            margins = dpi(2),
                            forced_height = dpi(108),
                            forced_width = dpi(108),
                        },
                        {
                            {
                                id = "name",
                                halign = "center",
                                text = client.name,
                                widget = wibox.widget.textbox,
                            },
                            widget = wibox.container.constraint,
                            width = dpi(108),
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
                shape = helpers.rrect(),
                widget = wibox.container.background,
                bg = beautiful.bg3 .. "66",
            })
            -- Add this widget to the main widget
            elems:add(widget)
        end

        -- If "next", change the background color of the currently selected client and move the selection to the next client
        if fn == "next" then
            if curr >= #sortedClients then
                curr = 1
            else
                curr = curr + 1
            end
            for i, element in ipairs(elems.children) do
                if i == curr then
                    element.bg = beautiful.fg3 .. "88"
                else
                    element.bg = beautiful.bg3 .. "00"
                end
            end
        -- If "raise", bring the currently selected client to the front and reset the selection
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

        -- Return the main widget
        return elems
    end

    -- Connect several signals to the createElement function
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

    -- Return the main widget
    return elems
end
