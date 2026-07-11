# Lua 5.1 / 5.4 Language Reference

**Source**: Context7 MCP — /websites/lua
**Fetched**: 2026-07-01
**TTL**: 7 days

## Module System (require/package.path)

```lua
-- require lookup order:
-- 1. package.preload[name]
-- 2. Searches package.path for Lua files
-- 3. Searches package.cpath for C libraries
package.path = "/path/to/?.lua;" .. package.path
package.cpath = "/path/to/?.so;" .. package.cpath

-- Loading pattern:
local mymodule = require("mymodule.sub")
-- Searches: mymodule/sub.lua on package.path
```

## Metatable System

Metatables control behavior of tables via metamethods:

```lua
local mt = {
    __index = function(table, key) return default end,
    __newindex = function(table, key, value) rawset(table, key, value) end,
    __call = function(table, ...) end,
    __tostring = function(table) return "..." end,
    __gc = function(table) end,  -- Lua 5.2+
}
setmetatable(table, mt)
```

## C API (relevant for LuaJIT FFI)

### Metatable Registration (C side)
```c
// Create named metatable
int luaL_newmetatable(lua_State *L, const char *tname);

// Get existing metatable
void luaL_getmetatable(lua_State *L, const char *tname);

// Type-check userdata
void *luaL_checkudata(lua_State *L, int index, const char *tname);
void *luaL_testudata(lua_State *L, int index, const char *tname);  -- non-error version
```

### Module Registration
```c
// Like require() but with C function
void luaL_requiref(lua_State *L, const char *modname,
                   lua_CFunction openf, int glb);
// If glb true, also sets _G[modname] = module
```

## Coroutines

```lua
co = coroutine.create(function()
    local val = coroutine.yield("waiting")
    return "done with " .. val
end)
status, result = coroutine.resume(co, "input")
```

## Key Idioms

```lua
-- Guard clause
if not x then return end

-- Default parameter
local function fn(x)
    x = x or default
end

-- Pattern matching
string.match(str, "^(%w+)")
string.gsub(str, pattern, replacement)

-- Table as object
local obj = {}
function obj:method(args) end
-- Equivalent: obj.method(self, args)
```
