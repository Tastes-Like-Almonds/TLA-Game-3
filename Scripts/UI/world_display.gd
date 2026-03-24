class_name WorldDisplay extends HBoxContainer

## Fired when the world is changed to a different, valid world data object.
signal world_changed(world:WorldData)

## Internal class for managing the currently loaded worlds and any needed
## metadata.
class WorldNode:
	var data   : WorldData = null
	var locked : bool      = false

@onready var button_left  : Button = $Left
@onready var button_right : Button = $Right

@onready var world_title_label      : Label = $VBoxContainer/Title
@onready var level_completion_label : Label = $VBoxContainer/LevelCompletion

var worlds        : Array[WorldNode] = []
var current_world : int              = -1

#region Public
## Clears all loaded worlds.
func clear_worlds() -> void:
	worlds.clear()
	current_world = -1
	_update_display()

## Adds a world to the list of selectable worlds.
func add_world(world:WorldData, locked:bool = false) -> void:
	var new_world := WorldNode.new()
	new_world.data = world
	new_world.locked = locked
	worlds.append(new_world)
	
	# When the first world is added, switch to it.
	if worlds.size() == 1: 
		current_world = 0
		world_changed.emit(worlds[current_world].data)
		_update_display()
#endregion

#region World Management
func _next_world() -> void:
	if worlds.size() == 0: return
	current_world = wrap(current_world+1, 0, worlds.size())
	world_changed.emit(worlds[current_world].data)
	_update_display()

func _previous_world() -> void:
	if worlds.size() == 0: return
	current_world = wrap(current_world-1, 0, worlds.size())
	world_changed.emit(worlds[current_world].data)
	_update_display()
#endregion

#region UI
func _update_display() -> void:
	
	if current_world == -1:
		hide()
		return
	
	show()
	
	var node := worlds[current_world]
	
	# Load the title
	world_title_label.text = node.data.name
	if node.locked:
		world_title_label.text = world_title_label.text + " - Locked"
	
	# TODO Load completion data
#endregion
