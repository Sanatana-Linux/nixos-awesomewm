# Bindings

The files contained with this sub-directory (sub-sub-directory really) contain the keybindings I use to interact with the system. They are highly idiosyncratic, based on what keys I find most suited to my tastes and which I can remember, as one would naturally expect of any such interface enabling an individul to intneract with a tool that they use constantly.

These bindings are broken up into categories as much a product of the idiosynratic impulses that caused me to map the bindings themselves as the classifications inherited from the upstream AwesomeWM API's ways of classifying elements that collectively compose AwesomeWM. Therefore, in order to aid in the understanding of any interested third party or myself if I return to this code at some later date with some unpredictable set of misfortunes and traumas that strip me of my memory of this relatively arbitrary taxonomy, I have listed the categories and provided a description of their contents below.


## Keybindings Taxonomyy


| Cateogory | File          | Description                                                                                                |
| --------- | ------------- |------------------------------------------------------------------------------------------------------------|
| awesome   | ./awesome.lua | Keybindgs of system-wide relevance or which interact with the Awesome API or a custom signal I have set up |
| client | client.lua | These apply to the client windows managed by awesome |
| focus | focus.lua | Apply to shifting focus between client windows |
| hardware_functions | hardware_functions.lua | Apply to hardware specific keys that control some aspect of the hardware's operation, like brightness |
| init | init.lua | This simply calls the other files, enabling the whole group to be called by the sub-directories name |
| layout | layout.lua | relate to how the client windows are presented on the screen |
| mouse | mouse.lua | These bind the various buttons of the mouse to various functions, notably excluding the scroll wheel in this case |
| tags | tags.lua | Relate to the workspaces that one may place client windows on, which I do not group by application type |


## Keybinding Cheatsheet

If at any point, you canot remember a keybinding or need to learn them in the first place but are adverse to looking at te source code to deduce as much, you can press `Mod4/Windows Key` and `F1`  to display the keybindings help popup included with AwesomeWM. Of course, it is styled to match the overall look and feel of the configuration but is otherwise blissfully not being substantially modified in this configuration.
