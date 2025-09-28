extends Node2D

var _debug_dots : Dictionary[String, DebugDot]

var debug_dot_scn : PackedScene = preload("res://Scenes/Debug/debug_dot.tscn")

func get_all_descendants(node: Node) -> Array[Node]:
	var descendants: Array[Node] = []
	for child in node.get_children():
		descendants.append(child)
		descendants.append_array(get_all_descendants(child))
	return descendants

func get_closest_player(origin:Vector2, distance_limit : float = 10000000) -> Player:
	for node in get_tree().get_nodes_in_group("Player"):
		if node is not Player : continue
		if origin.distance_to(node.get_player_position()) <= distance_limit:
			return node
	return null

## Returns the vector between the center of the screen and the mouse.
func get_mouse_vec_from_center() -> Vector2:
	var center := get_viewport().get_mouse_position()
	var size := get_viewport_rect().size
	return center - Vector2(size.x, size.y)/2

## Returns true if the passed angle is vertical.
func is_angle_roughly_vertical(ang : float, max_offset : float = PI/4) -> bool:
	return (absf(ang - PI/2)<max_offset or absf(ang - -PI/2)<max_offset)

func debug_dot(parent:Node, pos : Vector2, id : String, color : Color = Color.WHITE) -> void:
	
	if id in _debug_dots and is_instance_valid(_debug_dots.get(id)):
		_debug_dots.get(id).queue_free()
	
	var dot := debug_dot_scn.instantiate()
	dot.global_position = pos
	dot.kill_time = 3.0
	dot.id = id
	dot.self_modulate = color
	
	parent.add_child(dot)
	
	_debug_dots.set(id, dot)
	
