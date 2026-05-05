## A global script used for editing/accessing save data for certain
## save slots. This data contains information such level completion,
## best completion times, etc.
extends Node

const SLOT_TEMPLATE : Dictionary = {
	"name": "Untitled",  # TODO
	"creation_time": -1, # TODO
	"last_played": -1,   # TODO
	"achievements": {},  # TODO
	"worlds": {}
}

const WORLD_TEMPLATE : Dictionary = {
	"levels": {} # sid / LEVEL_TEMPLATE pairs of data.
}

const LEVEL_TEMPLATE : Dictionary = {
	"completions": [],
	"exits": []
}

var current_slot: int = -1

#region Helper
func _get_slot_data() -> Array:
	var data : Dictionary = PersistentData.get_all_save_data()
	if ("slots" not in data):
		data["slots"] = []
	return data["slots"]
#endregion

#region Getters
## Gets the number of save slots in the player's save data.
func get_slot_count() -> int:
	return _get_slot_data().size()

## Returns a reference to the currently loaded save slot dictionary. Note that
## changes made to this dictionary are saved automatically, so external
## classes should only read, and not modify, this dictionary.
func get_current_slot() -> Dictionary:
	var slots := _get_slot_data()
	assert(
		current_slot < get_slot_count(), 
		"Current save slot not found in save data! Current slot: " + str(current_slot)
	)
	return slots[current_slot] # TODO Validate slot has correct keys and types

## Returns true if a given level was completed.
func is_level_completed(world:String, sid:String) -> bool:
	
	var slot_data := get_current_slot()
	if world not in slot_data["worlds"]:
		return false
	
	if sid not in slot_data["worlds"][world]["levels"]:
		return false
	
	return slot_data["worlds"][world]["levels"][sid]["completions"].size() > 0

func get_level_completions(world:String, sid:String) -> Array:
	var slot_data := get_current_slot()
	
	if world not in slot_data["worlds"]:
		return []
	
	elif sid not in slot_data["worlds"][world]["levels"]:
		return []
	
	return slot_data["worlds"][world]["levels"][sid]["completions"]

func get_level_exits(world:String, sid:String) -> Array:
	if not is_level_completed(world, sid): return []
	var slot_data := get_current_slot()
	return slot_data["worlds"][world]["levels"][sid]["exits"]

#endregion

#region Setters
## Sets the current save slot to the passed index. If the slot does not exist,
## nothing will happen.
func set_slot(idx : int) -> void:
	if idx >= get_slot_count():
		push_warning("Invalid index passed for set_slot! Passed index: " + str(idx))
	current_slot = idx

## Adds completion data to a given level. Creates respective world and sid entries
## within player data to do so.
func add_level_completion(world:String, sid:String, data:CompletionData) -> void:
	var slot_data := get_current_slot()
	
	if world not in slot_data["worlds"]:
		var world_dict := WORLD_TEMPLATE.duplicate(true)
		slot_data["worlds"][world] = world_dict
	
	if sid not in slot_data["worlds"][world]["levels"]:
		slot_data["worlds"][world]["levels"][sid] = LEVEL_TEMPLATE.duplicate(true)

	var level_dict : Dictionary = slot_data["worlds"][world]["levels"][sid]
	level_dict["completions"].append(data.to_dict())
	
	if data.exit_type not in level_dict["exits"]:
		level_dict["exits"].append(data.exit_type)
	
	PersistentData.save_game()

## Creates a new save slot and returns its index.
func create_slot() -> int:
	
	var idx  : int        = get_slot_count()
	var slot : Dictionary = SLOT_TEMPLATE.duplicate(true)
	
	slot["creation_time"] = Time.get_unix_time_from_system()
	slot["last_played"]   = slot["creation_time"]
	slot["name"]          = "Save slot " + str(idx+1)
	
	# Appends to reference to save data, thus making the data persistent.
	_get_slot_data().append(slot)
	
	return idx
#endregion

#region Inherited
func _ready() -> void:
	
	if !PersistentData.is_loaded:
		await PersistentData.DataLoaded
	
	#_get_slot_data().clear()
	# TODO Remove everything below when possible.
	if get_slot_count() == 0:
		create_slot()
	
	set_slot(0)
	#add_level_completion("MyWorld", "1.1", CompletionData.new())
	#Helper.print_dict_as_json(get_current_slot())
#endregion
