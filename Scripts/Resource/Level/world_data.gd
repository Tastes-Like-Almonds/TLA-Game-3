class_name WorldData extends Resource

## A short, unique name for the level.
@export var name:String

## Columns of the level. Note that when adding a level, it cannot reference the sid
## of a level from a previous column.
@export var segments:Array[WorldSegmentData]

@export_group("Selector Colors")
@export var line_unlocked_color : Color = Color.WHITE
@export var line_locked_color   : Color = Color.RED
