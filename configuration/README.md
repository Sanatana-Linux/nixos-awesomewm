# Configuration

Here are the options and custom modes (in the case of Layouts) provided to AwesomeWM's builtin modules and widgets. Below is a table listing the contents of this sub-directory which explains the content of the files and sub-directories as well as what builtin functionality is being provided options specifically.

| File or Sub-Directory    | Functionality Provided or Builtin Being Configured                                                                                                  |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- | --- |
| `./keybindings/`         | Sub-Diretory containing files mapping keys combinations to various functions of AwesomeWM                                                           |
| `garbage_collection.lua` | Provides configuration to AwesomeWM's builtin garbage collection which reduces memory costs at expense of CPU cycles                                |
| `init.lua`               | default entrypoint initializing the rest of this sub-directory's contents when called in `rc.lua`                                                   |
| `layout.lua`             | Assigns default layouts to tags in the intended order the clients can be cycled                                                                     |
| `monitor.lua`            | handles restarting awesome if a new screen is connected during operation                                                                            |     |
| `mousebindings.lua`      | Provides mouse interaction and button mapping universally, which is later modified when various UI elements are interacted with                     |
| `rules.lua`              | Provides client rules in general and for clients with various xprop traits                                                                          |
| `theme.lua`              | initializes the custom theme for the configuration located at `../themes` and available using the `beautiful.` namespace                            |
| `variabled.lua`          | Unique approach to mitigate redundant boilerplate builtin/module calls at each files header, instead this file globally scopes the builtins/modules |

## If Adapting This Configuration

You will want/need to spend some time adjusting these configurations to suit your needs as these settings are very often related to one's workflow and personal preferences especially the keybindings which no two configurations are the same regarding as is and my idiocyncratic preferences there are sure to irritate most people.

If you add things you want to be globally scoped anywhere in your variant, add it to the variables file, called first it will insure that you can then refer to that added functionality from anywhere outside the `utilities/` aub-directory (called before this one) using the name assigned to the variable in that file.

In regards to the custom layout collection built up in my AwesomeWM flying spaghetti monster of code, I didn't place them in modules for my own convenience but doing this may make sense
