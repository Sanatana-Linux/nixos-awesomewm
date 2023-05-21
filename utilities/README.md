# Utilities 

Other configurations tend to call these helpers and include them in a single file. I prefer to call them using the `utilities.` namespace which is made available globally and write them as anonymous functions in their own files for organizational purpose. Those of minimal utility (pun intended) in the configuration I do tend to eliminate when/if they give me trouble or I remember to do so, others I intend to use more but haven't fully implemented and the rest are widely implemented across the configuration (especially `mkroundedrect`)


> Many of these, like a lot of bits and pieces are originally something I have gathered from other configurations and contorted into a shape that is of my own making and documented for my own understanding but I am grateful to the original authors nonetheless and encourage others to help themselves of course. 


| Utility              | Functionality                                            |
| -------------------- | -------------------------------------------------------- |
| add_buttons          | adds button events to widget                             |
| add_hover            | adds hover effects to widget                             |
| apply_transition     | adds transitions events to widget                        |
| capitalize           | capitalizes string                                       |
| color                | color helpers                                            |
| color2               | alternative color helpers                                |
| complex_capitalizing | capitalizing in more nuanced ways                        |
| crop_surface         | crop an image's outline within widget                    |
| dropdown             | creates scratchpad for quake-like terminal functionality |
| get_colorized_markup | colorizes string                                         |
| icon_handler         | Handling for individual icons, rounds out icons nicely   |
| icon_theme           | provide icon theme to use for taglist/tasklist combo     |
| limit_by_length      | limit the length of a string to fit a widget             |
| make_popup_tooltip   | creates hover popup tooltips for wibar buttons           |
| mkbtn                | create a styled button widget                            |
| mkroundedcontainer   | create container with rounded edges                      |
| mkroundedrect        | creates a consistent rounded rectangle shape             |
| overflow             | container with scrolling overflow                        |
| pointer_on_focus     | changes cursor over various widgets                      |
| screenshot           | screenshots + dialog with copy and delete function       |
| snap_edge            | window snapping for floating clients                     |
| trim                 | trims string length for display in limited spaces        |
| vertical_pad         | padding along vertical access                            |
