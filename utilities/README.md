# Utilities

These files take the place of the `helpers.lua` functions used in other repositories and in many cases are derived from functions found in other repositories adapted to this one and its intended goals.

## Contents

The files within this directory are mostly anonymous functions that are attached to the `utilities.` namespace in the `init.lua` file that returns the file as the name it is saved as such that `utilities.scrollbox` will call the function in the `utilities/scrollbox.lua` file.

**Note**: These files are called before the global variables are called, thus cannot have the library/module calls stripped from the beginning of the file like other files in this configuration (making them more portable and somewhat more onerous to write)

| File                 | Functionality                                            |
| -------------------- | -------------------------------------------------------- |
| add_buttons          | adds button events to widget                             |
| add_hover            | adds hover effects to widget                             |
| apply_transition     | adds transitions events to widget                        |
| capitalize           | capitalizes string                                       |
| color                | color helpers                                            |
| color2               | alternative color helpers                                |
| complex_capitalizing | capitalizing in more nuanced ways ;]                     |
| crop_surface         | crop an image's outline within widget                    |
| dropdown             | creates scratchpad for quake-like terminal functionality |
| get_colorized_markup | colorizes string                                         |
| icon_theme           | provide icon theme to use for taglist/tasklist combo     |
| limit_by_length      | limit the length of a string to fit a widget             |
| make_popup_tooltip   | creates hover popup tooltips for wibar buttons           |
| mkbtn                | create a styled button widget                            |
| mkroundedcontainer   | create container with rounded edges                      |
| mkroundedrect        | creates a consistent rounded rectangle shape             |
| overflow             | container with scrolling overflow                        |
| pointer_on_focus     |  ccchange lin                                                        |
| screenshot           |                                                          |
| snap_edge            |                                                          |
| trim                 |                                                          |
| vertical_pad         |     padding along vertical access                                                     |
