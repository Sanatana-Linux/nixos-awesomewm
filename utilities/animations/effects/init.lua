-- https://pastebin.com/tUwH0Ktn
local M = {}
 
local effects = {
  { require("utilities.animations.effects.tagswitch"), "tagswitch" }
}
 
M.request_effect = function (name)
  for _, e in ipairs(effects) do
    if name == e[2] then
      return e[1]
    end
  end
 
  return false
end
 
return M