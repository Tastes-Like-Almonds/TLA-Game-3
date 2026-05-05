class_name GraphSelect extends MarginContainer

signal level_selected(level:LevelNodeData)
signal level_played(level:LevelNodeData)

@onready var segment_parent : HBoxContainer = $HBoxContainer

@onready var hover_sound : AudioStreamPlayer = $HoverSound
@onready var click_sound : AudioStreamPlayer = $ClickSound

var scn_segment : PackedScene = preload("res://Scenes/UI/Graph/world_segment.tscn")
var scn_node_line : PackedScene = preload("res://Scenes/UI/Graph/level_node_line.tscn")

var loaded_world : WorldData

var last_clicked : LevelNodeData
var last_click_time : float = 0.0

var loading_world : bool = false

const LINE_THICKNESS : float = 4.0

## Map of SIDs to their respective LevelNode objects.
var loaded_sids : Dictionary [String,LevelNode] = {}

func _on_level_selected(node:LevelNodeData) -> void:
	if last_click_time < 0.5 and last_clicked == node:
		level_played.emit(node)
	else:
		last_click_time = 0.0
		last_clicked = node
		click_sound.play()
		level_selected.emit(node)

func load_world(world:WorldData) -> void:
	
	loading_world = true
	
	loaded_world = world
	loaded_sids = {}
	
	# So this is ugly, as everything in this script, but we are passing over
	# all loaded levels several times as each pass reveals new information
	# that is needed for the later steps.
	
	# Thus, don't merge the loops into one; they need to be separate.
	
	# Delete past segments
	for child in segment_parent.get_children():
		if child is LevelSegment:
			if child.is_connected("LevelSelected", _on_level_selected):
				child.LevelSelected.disconnect(_on_level_selected)
			child.queue_free()
	
	# Load segments and register SIDs of all levels
	for segment in world.segments:
		var new_seg : LevelSegment = scn_segment.instantiate()
		new_seg.load_segment(segment)
		new_seg.LevelSelected.connect(_on_level_selected)
		segment_parent.add_child(new_seg)
		
		# Add entry in loaded_sids dictionary.
		for child in new_seg.get_nodes():
			var sid : String = child.node_data.sid
			if sid in loaded_sids:
				push_warning("Duplicate SID found in loaded world: '" + sid + "'")
			else:
				loaded_sids[sid] = child

	# Connect hover sounds and find playable levels
	for segment : LevelSegment in segment_parent.get_children():
		for child : LevelNode in segment.get_nodes():
			child.self_modulate = loaded_world.level_color
			if child.node_data.level_data.is_boss:
				child.self_modulate = loaded_world.level_boss_color

			if child.node_data.always_playable:
				child.disabled = false
				if not child.mouse_entered.is_connected(hover_sound.play):
					child.mouse_entered.connect(hover_sound.play)
			
			for link : LevelLink in child.node_data.links:
				if _can_open_level(child.node_data.sid, link):
					loaded_sids[link.sid].disabled = false
					if not loaded_sids[link.sid].mouse_entered.is_connected(hover_sound.play):
						loaded_sids[link.sid].mouse_entered.connect(hover_sound.play)
	
	# Update the display for all levels based on completion
	for segment : LevelSegment in segment_parent.get_children():
		for child : LevelNode in segment.get_nodes():
			if child.disabled:
				child.set_display_state(LevelNode.DisplayState.DISABLED)
			elif SaveSlots.get_level_exits(world.name, child.node_data.sid).size() == 0:
				child.set_display_state(LevelNode.DisplayState.NOT_COMPLETED)
			else:
				child.set_display_state(LevelNode.DisplayState.COMPLETED)

	loading_world = false

## Get all level segments in the currently loaded world.
func _get_segments() -> Array[LevelSegment]:
	var segs : Array[LevelSegment]
	for segment in segment_parent.get_children():
		if segment is LevelSegment:
			segs.append(segment)
	return segs

func _draw_elbow(
	start : Vector2, 
	end : Vector2, 
	perc : float, 
	color:Color=Color.WHITE
) -> void:
	var elbow : Vector2 = start + Vector2((end.x-start.x)*perc, 0)
	var peak : Vector2 = elbow + Vector2(0, end.y-start.y)
	draw_line(start,elbow,color,LINE_THICKNESS)
	draw_line(elbow,peak,color,LINE_THICKNESS)
	draw_line(peak,end,color,LINE_THICKNESS)

func _segment_has_sid(segment : LevelSegment, sid:String) -> LevelNode:
	for level in segment.get_nodes():
		if (level.node_data.sid == sid): return level
	return null

## Returns the levelnode associated with the given sid in this world, if any.
## Returns null and warns otherwise.
func _get_level_from_sid(sid:String) -> LevelNode:
	if sid in loaded_sids:
		return loaded_sids[sid]
	#push_warning("Linked level SID '" + sid + "' not found in world!")
	return null

## Returns true if the player has met the requirements to access the linked level
## given the exits reached from the current level (level_sid).
func _can_open_level(level_sid:String, link:LevelLink) -> bool:
	var linked := _get_level_from_sid(link.sid)
	if linked:
		var reached_exits := SaveSlots.get_level_exits(loaded_world.name, level_sid)
		if link.exit_requirement in reached_exits: return true
	else:
		pass
		#push_warning("Linked level SID '" + link.sid + "' not found in world!")
	return false

# This is perhaps the ugliest code to ever be written. Behold!
func _draw() -> void:
	if loading_world: return
	if not loaded_world: return
	var line_color := loaded_world.line_unlocked_color
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
				
				if !_can_open_level(level.node_data.sid, link):
					line_color = loaded_world.line_locked_color
				
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
							0.5,
							line_color
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
								0.2, # TODO Get exact value
								line_color
							)
							start_pos = dest
						else:
							var dest := start_pos
							dest.x += segments[temp_i+1].size.x
							dest.x += seg_sep*2
							_draw_elbow(
								start_pos, 
								dest,
								0.2,
								line_color
							)
							start_pos = dest
					
					temp_i += 1;

func _process(delta: float) -> void:
	last_click_time += delta

func _ready() -> void:
	#load_world(load("res://Resource/World/testing_world.tres"))
	
	# Redraw when size changes
	resized.connect(func() -> void:
		await get_tree().process_frame
		queue_redraw()
	)
	get_viewport().size_changed.connect(func() -> void:
		await get_tree().process_frame
		queue_redraw()
	)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		queue_redraw()

#func _input(input: InputEvent) -> void:
	#if input.is_action("next_dialog"):
		#if input.pressed:
			#loaded_world.segments.append_array(loaded_world.segments)
			#load_world(loaded_world)
