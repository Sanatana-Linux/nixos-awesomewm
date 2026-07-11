# LuaRocks Reference

**Source**: Context7 MCP — /luarocks/luarocks
**Fetched**: 2026-07-01
**TTL**: 7 days

## Overview

LuaRocks is the package manager for Lua. Installs Lua modules as self-contained packages ("rocks"). Supports local and remote repositories, multiple local rock trees.

## Key Commands

```bash
luarocks install dkjson         # Install a package (rock)
luarocks install luasocket      # Install with dependencies auto-resolved
luarocks list                   # List installed rocks
luarocks search <query>         # Search remote repository
luarocks remove <package>       # Remove a rock
```

## Rockspec Format

A rockspec defines package metadata, source, dependencies, and build instructions:

```lua
package = "PackageName"
version = "1.0-1"
source = {
   url = "git://github.com/me/repo",
   tag = "v1.0",
}
description = {
   summary = "Short description.",
   homepage = "http://example.com",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1, < 5.4",
   "dependency >= 2.3"
}
build = {
   type = "builtin",
   modules = {
      mymodule = "src/mymodule.lua",
      mymodule.sub = "src/mymodule/sub.lua",
   },
   copy_directories = { "doc", "test" }
}
```

## Loading in AwesomeWM

```lua
pcall(require, "luarocks.loader")
-- If LuaRocks is installed, makes rock packages findable via require()
```

## Build Types

- **builtin** — Simple Lua modules, no compilation
- **make** — Uses Makefile
- **cmake** — Uses CMake
- **command** — Custom build command
