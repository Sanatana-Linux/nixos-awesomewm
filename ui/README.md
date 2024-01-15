# UI

This directory contains the modules and widgets that the user interacts with on screen. This includes the status bar revealed when the cursor is moved to the screen's bottom edge and all of its components, including pop-up menus that emerge from pressing buttons on that bar.

## On the Repository's Directory Scaffolding 

Comparative to the style of modular configuration that takes more directly from the `glorious dotfiles` structure, this subdirectory combines the `layout/` and `widget/` subdirectories into a single directory, a strategy inspired by the configuration of the venerable `JavaCafe01`. In this particular configuration, the reason for opting for this particular combination subdirectory is due to the nesting of the widgets associated with various pieces of the UI within the directory that UI module is defined. If it is something that is going to be reused, it is placed within the `utilities/` subdirectory (itself inspired by the `helper.lua` files common to other configurations). I find having either nested widgets or globally scoped utilities makes it easier to maintain and modify the UI and thus `it is what it is`. 

This may not be the most logical for other configurations, I advise each person do what makes the most sense to them individually as they individually will be using the resulting GUI interface and maintain it when it breaks, so `whatever's clever for you, you do.`

## Contents

| File or Directory | Description |
|-------------------|-------------|
| bar/ | the wibar at the bottom of the screen and its widgets | 
| launcher/ | system menu extracted that would be within `bar/` but for its complexity |
| menu/ | the menu when you right click on an empty space on the screen | 
| notifications/ | the status alerts that applications indicate state changes with at the worst times | 
| popups/ | various interfaces for performing various tasks, like networking |
| layoutbox |  
