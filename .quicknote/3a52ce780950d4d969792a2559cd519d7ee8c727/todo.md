# TO-DO Items






- [ ] TODO bloat elimination from the rebase and in general 
- [ ] TODO: Windows appearing bigger than workspace area issue

## Archived Items


- [x] DONE lint icons, remove unused, replace for specially chosen bold icons where practical or improves function recognition, etc
  - NOTE: Done due to rebasing and removing many, but not all, icons I would otherwise need to maintain
- [x] DONE: Eliminate bling configuration hold-overs from tabbar and mstab
  - NOTE: no need to have bling as a submodule any longer, nor are its remants filling variables with strings of `or`s for options not in the theme file
- [x] DONE: TabBar to single file in modules
  - NOTE: Used `pure` style that conforms to titlebar layout
- [x] DONE replace taglist to enable buttons/actions on items shown
- [x] DONE application menu animation
  - frustrated thus far, will load but now won't dismiss
  - refactored that nightmare of unnecessary features into a more compact form
- [x] DONE fix the screenshot popup loading time
  - NOTE somehow the connect_signal was also emitting the same signal, so it was removed and works as expected
- [x] DONE fix titlebar buttons
  - NOTE needed to use nerd font not font awesome // material fonts
  - NOTE ultimately moved to using SVG files, SVG scale better even with awesome having had issues with rendering them, they seem to be fine and I prefer having the additional fine-grained control over the icon
- [x] DONE add in proper error handling
- [x] DONE fix whatever is wrong with the launcher causing it to error out now that I have proper error handling
- [x] DONE controls to Notifications Popup
- [x] DONE fix mstab annoyance layout error
- [x] DONE - `plugins/rubato`, `modules/effects` and `modules/animations/instance` do the same thingx] TODO Main Menu stopped working?
  - long story short, call awful.menu.new() instead of file
  - [x] DONE normalize the various animations to use just one of these
- [x] DONE Main Menu stopped working?
  - long story short, call awful.menu.new() instead of file
- [x] DONE add in screen record
