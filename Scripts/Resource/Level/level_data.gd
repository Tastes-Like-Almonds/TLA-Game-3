## Contains information about a level. This is used for both loading and displaying the level.
class_name Leveldata extends Resource

#region Required
## The file path of the level.
var level_path : String

## The id of the level. Must be unique.
var id : String
#endregion

#region Display
## The displayed name of the level.
var level_name : String = "Unitled"

## The full description of the leve.
var desc : String = "No Description."
#endregion

#region Functions
func _init(path : String, level_id : String) -> void:
	if not path: printerr("Path not found for leveldata!")
	if not level_id: printerr("Level ID not found!")
	level_path = path
	level_id = level_id
#endregion
