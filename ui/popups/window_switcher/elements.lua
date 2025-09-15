---@diagnostic disable: undefined-global
-- Import necessary modules and set up an icon theme
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local client = client
local dpi = require("beautiful").xresources.apply_dpi
local overflow = require("wibox.layout.overflow")
local shapes = require("modules.shapes")

-- Define the main function
return function()
    -- Create an empty widget with a horizontal layout and a specific spacing
    local elems = wibox.widget({
        layout = overflow.horizontal(),
        spacing = dpi(33),
        id = "switcher",
    })

    -- Initialize a variable to keep track of the currently selected client
    local curr = 1 -- Initialize to 1 for the first element to be selected

    local sortedClients = {} -- Declare sortedClients outside createElement

    -- Define the main part of the function
    local function createElement(fn)
        -- Reset the widget and get all the clients
        fn = fn or ""
        elems:reset()

        local clients = client.get()
        sortedClients = {} -- Reset sortedClients here

        -- Sort the clients so that the currently focused client is first
        if client.focus then
            sortedClients[1] = client.focus
        end

        for _, c in ipairs(clients) do
            if c ~= client.focus then
                table.insert(sortedClients, c)
            end
        end

        -- For each client, create a widget that includes the client's icon and name
        for i, c in ipairs(sortedClients) do
            local widget = wibox.widget({
                {
                    {
                        {
                            {
                                id = "clienticon",
                                valign = "center",
                                halign = "center",
                                widget = wibox.widget.imagebox,
                                image = require("menubar").utils.lookup_icon(
                                    c.class
                                )
                                    or require("menubar").utils.lookup_icon(
                                        "default-application-icon"
                                    )
                                    or awful.widget.clienticon,
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
                                text = c.name,
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
                forced_height = dpi(96),
                forced_width = dpi(108),
                shape = shapes.rrect(beautiful.border_radius or dpi(10)),
                widget = wibox.container.background,
                id = "background",
                bg = beautiful.bg_alt .. "66",
            })

            elems:add(widget) -- Add the created widget to the elems container
        end

        -- If "next", change the background color of the currently selected client and move the selection to the next client
        if fn == "next" then
            if #sortedClients == 0 then
                curr = 1 -- Reset the selection
            elseif curr >= #sortedClients then
                curr = 1
            else
                curr = curr + 1
            end

            for i, element in ipairs(elems.children) do
                if i == curr then
                    element.bg = beautiful.fg .. "88"
                else
                    element.bg = beautiful.bg_alt .. "66"
                end
            end
        -- If "previous", change the background color of the currently selected client and move the selection to the previous client
        elseif fn == "previous" then
            if #sortedClients == 0 then
                curr = 1 -- Reset the selection
            elseif curr <= 1 then
                curr = #sortedClients
            else
                curr = curr - 1
            end

            for i, element in ipairs(elems.children) do
                if i == curr then
                    element.bg = beautiful.fg .. "88"
                else
                    element.bg = beautiful.bg_alt .. "66"
                end
            end
            -- If "raise", bring the currently selected client to the front and reset the selection
        elseif fn == "raise" then
            if #sortedClients > 0 then
                local c = sortedClients[curr]
                if c then
                    if not c:isvisible() and c.first_tag then
                        c.first_tag:view_only()
                    end
                    c:emit_signal("request::activate")
                    c:raise()
                end
            end
            curr = 1 -- Reset the selection
        else
            -- Initial highlighting
            for i, element in ipairs(elems.children) do
                if #sortedClients > 0 and i == curr then
                    element.bg = beautiful.fg .. "88"
                else
                    element.bg = beautiful.bg_alt .. "00"
                end
            end
        end

        -- Return the main widget
        return elems
    end

    -- Connect several signals to the createElement function
    elems = createElement()

    awesome.connect_signal("window_switcher::next", function()
        elems = createElement("next")
    end)

    awesome.connect_signal("window_switcher::previous", function()
        elems = createElement("previous")
    end)

    awesome.connect_signal("window_switcher::raise", function()
        elems = createElement("raise")
    end)

    awesome.connect_signal("window_switcher::update", function()
        elems = createElement() -- Just update the list, don't reset selection
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
