# What is a Module vs. a Widget

In the context of Awesome Window Manager, a module and a widget are both components used to customize and extend the functionality of the window manager. However, there is a distinction between the two:

1. Module: A module in Awesome Window Manager refers to a self-contained unit of functionality that provides a set of features or services. It is typically a Lua script that can be loaded and configured within the Awesome configuration file (`rc.lua`). Modules can provide various capabilities, such as managing key bindings, defining layouts, handling notifications, or controlling window behavior. Examples of modules in Awesome include the "awful" module (providing core functionality), the "beautiful" module (managing themes), and the "wibox" module (creating status bars).

2. Widget: A widget, on the other hand, is a graphical element that can be displayed on the screen and interacted with by the user. Widgets are often used within the status bar (also known as the "wibox") to provide information or functionality. They can show various types of data, such as the current time, battery status, system load, network connectivity, or even custom user-defined information. Widgets can be added, removed, and rearranged within the status bar to suit the user's preferences.

Thus modules provide functionality and services to Awesome Window Manager, while widgets are graphical elements (that may or may not be displayed within the status bar) to provide information or interactivity. A good rule of thumb to distinguish the two is this: modules are more focused on underlying functionality and behavior, while widgets are concerned with the visual presentation and user interaction.

> **NOTE**
>
> In this configuration, the widgets are housed within the `ui` directory while modules that are anonymous functions are within the `utilities` directory and other modules within the `modules` directory.
