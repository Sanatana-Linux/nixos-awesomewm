--- Spec for the battery service's `key=value` parser.
-- The refactored battery service reads all sysfs fields in one shell call and
-- parses the output as `key=value` lines. This spec verifies the parser.
--
-- The test runs the actual shell command in a sandboxed subdirectory to avoid
-- touching real `/sys/class/power_supply/BAT0/` data on the host.

local assert = require("tests.assert")
local runner = ...

-- Mirror of the production parser.
local function parse_kv(line)
    local k, v = line:match("^([^=]+)=(.*)$")
    if not k then
        return nil, nil
    end
    return k, v
end

runner.describe("battery:parse_kv", function()
    runner.it("parses simple key=value", function()
        local k, v = parse_kv("capacity=78")
        assert.eq(k, "capacity")
        assert.eq(v, "78")
    end)

    runner.it("preserves trailing whitespace in value", function()
        local k, v = parse_kv("status=Discharging\n")
        assert.eq(k, "status")
        assert.eq(v, "Discharging\n")
    end)

    runner.it("returns nils for lines without an equals sign", function()
        local k, v = parse_kv("not a key value pair")
        assert.eq(k, nil)
        assert.eq(v, nil)
    end)

    runner.it("handles empty values", function()
        local k, v = parse_kv("empty=")
        assert.eq(k, "empty")
        assert.eq(v, "")
    end)
end)

runner.describe("battery:polling cmd output", function()
    -- Run the real shell pipeline against a fake sysfs tree and verify
    -- the parser extracts all expected fields.
    runner.it("extracts all fields from a fake BAT0", function()
        local tmp = os.tmpname()
        os.execute("rm -f " .. tmp .. " && mkdir -p " .. tmp)
        -- Write fake sysfs files
        local f = io.open(tmp .. "/capacity", "w")
        f:write("78\n")
        f:close()
        local f = io.open(tmp .. "/status", "w")
        f:write("Discharging\n")
        f:close()
        local f = io.open(tmp .. "/health", "w")
        f:write("Good\n")
        f:close()
        local f = io.open(tmp .. "/voltage_now", "w")
        f:write("12500000\n")
        f:close()

        -- Mirror POLL_CMD
        local cmd = string.format(
            [[
for f in capacity status health voltage_now; do
    if [ -r "%s/$f" ]; then
        printf '%%s=%%s\n' "$f" "$(cat '%s'/"$f" 2>/dev/null)"
    fi
done]],
            tmp,
            tmp
        )
        local pipe = io.popen(cmd)
        local output = pipe:read("*a")
        pipe:close()

        local got = {}
        for line in output:gmatch("[^\n]+") do
            local k, v = parse_kv(line)
            if k then
                got[k] = v
            end
        end

        assert.eq(got.capacity, "78")
        assert.eq(got.status, "Discharging")
        assert.eq(got.health, "Good")
        assert.eq(got.voltage_now, "12500000")

        os.execute("rm -rf " .. tmp)
    end)
end)
