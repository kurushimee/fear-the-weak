# CLAUDE.md - Godot Project Guide

## Project Commands
- Run project: `godot -e` (opens Godot editor)
- Export project: `godot --export "Windows Desktop" game.exe`
- Debug mode: `godot --debug`
- Run scenes: `godot --path . --scene scenes/main.tscn`

## Code Style Guidelines
- **Naming Conventions**:
  - Classes: PascalCase (Player, Interactable)
  - Files/scenes: snake_case (player.gd, screen_fade_effect.tscn)
  - Functions/variables: snake_case (set_input_enabled, is_active)
  - Constants: SCREAMING_SNAKE_CASE (SPEED, CREAK_CHANCE)

- **Type Annotations**: Always use explicit typing (`: Type`)
- **Documentation**: Document all functions with `##` comments
- **Signal Pattern**: Use signals for communication between components
- **Singletons**: Use static variables with explicit typing (`static var instance: Player`)
- **Error Handling**: Use conditional checks, not try/catch
- **Export Properties**: Use `@export` for inspector-configurable properties
- **Project Structure**: Maintain separation between code systems

## Notes
- Godot version: 4.4 (GDScript)
- Input handling is done with action mapping, not raw input
