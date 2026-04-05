local awful = require("awful")
local ruled = require("ruled")

ruled.client.append_rule({
    rule_any = {
        type = { "utility" },
        class = {
            "vlc",
            "firefox",
            "firefoxdeveloperedition",
            "firefox-nightly",
        },
    },
    properties = {
        disallow_autocenter = true,
    },
})

-- center client in parent
client.connect_signal("request::manage", function(c)
    if c.transient_for and not c.disallow_autocenter then
        awful.placement.centered(c, { parent = c.transient_for })
        awful.placement.no_offscreen(c)
    end
end)
