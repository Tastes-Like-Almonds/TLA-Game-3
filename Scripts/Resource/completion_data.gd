## In-level data collected about what the player accomplishes. This is used
## as a class by level.gd, but is converted to a dictionary for the purposes
## of saving.
class_name CompletionData extends Resource

#region Statistics tracked during game
var completed_at : float  = 0
var time_sec     : float  = 0
var damage_taken : float  = 0
var damage_dealt : float  = 0
var kills        : int    = 0
var deaths       : int    = 0
var dashes       : int    = 0
var exit_type    : String = "main"
#endregion

## Return an empty CompletionData object.
static func get_blank() -> CompletionData:
	return CompletionData.new()

## Convert a CompletionData object into a dictionary.
static func from_dict(dict : Dictionary) -> CompletionData:
	var obj := get_blank()
	for key : String in dict.keys():
		obj.set(key, dict[key])
	return obj

## Convert a CompletionData dictionary into an object. Dictionary is created
## via CompletionData.from_dict().
func to_dict() -> Dictionary:
	var dict := {}
	for property in get_property_list():
		if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE > 0:
			dict[property.name] = get(property.name)
	return dict
