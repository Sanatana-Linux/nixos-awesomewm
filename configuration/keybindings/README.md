# Keybindings

The files in this subdirectory configure the keybindings I employ. Instead of using one or two files to configure all the keybindings for the client and root in a giant block of text, instead they are grouped in very rough categories, each within its own file. This helps make the process of finding and modifying them more seamless and makes it easier to read these files without going cross eyed from the wall of keybinding text that this part of the configuration would otherwise be. Below are the files and what is contained within them:

| File    | Contents                                                                      |
| ------- | ----------------------------------------------------------------------------- |
| awesome | keybindings that interact with Awesome in general or calling widgets/builtins |
| client  | Keybindings that interact with the currently focused client                   |
| focus   | keybindings for changing the focused client                                   |
| init    | single point of entry calling other files                                     |
| layout  | keybindings that modify the arrangement of clients on screen                  |
| tags    | Keybindings interacting with the presently displayed tag                      |
