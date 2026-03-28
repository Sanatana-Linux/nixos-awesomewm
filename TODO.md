- [x] TODO now that the wibar hides without disturbing the arrangement of the other things on screen (clients in that case), it should be made taller by ~100% its present height
- [x] TODO adjust the height of the buttons and placement of their contents to account for this

- [x] TODO the animation library is a complete, badly documented and clunky cluster fuck that needs to be polished up, documented and written in code that is less autistic

- [ ] TODO bluetooth menu
  - [ ] TODO no icons on buttons
  - [ ] TODO Not functional in connecting to bluetooth on the backend

- [ ] TODO wifi menu
  - [ ] TODO no icons on buttons
  - [ ] TODO non-functional backend state

- [ ] TODO change font to OperatorUltraNerdFontComplete Nerd Font Propo

- [ ] TODO create a backdrop component that is placed behind the popup windows
  - [ ] TODO it should be semi-transparent black, something like #00000088
  - [ ] TODO clicking it should also close the popups like clicking outside of them should already
  - [ ] TODO when the popup hides, the backdrop should always hide as well
  - [ ] TODO either a blur should be applied in awesome or if picom must do this, it should be given a property allowing it to be targeted specifically.

- [ ] TODO change the hardcoded generic icon for the task manager to be one pulled from /run/current-system/sw/share/icons/Papirus-Dark/64x64/apps/app.svg
  - [ ] TODO use the same icon in the applauncher menu for applications without an icon

- [ ] TODO Fix notifications background to be the same color/opacity as the wibar
  - [ ] TODO notification close button should be like the titlebar button in style
  - [ ] TODO the buttons for the screenshot mode selection should be the same background+effects as the taglist+tasklist buttons for each tag and should have the same border effects
  - [ ] TODO The screenshot notification buttons offering the various additional functions like "animate" should be larger, more spaced apart and have tooltips describing their functionality in case it is cut off.

- [ ] TODO There are quirks that need ironing out in the mstab layout, like when switching between "slaves" in the stack, often the window getting focus will not occupy the entire "slave" side but but 10% in the center of the slave stack.
  - [ ] TODO hovering the items stacked on top of each other that are listed in the titlebar specific to this layout should have tooltips providing the entire name of the window being hovered

- [ ] TODO Sometimes windows that are not kitty windows summoned by the scratchpad will come to replace kitty when the scratchpad keybinding is toggled, this is not desirable at all
