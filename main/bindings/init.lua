-- Call the bindings broken into thematic files  to ease maintainability and keep my sanity whole when adding new bindings

local function set_keybindings()
    require("main.bindings.awesome")
    require("main.bindings.custom_bindings")
    require("main.bindings.client")
    require("main.bindings.focus")
    require("main.bindings.layout")
    require("main.bindings.mouse")
    require("main.bindings.tags")
end

set_keybindings()
