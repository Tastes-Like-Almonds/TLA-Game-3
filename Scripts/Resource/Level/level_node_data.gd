class_name LevelNodeData extends Resource

## A short, unique name for the level.
@export var sid:String

## The actual data of the level.
@export var level_data:LevelData

## The levels which this node links to.
@export var links:Array[LevelLink]
