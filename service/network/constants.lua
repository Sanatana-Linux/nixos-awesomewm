--- NetworkManager constants for the network service.
-- Pure data module plus NM lgi binding loading.
-- No D-Bus calls, no side effects beyond the initial NM probe.
-- @module service.network.constants

local lgi = require("lgi")

--- Load the NetworkManager GIR binding.
-- The NM variable is `nil` when the binding is unavailable (no lgi.NM,
-- missing permissions, headless boot). Submodules check this before
-- calling NM-specific functions.
local NM
do
    local ok, mod = pcall(function()
        return lgi.NM
    end)
    if ok then
        NM = mod
    else
        pcall(function()
            require("gears.debug").print_warning(
                "service.network: NetworkManager GIR not available; service disabled"
            )
        end)
    end
end

local constants = {}
constants.NM = NM

--- Numeric state constants exposed by NetworkManager. Mirrors `NM.State` enum.
constants.NMState = {
    UNKNOWN = 0,
    ASLEEP = 10,
    DISCONNECTED = 20,
    DISCONNECTING = 30,
    CONNECTING = 40,
    CONNECTED_LOCAL = 50,
    CONNECTED_SITE = 60,
    CONNECTED_GLOBAL = 70,
}

constants.DeviceType = {
    ETHERNET = 1,
    WIFI = 2,
}

constants.DeviceState = {
    UNKNOWN = 0,
    UNMANAGED = 10,
    UNAVAILABLE = 20,
    DISCONNECTED = 30,
    PREPARE = 40,
    CONFIG = 50,
    NEED_AUTH = 60,
    IP_CONFIG = 70,
    IP_CHECK = 80,
    SECONDARIES = 90,
    ACTIVATED = 100,
    DEACTIVATING = 110,
    FAILED = 120,
}

--- Convert a NetworkManager device state integer to a human-readable string.
-- @tparam integer state DeviceState enum value (0..120)
-- @treturn string Human-readable state name, or `nil` if unknown
function constants.device_state_to_string(state)
    local device_state_to_string = {
        [0] = "Unknown",
        [10] = "Unmanaged",
        [20] = "Unavailable",
        [30] = "Disconnected",
        [40] = "Prepare",
        [50] = "Config",
        [60] = "Need Auth",
        [70] = "IP Config",
        [80] = "IP Check",
        [90] = "Secondaries",
        [100] = "Activated",
        [110] = "Deactivated",
        [120] = "Failed",
    }

    return device_state_to_string[state]
end

--- Convert a NetworkManager device type integer to a human-readable string.
-- @tparam integer dtype DeviceType enum value (1 = Ethernet, 2 = WiFi)
-- @treturn string Human-readable device type, or `"Unknown"` if unrecognised
function constants.device_type_to_string(dtype)
    local device_type_to_string = {
        [1] = "Ethernet",
        [2] = "WiFi",
    }
    return device_type_to_string[dtype] or "Unknown"
end

return constants
