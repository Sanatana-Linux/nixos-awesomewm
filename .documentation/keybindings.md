# Keybindings Reference

This document provides a comprehensive list of all default keybindings. The "Super" key is `Mod4`, which is typically the Windows or Command key. I split the keybindings into several different files arranged by category, which is reflected below. Maybe there are better ways to organize this and there are jazzier ways to implement keybindings in general, but this way I can quickly find my keybindings when trying to add new ones or change them.

### General / Awesome Control

| Keybinding          | Description           |
| ------------------- | --------------------- |
| `Super + r`         | Reload AwesomeWM      |
| `Super + Shift + q` | Quit AwesomeWM        |
| `Super + F1`        | Show keybindings help |

### UI Panels & Launchers

| Keybinding              | Description                |
| ----------------------- | -------------------------- |
| `Super + Shift + Enter` | Show Application Launcher  |
| `Super + Return`        | Toggle dropdown terminal   |
| `Super + Ctrl + Return` | Spawn new terminal         |
| `Super + p`             | Show the menubar           |
| `Super + d`             | Toggle Day Info (Calendar) |
| `Super + e`             | Toggle Control Panel       |
| `Super + x`             | Show Power Menu            |
| `Alt + Tab`             | Show/Cycle Window Switcher |

### Window (Client) Management

| Keybinding          | Description                        |
| ------------------- | ---------------------------------- |
| `Super + f`         | Toggle client context menu         |
| `Super + w`         | Close focused window               |
| `Super + z`         | Toggle floating mode               |
| `Super + \`         | Move focused window to master      |
| `Super + o`         | Move focused window to next screen |
| `Super + t`         | Toggle "always on top"             |
| `Super + n`         | Minimize focused window            |
| `Super + Ctrl + n`  | Restore minimized window           |
| `Super + m`         | Toggle maximize (fullscreen)       |
| `Super + Ctrl + m`  | Toggle maximize vertically         |
| `Super + Shift + m` | Toggle maximize horizontally       |

### Window Focus & Swapping

| Keybinding          | Description                |
| ------------------- | -------------------------- |
| `Super + j`         | Focus next window          |
| `Super + k`         | Focus previous window      |
| `Super + Shift + j` | Swap with next window      |
| `Super + Shift + k` | Swap with previous window  |
| `Super + Tab`       | Go back to previous window |
| `Super + u`         | Jump to urgent window      |
| `Super + Ctrl + j`  | Focus next screen          |
| `Super + Ctrl + k`  | Focus previous screen      |

### Layout Management

| Keybinding              | Description                       |
| ----------------------- | --------------------------------- |
| `Super + Space`         | Cycle to next layout              |
| `Super + Shift + Space` | Cycle to previous layout          |
| `Super + h`             | Decrease master width factor      |
| `Super + l`             | Increase master width factor      |
| `Super + Shift + h`     | Increase number of master windows |
| `Super + Shift + l`     | Decrease number of master windows |
| `Super + Ctrl + h`      | Increase number of columns        |
| `Super + Ctrl + l`      | Decrease number of columns        |

### Tag (Workspace) Management

| Keybinding                     | Description                  |
| ------------------------------ | ---------------------------- |
| `Super + Left`                 | View previous tag            |
| `Super + Right`                | View next tag                |
| `Super + Escape`               | Go back to previous tag      |
| `Super + [1-9]`                | View tag #                   |
| `Super + Shift + [1-9]`        | Move focused client to tag # |
| `Super + Ctrl + Shift + [1-9]` | Toggle client on tag #       |

### Hardware & Utility

| Keybinding              | Description                   |
| ----------------------- | ----------------------------- |
| `XF86MonBrightnessUp`   | Increase screen brightness    |
| `XF86MonBrightnessDown` | Decrease screen brightness    |
| `PrintScreen`           | Take fullscreen screenshot    |
| `Super + PrintScreen`   | Take selected area screenshot |
| `Shift + PrintScreen`   | Take delayed screenshot       |
