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

- [x] DONE change the png layout icons to the svg equivalents that are located in the same folder then remove the png versions.

- [x] DONE the configuration/error and configuration/notification seem redundant given both could be included within the configuration/notification directory and called together by the directory wide init file

- [x] DONE The icons for the launcher and the control panel should be larger than at present and more like the layout button icon in terms of how much of the buttonn they cover.

- [x] DONE the module creating the backdrop must be placed behind any instance of the launcher, comntrol panel, calendar or the system statistics popups being displayed and still click outside of the popups must still close them

- [x] DONE the search text that the user is able to search for applications via the launcher must have more padding (background color the text is typed in) by 20% top-bottom at least and right until almost the edge of the image it is place atop.

- [x] DONE make the black background of the window switcher partially transparent, raise minimized windows as they are cycled through, do not include the windows on other tags, make it so upon hitting enter, the current window selected by the window switcher is brought into focus as the switcher closes

- [x] DONE add a lowb battery notifier via the configuration/notifications/battery.lua
- [x] DONE improve the custom layout files internal logic and refactor each where necessary and useful to make them more effective in achieving their intended layouts while being written in readily understood and non-esoteric fully documented code
- [x] DONE the clear all notifications confirmation dialogue is not dismissed when either button is pressed nor do all the notifications get cleared if that button is pressed, just some
- [x] DONE clearing notifications produces an error creating 2 more notifications.
  - [x] DONE in ui/popups/ there is screenshot_popup.lua that should be screenshot_popup/init.luia
  - [x] DONE there is a configuration/screen.lua that should instead be configuration/screen/init.lua
- [x] DONE the services/ directory uses [functionality].lua files that should all instead be [functionality]/init.lua
- [x] DONE make the titlebar's background the same as the control panel popup
- [x] DONE to indicate the focused windpw the border should be the same color and width as the control_panel popup then become darker when not focused
- [x] DONE modify the keybinding list to gave the following traits both by modifying the hotkeys_popup lua file and by insuring the hotkeys are appropriately categorized in their actual definitions:
  - [x] DONE reimplement the group labeling for the hotkeys
  - [x] DONE Give each group its own page which are navigated between when the popup is opened with the arrow left and arrow right keys as well as the j and k keys
  - [x] DONE the popup's label for each group should have the background be one of the colors in theme (not gray) and the foreground be the popup's background without the transparency
  - [x] DONE the popup should have the same transparent background + blur and shadow as is seen with. It should use the spame border as the control panel popup
- [x] DONE there is a configuration/notification and a ui/notification, this is redundant and annoying, consolidate them into a single location at ui/notification without removing any functionality of either

- [x] DONE Change the image behind the application launcher's input bar to not be the wallpaper (as it is at present) but to be the "wallpaper-unbranded.png" image in the same directory as the current wallpaper.

- [x] DONE the Keybindings Popup that is raised with mod4+f1 is still nonfunctional, which when it functions correctly will have the following traits:
  - [x] DONE each of the "categories" of keybindings will be a separate page
  - [x] DONE navigation between the pages will be done with left and right arrows when the popup is open
  - [x] DONE clicking outside the popup, pressing escape or repeating the launch hotkeys will close it
  - [x] DONE Each page will have the title text, hotkety popup window border, modifier keys, etc elements in a different one of the configured not-monochromatic colors specific to it

- [x] DONE change the launcher and control panel buttons to use a black border until hovered when the border should become white with the same width as the taglist/tasklist button borders
- [x] DONE change the taglist/tasklist buttons to have a white border when hovered
- [x] DONE provide the same button effects to the time, layout, systray and battery buttons

- [x] DONE NONE OF THE SYSTEM STATUS ARC CHARTS ARE DISPLAYING ANY LIVEFEED LOAD PERCENTAGES, ALL SAY 0% (fixed animation easing function and callback parameter order in arc_chart module)
- [x] DONE make battery button show the remaining percentage as text overlaid on top of the battery icon
- [x] DONE if no battery is detected during start up, the icon where the battery is should display an arc chart showing CPU load like the popup clicking it shows
