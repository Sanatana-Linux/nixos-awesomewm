# TO-DO Items

- [x] DONE add in screen record
  - [ ] TODO make screen recorder work'
    - [ ] TODO choose terminal application to use
    - [ ] TODO set it up in the screen recorder
    - [ ] TODO change screenshot menu to approximate the AWFUL dotfiles variant

- [ ] TODO lint icons, remove unused, replace for specially chosen bold icons where practical or improves function recognition, etc

- [ ] TODO incorporate all the necessary functionality then remove the plugins entirely, mitigating headaches and much bloat
- [ ] TODO: Eliminate bling configuration hold-overs from tabbar and mstab
- [ ] TODO: Windows appearing bigger than workspace area issue

## Archived Items

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
- [x] TODO Main Menu stopped working?
  - long story short, call awful.menu.new() instead of file
