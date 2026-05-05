class_name LevelLink extends Resource

## The SID of the level to link to. Must be from a later segment in a given world.
@export var sid:String

## The exit that must be reached for the end of the link to be marked as playable.
## For instance, level 1.1 may require the exit "main" to access 1.2--the level
## it links to.
@export var exit_requirement:String = "main"
