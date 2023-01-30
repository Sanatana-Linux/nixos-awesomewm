-- add hover support to wibox.container.background-based elements


local apply_transition=require('utilities.apply_transition')

return function (element, bg, hbg)
  local transition = apply_transition {
      element = element,
      prop = 'bg',
      bg = bg,
      hbg = hbg,
  }

  element:connect_signal('mouse::enter', transition.on)
  element:connect_signal('mouse::leave', transition.off)

  return transition
end