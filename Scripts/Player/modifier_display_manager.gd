## Manages displays for temporary stat modifiers
class_name ModifierDisplayManager extends Node2D

var display_scn:PackedScene = preload("res://Scenes/Player/radial_modifier_display.tscn")

var displays : Dictionary[StringName, TextureProgressBar]

func create_display(id:StringName, time:float, color:Color = Color.WHITE) -> void:

	# Remove old display	
	cancel_display(id)
	
	var new : TextureProgressBar = display_scn.instantiate()
	new.modulate = color
	
	add_child(new)
	
	var timer : SceneTreeTimer = get_tree().create_timer(time)
	timer.timeout.connect(new.queue_free)
	new.set_meta(&"timer", timer) # Used to update progress value
	new.set_meta(&"start_time", time)
	
	displays[id] = new

func cancel_display(id:StringName) -> void:
	if id in displays and is_instance_valid(displays[id]):
		displays[id].queue_free()

func _process(_delta: float) -> void:
	
	# Erase invalid displays. Done in _process to ensure all values are valid
	# before processing; doing so in cancel_display can crash.
	for key : Variant in displays.keys():
		if !is_instance_valid(displays[key]):
			displays.erase(key)
	
	for display : TextureProgressBar in displays.values():
		var timer : SceneTreeTimer = display.get_meta(&"timer")
		var start_time : float = display.get_meta(&"start_time")
		display.value = 100 * timer.time_left / start_time
		display.global_position = global_position - (display.texture_progress.get_size()*display.scale*global_scale)/2
