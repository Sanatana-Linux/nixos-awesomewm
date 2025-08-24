# AwesomeWM Configuration

A modern, feature-rich AwesomeWM configuration with custom UI components, animations, and comprehensive system integration.

<img src="./assets/dreams.gif" width="100%" alt="AwesomeWM Configuration Preview"/>

---

## Features

- **Custom UI Components**: Modern control panels, popups, and notification system
- **Comprehensive Theming**: Yerba Buena theme with gradients, rounded corners, and consistent styling
- **Advanced Window Management**: Custom taglist/tasklist, window switcher, and client management
- **System Integration**: Audio, brightness, network, Bluetooth, and battery status widgets
- **Animations**: Smooth transitions and visual feedback throughout the interface
- **Multiple Layouts**: Support for various window layouts with on-screen display
- **Modular Architecture**: Well-organized codebase with clear separation of concerns

## Installation

1. **Prerequisites**:
   - AwesomeWM 4.3+
   - Lua 5.3+
   - Required fonts: Agave Nerd Font Propo Bold, awesomewm-font

2. **Clone Configuration**:
   ```bash
   git clone <repository-url> ~/.config/awesome
   cd ~/.config/awesome
   ```

3. **Install Dependencies**:
   - Ensure all system services (audio, brightness control, etc.) are available
   - Install required fonts and icon themes

4. **Test Configuration**:
   ```bash
   # Test in nested session
   ./bin/awmtt-ng.sh start
   
   # Or restart AwesomeWM
   awesome -c ~/.config/awesome/rc.lua
   ```

## Project Structure

```
├── core/                    # Core AwesomeWM functionality
│   ├── autostart/          # Auto-start applications
│   ├── client/             # Client (window) management
│   ├── error/              # Error handling and notifications
│   ├── keybind/            # Keybinding definitions
│   ├── notification/       # Notification system
│   ├── tag/                # Tag (workspace) management
│   └── theme/              # Theme initialization
├── lib/                     # Utility libraries
│   ├── dbus_proxy/         # D-Bus communication
│   ├── inspect.lua         # Debug inspection utility
│   └── json.lua            # JSON handling
├── modules/                 # Reusable UI modules
│   ├── animations/         # Animation framework
│   ├── dropdown/           # Dropdown terminal
│   ├── hover_button/       # Interactive button widget
│   ├── menu/               # Context menu system
│   ├── shapes/             # Custom shape definitions
│   └── text_input/         # Text input widgets
├── service/                 # System service integrations
│   ├── audio.lua           # Audio/volume control
│   ├── battery.lua         # Battery status
│   ├── bluetooth.lua       # Bluetooth management
│   ├── brightness.lua      # Screen brightness
│   ├── network.lua         # Network connectivity
│   └── screenshot.lua      # Screenshot functionality
├── themes/                  # Visual themes
│   └── yerba_buena/        # Main theme with icons and styling
├── ui/                      # User interface components
│   ├── bar/                # Top panel/bar
│   ├── lockscreen/         # Screen lock interface
│   ├── notification/       # Notification display
│   ├── popups/             # Various popup interfaces
│   │   ├── control_panel/  # System control panel
│   │   ├── launcher/       # Application launcher
│   │   ├── on_screen_display/ # Volume/brightness OSD
│   │   ├── powermenu/      # Power management
│   │   └── window_switcher/ # Alt-tab style window switcher
│   ├── tabbar/             # Window tab bar
│   ├── titlebar/           # Window title bars
│   └── wallpaper/          # Dynamic wallpaper management
└── wibox/                   # Custom wibox widgets
    ├── layout/             # Custom layouts
    └── widget/             # Enhanced widgets
```

## Key Components

### Core Systems
- **Client Management**: Advanced window placement, rules, and focus handling
- **Keybindings**: Comprehensive keyboard shortcuts organized by category
- **Tag Management**: Custom workspace handling with dynamic layouts
- **Error Handling**: Robust error reporting with notification integration

### User Interface
- **Control Panel**: System settings, audio/brightness controls, notification center
- **Application Launcher**: Modern app launcher with search functionality  
- **Window Switcher**: Alt-tab style window navigation with previews
- **On-Screen Display**: Volume and brightness indicators
- **Power Menu**: System power management interface

### Services
- **Audio Service**: PulseAudio integration for volume and device management
- **Brightness Service**: Screen brightness control with smooth transitions
- **Network Service**: WiFi and connection status monitoring
- **Bluetooth Service**: Device pairing and connection management
- **Battery Service**: Power status and charging indicators

### Theming
- **Yerba Buena Theme**: Modern design with gradients and rounded corners
- **Icon System**: Comprehensive icon set with fallback handling
- **Typography**: Custom font stack with multiple weight variants
- **Color Palette**: Consistent color scheme across all components

## Configuration

### Keybindings
See [documentation/keybindings.md](.github/documentation/keybindings.md) for the complete keybinding reference.

### Theme Customization
Modify `themes/yerba_buena/theme.lua` to customize:
- Colors and gradients
- Fonts and typography
- Border radius and spacing
- Icon themes

### Adding Services
Create new services in the `service/` directory following the existing pattern:
```lua
local service = {}

function service:get_default()
    if not self._instance then
        self._instance = self:new()
    end
    return self._instance
end

return service
```

## Development

### Testing
```bash
# Start test environment (Xephyr nested session)
./bin/awmtt-ng.sh start

# Stop test environment  
./bin/awmtt-ng.sh stop

# Format code
stylua .

# Check configuration
awesome -c rc.lua --check
```

### Code Style
- **Indentation**: 4 spaces
- **Line width**: 80 characters max
- **Variables**: `snake_case`, always use `local`
- **Functions**: `snake_case` with clear parameter documentation
- **Comments**: Document purpose and parameters for complex functions

### Adding Features
1. Follow the modular architecture
2. Use existing services and utilities where possible
3. Maintain consistent theming and styling
4. Add appropriate error handling
5. Test in nested session before deployment

## Documentation

- [Keybindings Reference](.github/documentation/keybindings.md)
- [Additional Resources](.github/documentation/Additional-Resources.md)
- [Credits](.github/documentation/Credit-Where-It-Is-Due.md)
- [Project Notes](.github/documentation/rc.lua.md)

## Contributing

1. Follow the existing code style and architecture
2. Test changes in the nested environment
3. Update documentation for new features
4. Ensure all functionality remains working

## License

This configuration is provided as-is for educational and personal use.
