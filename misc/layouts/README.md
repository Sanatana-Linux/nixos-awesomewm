# Configuration/Tags/layouts

Yes, these are custom layouts, which are inspired by the noted projects in each
file. Like much else about this configuration, I have preferred to take
ownership of the code so that I could

    a. format the files to my liking
    b. modify the code to best fit into this configuration
    c. stabilize and ease maintence

## Layouts

| Layout        | Characteristics                                                                                                   |
| ------------- | ----------------------------------------------------------------------------------------------------------------- |
| cascade       | client windows are stacked behind main/current in tighter formation than deck                                     |
| cascade.tiled | tiles stack within the screen's workarea                                                                          |
| center        | center of the layout is most of the screen, additional windows on sides of the master client                      |
| deck          | stacks clients over one another like a hand of playing cards                                                      |
| equalarea     | each client gets an equal sized space on screen                                                                   |
| horizon       | creates a row for each client, stacking the windows on top of each other with the master being the largest.       |
| mstab         | Tabs like in the Microsoft (Windows?) since it is ms tab not m stab. Stack but with a tab bar for the secondaries |
| stack         | Two clients, with the master to the left and new windows stacking on the right (can be switched, check the code)  |
| thrizen       | <= 3 clients it is vertical, then creates a horizontal row.                                                       |
| vertical      | makes columns, then keeps making them leaving the primary with slightly more space than secondaries               |

## Please, Take These for Your Configuration

These should be pretty portable. Just add back in the module calls to Awesome's builtins that I have a global call for (specific scoping doesn't improve performance in my experience but global scoping the variables radically improves developer experience) and they should be easy to use in your configuration. These custom layouts are the crown jewel of this configuration for me as such is rather rare, outside of `bling` where many came from. Custom layouts have a lot of potential left unexploited, stack/mstab really has enhanced my productivity more than anything else since starting with WM tiling, let's see what else we can come up with shall we?
