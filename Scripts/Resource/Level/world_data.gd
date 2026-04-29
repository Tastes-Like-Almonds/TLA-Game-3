class_name WorldData extends Resource

## A short, unique name for the level.
@export var name:String

## The world name displayed to the player.
@export var display_name:String

## Columns of the level. Note that when adding a level, it cannot reference the sid
## of a level from a previous column.
@export var segments:Array[WorldSegmentData]

## Automatically plays the selected animation when this world is loaded
## in the selector. Only set this after the animation is complete.
@export var selector_animation : StringName = ""

@export_group("Colors")
@export var line_unlocked_color : Color = Color.WHITE
@export var line_locked_color   : Color = Color.RED
@export var level_color         : Color = Color.WHITE
@export var level_boss_color    : Color = Color.RED
