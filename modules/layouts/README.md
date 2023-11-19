# Configuration/Tags/layouts

Yes, these are custom layouts, which are inspired by the noted projects in each
file. Like much else about this configuration, I have preferred to take
ownership of the code so that I could

    a. format the files to my liking
    b. modify the code to best fit into this configuration
    c. stabilize and ease maintence

## Layouts

| Layout        | Characteristics                                                                                                  |
| ------------- | ---------------------------------------------------------------------------------------------------------------- |
| cascade       | client windows are stacked behind main/current in tighter formation than deck                                    |
| cascade.tiled | tiles stack within the screen's workarea                                                                         |
| center        | center of the layout is most of the screen, additional windows on sides of the master client                     |
| deck          | stacks clients over one another like a hand of playing cards                                                     |
| equalarea     | each client gets an equal sized space on screen                                                                  |
| horizon       | creates a row for each client, stacking the windows on top of each other with the master being the largest.      |
| stack         | Two clients, with the master to the left and new windows stacking on the right (can be switched, check the code) |
| thrizen       | Similar to empathy but the next row shrinks only the row above it                                                |
