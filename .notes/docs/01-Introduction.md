# Awesome Window Manager Tutorial Part 01

<!-- vim-markdown-toc GFM -->

* [Introduction:](#introduction)
* [Understanding the Concepts:](#understanding-the-concepts)
    * [Floating, Tiling and Dynamic Window Managers? Oh My!:](#floating-tiling-and-dynamic-window-managers-oh-my)
    * [Tiling Layouts:](#tiling-layouts)
    * [Tags and Workspaces:](#tags-and-workspaces)
    * [Modular or Monolithic Configurations](#modular-or-monolithic-configurations)
    * [Widgets and the Wibox:](#widgets-and-the-wibox)
    * [Modules:](#modules)
    * [Modules vs. Widgets, What's the Difference?](#modules-vs-widgets-whats-the-difference)
    * [Helpers or Utilities](#helpers-or-utilities)
* [Footnotes](#footnotes)

<!-- vim-markdown-toc -->

## Introduction:

Welcome to an exciting journey at the amorphous frontier of desktop computing interfaces, where anything is possible so long as you are willing to put in the hours of debugging. In this series of tutorials, we shall survey the wild landscape of Awesome Window Manager, a captivating and powerful tiling window management _framework_ that empowers you to mold your own desktop environment to be just about anything you can dream up and write out in Lua code. Prepare yourself to embark on one of the most rewarding, if not most frustrating, experiences .

## Understanding the Concepts:

Before we dive into the captivating world of Awesome, let's lay a solid foundation by understanding the underlying concepts that drive this exceptional window manager. Familiarity with these concepts will pave the way for you to unleash the full potential of Awesome.

### Floating, Tiling and Dynamic Window Managers? Oh My!:

At the core of Awesome lies the concept of tiling window managers. Unlike conventional window managers, which allow windows to float freely, overlap, or clutter the screen, tiling window managers take an architectural approach. They partition the screen into non-overlapping tiles, allowing each window to occupy its dedicated space. The result is an optimized use of screen real estate, eliminating clutter and providing an organized workspace that enhances productivity.

Awesome is actually a dynamic window manager, which means that it does can render both tiling and floating windows, even on the same screen at the same time! This can be helpful for things like dialog boxes that would otherwise get tiled, throw the whole screen off and after clicking "Ok" would then again need to re-tile the whole screen, which is inefficient and jarring in most cases.

### Tiling Layouts:

The geometric pattern which windows are laid out in is the `layout`, which AwesomeWM comes with a bounty of by default, significantly more options than other dynamic or tiling window managers. How useful any of these pattern is depends on the windows being arranged and the responsive of the applications within them, of course. While one sized fits all solutions are non-existent anywhere in the Linux ecosystem, the default layout this configuration uses is pretty handy and with the right settings to insure dialogues render as floating windows, an excellent starting point for learning how best to handle tiling window managers.

### Tags and Workspaces:

Tags, a fundamental concept in Awesome, revolutionize the way some of us manage windows. Tags represent virtual workspaces that enable efficient organization and grouping of windows. Unlike traditional workspaces, Awesome allows windows to exist simultaneously in multiple tags or several tags to be displayed on the same screen at the same time. This flexibility empowers you to tailor your workspace dynamically, effortlessly adapting to the demands of different projects or tasks. Seamlessly switch between tags, and witness the transformation of your workflow.

Often times, the use of tags with intent to show multiple on screen at once is combined with rules that will prompt any of the windows of specific applications to open on one of them. The windows of a tag can then be set to display when needed, dismissed when not and without changing the initial tag one is working with.

While many swear by this sort of arrangement, the beauty of Awesome being whatever you code it to be is that if you are like the author, you might find the dynamic use of virtual workspaces less useful than the traditional workspaces and decent keybindings to move windows, thus this configuration is set up for that specifically in a more traditional workspace paradigm. Awesome is whatever you want it to be.

### Modular or Monolithic Configurations

By default, the configuration of done with a single file located at `$HOME/.config/awesome/rc.lua`, this is a monolithic configuration. While this a neat solution and can eliminate a lot of redundant code in the form of requiring only a single set of lines including various functionality being pulled from, it is a long file and can be hard to navigate on a traditional code editor as it is, this only magnifying if one does any substantial modification.

The alternative, which is how this particular configuration is arranged and the assumption of this documentation that the reader will also being using this style, is that of a **modular configuration** where various elements of the configuration have been split up into an array of files called as necessary by `rc.lua` or other files. How these files are arranged is variable, most arrange their configuration depending on the configuration that inspires them the most, or seems most rational, but this varies too wildly to merit too much discussion of. The arrangement of this configuration which has evolved over time and blends several paradigms together (all hailing originally from the `Glorious Dotfiles` take on `elenapan's dotfiles`), informs the precise definitions of terms below<sup>1</sup> and in the rest of this documentation these terms will be used in reference to these definitions. 

### Widgets and the Wibox:

The Wibox, a central element of Awesome's allure, comes to life through the concept of widgets. These versatile graphical elements adorn the Wibar, which is essentially a status bar, providing real-time information and interactivity if that so pleases the user to program for themselves or adapt the code of others to do so. From displaying the current time and system statistics to weather updates and media controls, widgets serve as your faithful companions, both as functional and aesthetically pleasing as you are willing to make them. Awesome Window Manager's design and configuration encourage you to customize your status bar, sculpting it to reflect your preferences and necessities and with a little imaginative Lua code, you can fashion whatever sort of desktop bar you want, from a macOS style dock to a replication of the sort of desktop bars common across operating systems or even something entirely unique and of your own making.

### Modules:

In the parlance used in this configuration and this associated documentation, **modules** provide functionality overall to the configuration. This functionality can be things like the backend for the dropdown terminal<sup>2</sup> or changing the icons on the battery widget to reflect the current state of the battery's charge. While AwesomeWM provides a number of these by default, like the keybindings help window which is incredibly helpful for those new to keyboard driven window management, the more complex configurations will tend to require additional functionality to achieve their intended results and thus will write their own modules.

### Modules vs. Widgets, What's the Difference?

In the context of Awesome Window Manager, a module and a widget are both components used to customize and extend the functionality of the window manager. However, there is a distinction between the two:

1. Module: A module in Awesome Window Manager refers to a self-contained unit of functionality that provides a set of features or services. It is typically a Lua script that can be loaded and configured within the Awesome configuration file (`rc.lua`). Modules can provide various capabilities, such as managing key bindings, defining layouts, handling notifications, or controlling window behavior. Examples of modules in Awesome include the "awful" module (providing core functionality), the "beautiful" module (managing themes), and the "wibox" module (creating status bars).

2. Widget: A widget, on the other hand, is a graphical element that can be displayed on the screen and interacted with by the user. Widgets are often used within the wibar to provide information or functionality. They can show various types of data, such as the current time, battery status, system load, network connectivity, or even custom user-defined information. Widgets can be added, removed, and rearranged within the status bar to suit the user's preferences.

### Helpers or Utilities

Often called helpers, here referred to as Utilities, these are functions which are run repeatedly called upon within the configuration, which due to the reusable nature are called with a common namespace and scoped to be available anywhere without additional fuss. These are written here as anonymous functions specified in the namespace's `init.lua` file. In a single-page configuration they would have been placed towards the top of the file without the `local` specifier. The namespace `utilities` in this configuration approximates one of the built-in modules or larger widget collections in being 2 layers deep, looking something like `utilities.widgets.mkroundedrect()` when called<sup>3</sup>.

---
## Footnotes 

- <sup>1</sup>: Which differs across the span of configurations available as no standardized version is held universally to provide a lexicon to the AwesomeWM jargon.
- <sup>2</sup>: Using this configuration, the dropdown terminal is accessible with <kbd>Super</kbd>+<kbd>Enter</kbd>.
- <sup>3</sup>: Notice the `()` at the end? That indicates that it is a function being called and in some cases is filled in with the value of variables the function expects or optionally accepts. In Lua, they must be included otherwise the content of the namespace will be filled in instead of the function's value. 
