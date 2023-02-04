
local beautiful = require 'beautiful'


local color = require 'modules.color'
local rubato = require 'modules.rubato'


return function(opts)
  opts = opts or {}

  local bg = opts.bg or beautiful.bg_lighter
  local hbg = opts.hbg or beautiful.black

  local element, prop = opts.element, opts.prop

  local background = color.color { hex = bg }
  local hover_background = color.color { hex = hbg }

  local transition = color.transition(background, hover_background, color.transition.RGB)

  local fading = rubato.timed { duration = 0.30 }

  fading:subscribe(function (pos)
      element[prop] = transition(pos / 100).hex
  end)

  return {
      on = function ()
          fading.target = 100
      end,
      off = function ()
          fading.target = 0
      end
  }
end