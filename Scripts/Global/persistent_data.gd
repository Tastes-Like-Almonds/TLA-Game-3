# Saves/loads player data via JSON.
extends Node

const SAVE_PATH : String = "user://tla-3.save"
const TEMP_SAVE_PATH : String = "user://tla-3.save.tmp"

@onready var version : String = ProjectSettings.get_setting("application/config/version")

var loaded_data : Dictionary

#region Helper
## Returns the default template for save data.
func _get_base_data() -> Dictionary:
	return {
		"save_version": version,
		"val": 1,
		"settings": {},
		"slots": []
	}

## Converts non-json objects into json ones, e.g. allows for ints to be serialized.
func _typeify(target:Variant) -> Variant:
	
	if target is float:
		return target
	
	elif target is String:
		return target
	
	elif target is int:
		return {
			"_type": "int",
			"_val": target
		}
	
	elif target is Array:
		var arr := []
		for item:Variant in target:
			arr.append(_typeify(item))
		return arr
	
	elif target is Dictionary:
		var dict := {}
		for key : Variant in target.keys():
			dict[key] = _typeify(target[key])
		return dict
	
	# This error could be removed along with the checks for float and string, but it is kept
	# to ensure future data types are properly stored.
	push_error("No typeify handling for target: " + str(target))
	return target

## Inverse of _typeify().
func _untypeify(target:Variant) -> Variant:
	
	if target is Dictionary:
		
		# Convert custom types to Godot objects
		if "_type" in target:
			assert("_val" in target, "_type object does not have a 'val' key! (" + str(target) + ")")
		
			if target["_type"] == "int":
				return int(target["_val"])
			
			push_error("No handling for _type of '" + target + "'.")
		
		var dict := {}
		for key : Variant in target.keys():
			dict[key] = _untypeify(target[key])
		return dict
	
	elif target is Array:
		var arr := []
		for item : Variant in target:
			arr.append(_untypeify(item))
		return arr
	
	# All other objects must be normal JSON
	return target

func _load_from_json(json:String) -> Dictionary:
	var data : Variant = JSON.parse_string(json)
	assert(data is Dictionary, "Passed JSON data is not a dictionary!")
	return _untypeify(data)

func _save_to_json(data:Dictionary) -> String:
	var stringed : String = JSON.stringify(_typeify(data))
	return stringed

#endregion

#region Public
## Loads all game data from disk. Note that this replaces all currently loaded data, regardless
## of whether or not it has been saved. 
func load_game(path:String=SAVE_PATH) -> void:
	var current_loaded_data : Dictionary = {}
	
	if FileAccess.file_exists(path):
		var save_file := FileAccess.open(path, FileAccess.READ)
		
		if save_file == null:
			push_error("Failure to load save data. Error code: " + str(FileAccess.get_open_error()))
			return
		
		current_loaded_data = _load_from_json(save_file.get_as_text())
		save_file.close() # Not neccessary but it feels weird not writing it
		
	else:
		current_loaded_data = _get_base_data()
	
	loaded_data = current_loaded_data

## Saves all game data to disk.
func save_game(path:String=SAVE_PATH) -> void:
	
	print("Saving game...")
	
	if (!loaded_data):
		load_game() # Will create base data if needed
	
	# Save to temporary file to prevent loss of data during crash
	var save_file := FileAccess.open(path, FileAccess.WRITE)
	var save_string : String = _save_to_json(loaded_data)
	
	assert(save_file != null, "Error opening save file. Error code: " + str(FileAccess.get_open_error()))
	assert(save_file.store_string(save_string), "Error writing save data to file.")
	
	save_file.close()

## Gets all loaded save data.
func get_all_save_data() -> Dictionary:
	return loaded_data

#endregion

#region Inherited
func _ready() -> void:
	get_tree().auto_accept_quit = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
#endregion
