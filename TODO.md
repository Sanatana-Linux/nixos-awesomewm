# TODO LIST

**NOTE:** When an item is finished, switch the `[  ]` to `[x]` **AND change the `TODO` to `DONE`.**

- [x] DONE now that the wibar hides without disturbing the arrangement of the other things on screen (clients in that case), it should be made taller by ~100% its present height
- [x] DONE adjust the height of the buttons and placement of their contents to account for this
- [x] DONE the animation library is a complete, badly documented and clunky cluster fuck that needs to be polished up, documented and written in code that is less autistic
- [x] DONE bluetooth menu
  - [x] DONE keep SVG icons (user confirmed)
  - [x] DONE handle rfkill soft-blocked state - bluetooth shows "Powered: no, PowerState: off-blocked"
- [x] DONE wifi menu
  - [x] DONE no icons on buttons
  - [x] DONE non-functional backend state
- [x] DONE change font to OperatorUltraNerdFontComplete Nerd Font Propo

- [x] DONE abstract common page structure for wifi and bluetooth to module/ file
- [x] DONE abstract common button on control panel style to module/ file

- [x] DONE create a backdrop component that is placed behind the popup windows
  - [x] DONE it should be semi-transparent black, something like #00000088
  - [x] DONE clicking it should also close the popups like clicking outside of them should already
  - [x] DONE when the popup hides, the backdrop should always hide as well
  - [x] DONE either a blur should be applied in awesome or if picom must do this, it should be given a property allowing it to be targeted specifically.

- [x] DONE change the hardcoded generic icon for the task manager to be one pulled from improved fallback icon
  - [x] DONE use the same icon in the applauncher menu for applications without an icon

- [x] DONE Fix notifications background to be the same color/opacity as the wibar
- [x] DONE notification close button should be like the titlebar button in style
- [x] DONE the buttons for the screenshot mode selection should be the same background+effects as the taglist+tasklist buttons for each tag and should have the same border effects
  - [x] DONE The screenshot notification buttons offering the various additional functions like "animate" should be larger, more spaced apart and have tooltips describing their functionality in case it is cut off.

- [x] DONE There are quirks that need ironing out in the mstab layout, like when switching between "slaves" in the stack, often the window getting focus will not occupy the entire "slave" side but but 10% in the center of the slave stack.
  - [x] DONE hovering the items stacked on top of each other that are listed in the titlebar specific to this layout should have tooltips providing the entire name of the window being hovered

- [x] DONE Sometimes windows that are not kitty windows summoned by the scratchpad will come to replace kitty when the scratchpad keybinding is toggled, this is not desirable at all

- [x] DONE create a file in .cache/awesome/ to cache the history of the notifications
  - [x] DONE have the notification list in the control panel read from the list of cached notifications
  - [x] DONE have the clear notifications button erase the cache files content and have popup "Are you sure" dialogue

- [x] DONE Add gaps between windows and the edges of the screen equaling dpi(3)

- [x] DONE abstract out modules for the common features shared by multiple UI elements and then swap out the hardcoded settings for these new abstracted modules

- [x] DONE power menu doesn't work, it just produces an error

- [x] DONE sliders glitch and skip, likely need a delay on them to make the transition more smooth and less error prone

- [x] DONE make a proper test file for debugging purposes to replace the symlink to rc.lua

- [x] DONE Make the Bluetooth and Network applets on the control panel the same background color as the sliders and the border should be fg_alt for the buttons and boxes for the sliders

- [x] DONE make the backdrop slightly darker and apply a blur effect

- [x] DONE remove the goofy color styling (except the red for the power button only when hovered) from the power menu buttons and style them as the wibar buttons are styled.

- [x] DONE apply window gaps to maximized windows of dpi(3) on all sides of the screen

- [x] DONE change the "core" directory to "configuration" and update the various require statements adjusting for this change

- [x] DONE make sure all the files within the modules directory are themsekves within their own subdirectories

- [ ] TODO improve the custom layout files internal logic and refactor each where necessary and useful to make them more effective in achieving their intended layouts while being written in readily understood and non-esoteric fully documented code

- [x] DONE change the png layout icons to the svg equivalents that are located in the same folder then remove the png versions.
