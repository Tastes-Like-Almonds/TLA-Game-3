class_name WorldPanel extends FoldableContainer

## Emitted when a level of this world is played. This is emitted before the level is loaded.
signal LevelPlayed(data : LevelData)

@onready var vbox : VBoxContainer = $MarginContainer/VBoxContainer

## Instantiate and return an unparented LevelPanel object.
func _get_new_level_panel() -> LevelPanel:
	var child : LevelPanel = load("res://Scenes/UI/level_panel.tscn").instantiate()
	return child

## Adds a level to this panel's display. Must be a LeveLdata resource, not an actual level.
func _add_level(data:LevelData) -> void:
	var child : LevelPanel = _get_new_level_panel()
	vbox.add_child(child)
	child.LevelPlayed.connect(LevelPlayed.emit)
	child.set_level_data(data)

## Adds a level to this panel's display. Must be a path to the LeveLdata resource, not the actual level.
func _add_level_from_path(data_path:String) -> void:
	
	var data := load(data_path)
	
	if data is not LevelData:
		push_warning("Invalid data_path '" + data_path + "'; Not a LevelData!")
		return
	
	_add_level(data)

## Set the world's description display to the passed string.
func set_description(text : String) -> void:
	$MarginContainer/VBoxContainer/Label.text = text

## Delete all loaded LevelPanel objects..
func clear_levels() -> void:
	for child in vbox.get_children():
		if child is LevelPanel:
			child.queue_free()

## Loads an array of level paths into the world. Does not clear levels when called.
func load_level_paths_array(arr : Array[Variant]) -> void:
	for path : Variant in arr:
		_add_level_from_path(path) # Type checks done in function
