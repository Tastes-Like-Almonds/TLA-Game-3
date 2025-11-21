##A 2D map used to group levels together and save level progress.
@abstract class_name LevelMap extends Node2D

## Variable data
var map_data : MapData

func load_map(_data : MapData) -> void:
	pass # TODO

## Gets the JSON save data of the map.
func get_save() -> String:
	return "" # TODO
