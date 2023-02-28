# Luajit
-----

Instead of giving you a list of luarocks dependencies to install in the `README.md` or surprising you with an error, I have included in the configuration the entirety of the `luarocks` directory tree with the necessary dependencies included. Since this is within the configuration directory, AwesomeWM will see these all when the configuration is loaded and thus no issues should arise due to them...  I hope.

| Package       | Functionality Provided                                     |
| ------------- | ---------------------------------------------------------- |
| luaposix      | POSIX bindings easing use of various shell functionalities |
| luasec        | OpenSSL support for luasocket                              |
| luasocket     | provides network support for lua                           |
| luacheck      | error checking for development                             |
| luafilesystem | critical file system access from within lua                |
| argparse      | a dependency of multiple other lua packages                |
| lpeg          | parses expression grammars for lua                         |
| fzy-lua | fuzzy finder utility bindings |

## Set Up Process

In case you delete this subdirectory and then do find utility in having these plugins locally available after all, it is easy enough to re-implement it using the following commands in terminal, assuming you have pip installed.

```bash

pip install hererocks

cd ~/.config/awesome

hererocks luajit -j2.0.5 -rlatest

source luajit/bin/activate

luarocks install luaposix

luarocks install luasec

luarocks install luacheck

luarocks install luafilesystem

luarocks install argparse

luarocks install lpeg

luarocks install fzy

luarocks install luasocket 

```

Now these dependencies will be located in `~/.config/awesome/libraries/luajit/lib/lua/5.1` and `~/.config/awesome/libraries/luajit/share/lua/5.1` if you need to link to them directly though thanks to awesome combing the configuration directory, it should `just work` from the above.
