# Template Godot Repo
---
## Description
This is a template for creating godot games with a simple CICD pipeline as well as some other features.
GUT (Godot Unit Testing) comes preinstalled with the repo.
Currently uses Godot 4.4.3.

## Reminders
Make sure to set the following secrets/variables in settings to whatever you need.

GODOT_VERSION: The version of godot used (4.4.3-stable)

USE_MONO: Whether or not godot games are built using the mono (C#) version (true/false)

## Workflows
### Create Relase: 
- Builds the game using the presets within the project and creates a github release with the given version number.
- Must be run manually
