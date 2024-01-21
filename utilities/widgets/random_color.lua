return function()
  local accents = {
    beautiful.magenta,
    beautiful.yellow,
    beautiful.green,
    beautiful.red,
    beautiful.blue,
    beautiful.aqua,
  }
  local i = math.random(1, #accents)
  return accents[i]
end
