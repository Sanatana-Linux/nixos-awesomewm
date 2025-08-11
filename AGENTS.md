# AGENTS.md

## Build, Lint, and Test Commands
- **Start test environment**: `./bin/awmtt-ng.sh start` (Xephyr nested Awesome)
- **Stop test environment**: `./bin/awmtt-ng.sh stop`
- **Format code**: `stylua .` (uses `.stylua.toml`)
- **Lint/diagnostics**: Use `lua-language-server` with `.luarc.json`
- **Single test**: Manually test modules by reloading in nested Awesome session

## Code Style Guidelines
- **Indentation**: 4 spaces (`.stylua.toml`)
- **Line width**: 80 characters max
- **Quotes**: Prefer double quotes (auto, StyLua)
- **Line endings**: Unix
- **Imports**: Group all `require` statements at the top of files
- **Variables**: Always use `local`, snake_case, descriptive names
- **Functions**: Use snake_case, document parameters clearly
- **Types**: Lua is dynamically typed; use clear naming and comments for intent
- **Comments**: Use `---@diagnostic disable: undefined-global` for AwesomeWM globals
- **Error handling**: Use `pcall()` for potentially failing operations
- **Globals**: Avoid unless required by AwesomeWM; add to `.luarc.json` if needed

## Project Structure
- **Core modules**: `core/`
- **UI components**: `ui/`
- **Services**: `service/`
- **Themes**: `themes/`
- **Libraries**: `lib/`
