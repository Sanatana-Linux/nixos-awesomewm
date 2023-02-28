-- LuaRocks configuration

rocks_trees = {
   { name = "user", root = home .. "/.luarocks" };
   { name = "system", root = "/home/tlh/.config/awesome/libraries/luajit" };
}
lua_interpreter = "lua";
variables = {
   LUA_DIR = "/home/tlh/.config/awesome/libraries/luajit";
   LUA_BINDIR = "/home/tlh/.config/awesome/libraries/luajit/bin";
}
