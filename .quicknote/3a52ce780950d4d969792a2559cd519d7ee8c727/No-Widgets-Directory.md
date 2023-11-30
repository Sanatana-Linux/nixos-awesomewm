# No Widgets Directory

Unlike the very rationally laid out [Linux AwesomeWM Modular Starter Kit](https://gitlab.com/bloxiebird/linux-awesomewm-modular-starter-kit/) and many configurations I have opted against separating out the widgets from their parent UI elements and placing them in a top-level `widgets/` directory. This design consideration in the layout of my codebase has been primarily a reflection of my desire to make the UI elements "portable", in the limited sense of this particular codebase (my global scoping of the configuration's variables would make for some debugging were you to drag and drop any of these elements, but that was a developer experience decision I hardly regret).

These UI elements with their associated widgets within the directory they are located within are portable in the sense that they are this way easily disposed of. Sometimes one needs a fresh start after all and this arrangement makes such a situation much more convenient.

It has also been that I have opted to write this configuration this way for purposes of easing the process of navigating between the files without getting distracted by other lingering `TODO` items. So for sake of combatting my ADHD tendencies, I have opted to this atomic topography of the UI elements.

As a final consideration that has been at play, I find it unnecessarily obtuse to have a separate subdirectory with the same name to store an element's widgets and then that UI element in its own subdirectory containing only a `init.lua` file.

Of course these are my opinions, shaped by what works best for me (or at least seems to) such that I am aware of alternative arrangements having the potential to be much better for others and suggest you figure out what works for you then stick to it.
