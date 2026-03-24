## In-level data collected about what the player accomplishes. This is used
## as a class by level.gd, but is converted to a dictionary for the purposes
## of saving.
class_name CompletionData extends Node

var completed_at : float = -1
var time_sec : float = -1
var damage_taken : float = -1
var kills : int = -1
var exit_type : String = "main"

static func get_blank() -> CompletionData:
	return CompletionData.new()

static func from_dict(dict : Dictionary) -> CompletionData:
	var obj := get_blank()
	for key : String in dict.keys():
		obj.set(key, dict[key])
	return obj

func to_dict() -> Dictionary:
	var dict := {}
	for property in get_property_list():
		if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE > 0:
			dict[property.name] = get(property.name)
	return dict

func _init() -> void:
	pass
