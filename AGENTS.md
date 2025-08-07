# AwesomeWM Configuration - Agent Guidelines

## Build/Test/Lint Commands
- **Test config**: `./bin/awmtt-ng.sh start` (starts nested Awesome in Xephyr)
- **Stop test**: `./bin/awmtt-ng.sh stop`
- **Format code**: `stylua .` (uses .stylua.toml config)
- **Lua check**: Use lua-language-server with .luarc.json config

## Code Style
- **Indentation**: 4 spaces (defined in .stylua.toml)
- **Line width**: 80 characters max
- **Quotes**: Auto-prefer double quotes
- **Comments**: Use `---@diagnostic disable: undefined-global` for AwesomeWM globals
- **Imports**: Group requires at top, local variables follow
- **Variables**: Use `local` for all variables, descriptive snake_case names
- **Functions**: snake_case naming, clear parameter documentation
- **Error handling**: Use `pcall()` for potentially failing operations

## Architecture
- **Core modules**: Place in `core/` directory with init.lua
- **UI components**: Place in `ui/` directory with modular structure
- **Services**: Place in `service/` directory for background functionality
- **Themes**: Use `themes/` directory structure with theme.lua files
- **Libraries**: External libs in `lib/` directory