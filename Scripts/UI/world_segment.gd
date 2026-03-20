class_name LevelSegment extends VBoxContainer

var scn_node : PackedScene = preload("res://Scenes/UI/Graph/level_node.tscn")

signal LevelSelected(level:LevelNodeData)

func load_segment(segment:WorldSegmentData) -> void:
	for level in segment.levels:
		var new_node : LevelNode = scn_node.instantiate()
		new_node.node_data = level
		new_node.pressed.connect(LevelSelected.emit.bind(level))
		add_child(new_node)

func get_nodes() -> Array[LevelNode]:
	var nodes : Array[LevelNode]
	
	for child in get_children():
		if child is LevelNode:
			nodes.append(child)
	
	return nodes
