class_name LevelNode extends Button

var node_data : LevelNodeData:
	set(value):
		text = value.sid
		node_data = value

func get_left_center_position() -> Vector2:
	var pos := global_position
	global_position.x += size.x/2
	return pos

func get_right_center_position() -> Vector2:
	var pos := global_position
	global_position.x -= size.x/2
	return pos

func set_enabled(val:bool=true) -> void:
	disabled = !val
