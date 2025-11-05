extends Node

## Return codes for load_level()
enum LoadLevelStatus {
	SUCCESS, ## No issues with loading.
	INVALID_LEVEL, ## The level failed to load from the path
	INVALID_PARENT, ## The parent is invalid (failed is_instance_valid())
	LEVEL_IS_NOT_LEVEL, ## The level loaded, but was not a Level object.
}

## The target directory to find level files.
const LEVEL_DIR : String = "res://Scenes/Level/"

## Deletes all level nodes in the passed parent.
func clear_levels(parent : Node) -> void:
	if not is_instance_valid(parent): return
	for child in parent.get_children():
		if child is Level:
			child.queue_free()

## Loads a level and parents it to `parent`. 
func load_level(path : String, parent: Node, config : LevelConfig = null) -> LoadLevelStatus: # TODO Dynamically test levels as they are added.
	
	if not is_instance_valid(parent): return LoadLevelStatus.INVALID_PARENT
	if not path: return LoadLevelStatus.INVALID_LEVEL
	
	var scn : PackedScene = load(path)
	if not scn: return LoadLevelStatus.INVALID_LEVEL
	
	var loaded := scn.instantiate()
	if loaded is not Level: loaded.free() ; return LoadLevelStatus.LEVEL_IS_NOT_LEVEL
	
	parent.add_child(loaded)
	loaded.initialize(config)
	
	print("Level '" + path + "' loaded!")
	
	SignalBus.LevelPathLoaded.emit(path)
	return LoadLevelStatus.SUCCESS

## Returns an array of all file paths of levels. Note: This only checks if files are .tscn files,
## and not Level objects.
func get_all_level_paths() -> Array[String]:
	var files_list: Array[String] = []
	var dir_access: DirAccess = DirAccess.open(LEVEL_DIR)
	
	if dir_access:
		dir_access.list_dir_begin()
		var file_name: String = dir_access.get_next()
		while file_name != "":
			if not dir_access.current_is_dir(): # Check if it's a file, not a directory
				if file_name.ends_with(".tscn"):
					files_list.append(LEVEL_DIR + file_name)
			file_name = dir_access.get_next()
		dir_access.list_dir_end()
	else:
		printerr("Could not open folder: " + LEVEL_DIR)
	
	return files_list
