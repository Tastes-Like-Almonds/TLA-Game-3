extends MarginContainer

@onready var segment_parent : HBoxContainer = $HBoxContainer

var scn_segment : PackedScene = preload("res://Scenes/UI/Graph/world_segment.tscn")
var scn_node_line : PackedScene = preload("res://Scenes/UI/Graph/level_node_line.tscn")

var loaded_world : WorldData

const LINE_THICKNESS : float = 4.0

func _on_level_selected(node:LevelNodeData) -> void:
	print(node.level_data.title)

func load_world(world:WorldData) -> void:
	
	loaded_world = world
	
	for child in segment_parent.get_children():
		if child is LevelSegment:
			if child.is_connected("LevelSelected", _on_level_selected):
				child.LevelSelected.disconnect(_on_level_selected)
			child.queue_free()
	
	for segment in world.segments:
		var new_seg : LevelSegment = scn_segment.instantiate()
		new_seg.load_segment(segment)
		new_seg.LevelSelected.connect(_on_level_selected)
		segment_parent.add_child(new_seg)


## Get all level segments in the currently loaded world.
func _get_segments() -> Array[LevelSegment]:
	var segs : Array[LevelSegment]
	for segment in segment_parent.get_children():
		if segment is LevelSegment:
			segs.append(segment)
	return segs

func _draw_elbow(start : Vector2, end : Vector2, perc : float) -> void:
	var elbow : Vector2 = start + Vector2((end.x-start.x)*perc, 0)
	var peak : Vector2 = elbow + Vector2(0, end.y-start.y)
	draw_line(start,elbow,Color.WHITE,LINE_THICKNESS)
	draw_line(elbow,peak,Color.WHITE,LINE_THICKNESS)
	draw_line(peak,end,Color.WHITE,LINE_THICKNESS)

func _segment_has_sid(segment : LevelSegment, sid:String) -> LevelNode:
	for level in segment.get_nodes():
		if (level.node_data.sid == sid): return level
	return null

# This is perhaps the ugliest code to ever be written. Behold!
func _draw() -> void:
	var segments := _get_segments()
	var seg_offset : Vector2 = Vector2.ZERO
	var seg_sep : float
	
	seg_offset.x -= get_theme_constant("margin_left")
	
	for i in segments.size():
		var segment := segments[i]
		seg_sep = segment.get_theme_constant("separation")
		
		seg_offset.x += seg_sep*2
		seg_offset.x += segment.size.x

		for level:LevelNode in segment.get_nodes():
			
			for link in level.node_data.links:
				var start_pos : Vector2 = seg_offset+level.position
				start_pos.y += level.size.y
				
				var temp_i : int = i
				
				# Path to destination level
				while temp_i < segments.size():
					
					# Not found
					if temp_i+1 >= segments.size():
						break
					
					# Connect to found sid
					elif _segment_has_sid(segments[temp_i+1], link.sid):
						var level_node := _segment_has_sid(segments[temp_i+1], link.sid)
						var dest := start_pos
						dest.x += seg_sep*2
						#dest.y += (level_node.global_position.y+level_node.size.y) - start_pos.y
						dest.y += level_node.position.y + level_node.size.y - start_pos.y
						_draw_elbow(
							start_pos, 
							dest,
							0.5
						)
						break
					
					# If not found, go to next segment
					else:
						var nodes := segments[temp_i].get_nodes()
						var next_nodes := segments[temp_i+1].get_nodes()
						if nodes.size() % 2 == next_nodes.size() % 2:
							
							var dest := start_pos
							
							# TODO Go above or below depending on if the
							# level is below or above the center.
							dest.y -= level.size.y/2
							dest.y -= segments[temp_i+1].get_theme_constant("separation")/2.0
							dest.x += seg_sep*2
							dest.x += level.size.x
							
							_draw_elbow(
								start_pos, 
								dest,
								0.2 # TODO Get exact value
							)
							start_pos = dest
						else:
							var dest := start_pos
							dest.x += segments[temp_i+1].size.x
							dest.x += seg_sep*2
							_draw_elbow(
								start_pos, 
								dest,
								0.2
							)
							start_pos = dest
					
					temp_i += 1;

func _process(_delta: float) -> void:
	queue_redraw()

func _ready() -> void:
	load_world(load("res://Resource/World/testing_world.tres"))

#func _input(input: InputEvent) -> void:
	#if input.is_action("next_dialog"):
		#if input.pressed:
			#loaded_world.segments.append_array(loaded_world.segments)
			#load_world(loaded_world)
