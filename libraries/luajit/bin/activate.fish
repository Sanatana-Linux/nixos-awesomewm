if functions -q deactivate-lua
    deactivate-lua
end

function deactivate-lua
    if test -x '/home/tlh/.config/awesome/libraries/luajit/bin/lua'
        eval ('/home/tlh/.config/awesome/libraries/luajit/bin/lua' '/home/tlh/.config/awesome/libraries/luajit/bin/get_deactivated_path.lua' --fish)
    end

    functions -e deactivate-lua
end

set -gx PATH '/home/tlh/.config/awesome/libraries/luajit/bin' $PATH
