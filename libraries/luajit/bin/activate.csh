which deactivate-lua >&/dev/null && deactivate-lua

alias deactivate-lua 'if ( -x '\''/home/tlh/.config/awesome/libraries/luajit/bin/lua'\'' ) then; setenv PATH `'\''/home/tlh/.config/awesome/libraries/luajit/bin/lua'\'' '\''/home/tlh/.config/awesome/libraries/luajit/bin/get_deactivated_path.lua'\''`; rehash; endif; unalias deactivate-lua'

setenv PATH '/home/tlh/.config/awesome/libraries/luajit/bin':"$PATH"
rehash
