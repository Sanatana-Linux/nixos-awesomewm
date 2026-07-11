# LuaJIT FFI Library Reference

**Source**: Context7 MCP — /luajit/luajit
**Fetched**: 2026-07-01
**TTL**: 7 days

## Overview

The FFI library allows calling external C functions and using C data structures directly from pure Lua code. Parses plain C declarations — no manual Lua/C bindings needed. Tightly integrated into LuaJIT, generates C-level performance.

## Loading

```lua
local ffi = require("ffi")
```

## Declaring C Types and Functions

```lua
ffi.cdef([[
typedef struct foo { int a, b; } foo_t;
int dofoo(foo_t *f, int n);
]])
```

- C declarations are NOT passed through a C pre-processor
- Replace `#define` with `enum`, `static_const`, or `typedef`
- External symbols aren't bound until a C library namespace is used

## Accessing C Libraries

```lua
ffi.C  -- Default C library namespace (linked symbols)
```

## Key Features

- **ffi.cdef(def)** — Adds multiple C declarations (types + external symbols). String containing C declarations separated by semicolons
- **ffi.C** — C library namespace for accessing declared external symbols
- Parser accepts standard C declarations
- Use Lua's `[[ ... ]]` syntax for multi-line C declarations
