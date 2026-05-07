extends Node2D

var _debug_dots : Dictionary[String, DebugDot]

var debug_dot_scn : PackedScene = preload("res://Scenes/Debug/debug_dot.tscn")

# Cached values for performance (it helps so much)
var viewport:Viewport
var camera:Camera2D

## Returns all descendants of a node.
func get_all_descendants(node : Node) -> Array[Node]:
	var descendants: Array[Node] = []
	for child in node.get_children():
		descendants.append(child)
		descendants.append_array(get_all_descendants(child))
	return descendants

## Returns all valid children of a node, i.e. nodes which are not freeing/have been freed.
func get_all_valid_children(node : Node) -> Array[Node]:
	
	var children := node.get_children()
	var valid : Array[Node] = []
	
	for idx in range(len(children)):
		if not is_instance_valid(children[idx]): continue
		elif children[idx].is_queued_for_deletion(): continue
		valid.append(children[idx])
	
	return valid

## Returns the closest player to origin.
func get_closest_player(origin:Vector2, distance_limit : float = 10000000) -> Player:
	for node in get_tree().get_nodes_in_group("Player"):
		if node is not Player : continue
		if origin.distance_to(node.get_player_position()) <= distance_limit:
			return node
	return null

## Returns all player nodes in the tree. Note that they must both be Players and have the Player tag.
func get_all_players() -> Array[Player]:
	var players : Array[Player] = []
	for node in get_tree().get_nodes_in_group("Player"):
		if node is Player:
			players.append(node)
	return players

## Returns the vector between the center of the screen and the mouse.
func get_mouse_vec_from_center() -> Vector2:
	var mouse := viewport.get_mouse_position()
	
	var size := get_viewport_rect().size
	return (mouse - Vector2(size.x, size.y)/2)/camera.zoom

## Returns true if the line between start and end moves past the target point's x or y position.
func line_passes_point_horizontally_or_vertically(start: Vector2, end: Vector2, point: Vector2) -> bool:
	
	# Yes, there is probably a more elegant solution, but it will work.
	if start.y > point.y and end.y < point.y:
		return true
	if start.y < point.y and end.y > point.y:
		return true
	if start.x > point.x and end.x < point.x:
		return true
	if start.x < point.x and end.x > point.x:
		return true
	
	# Not horizontal or vertical
	return false

## Returns true if the passed angle is vertical.
func is_angle_roughly_vertical(ang : float, max_offset : float = PI/4) -> bool:
	return (absf(ang - PI/2)<max_offset or absf(ang - -PI/2)<max_offset)

## Returns the slide (1 - friction) based upon a collision, returning default if not applicable.
## This is used for calculating how much friction different tiles have, though may have
## other uses in the future.
func get_slide_from_collision(collision : KinematicCollision2D, default : float = 0.9, offset:Vector2=Vector2.ZERO) -> float:
	if not collision: return 0.0
	var collider := collision.get_collider()
	if collider is TileMapLayer:
		collider = collider as TileMapLayer
		
		var coords : Vector2i = collider.local_to_map(collider.to_local(collision.get_position()+offset))
		var tile_data : TileData = collider.get_cell_tile_data(coords)
		
		if tile_data:
			return 1 - tile_data.get_custom_data("friction")
	return default

## Same as get_slide_from_collision, but returns the "sword_friction" property of the given tile.
func get_sword_slide_from_collision(collision : KinematicCollision2D, default : float = 0.6) -> float:
	if not collision: return 0.0
	var collider := collision.get_collider()
	
	if collider is TileMapLayer:
						
		collider = collider as TileMapLayer
		
		var coords : Vector2i = collider.local_to_map(collider.to_local(collision.get_position()))
		var tile_data : TileData = collider.get_cell_tile_data(coords)
		
		if tile_data:
			return 1 - tile_data.get_custom_data("sword_friction")

	return default

## Given a collision, returns the colliding tile's tiledata, if the collider is a tile.
func get_tile_data_from_collision(collision : KinematicCollision2D) -> TileData:
	if not collision: return null
	var collider := collision.get_collider()
	
	if collider is TileMapLayer:
		
		collider = collider as TileMapLayer
		
		var coords : Vector2i = collider.local_to_map(collider.to_local(collision.get_position()))
		var tile_data : TileData = collider.get_cell_tile_data(coords)
		
		return tile_data

	return null

func get_tile_pos_from_collision(collision : KinematicCollision2D) -> Vector2:
	if not collision: return collision.get_position()
	var collider := collision.get_collider()
	
	if collider is TileMapLayer:
		var map := collider as TileMapLayer
		var coords : Vector2i = collider.local_to_map(collider.to_local(collision.get_position()))
		return map.to_global(map.map_to_local(coords))
	return collision.get_position()

## Cast a ray to detect collisions. Returns ray result.
func cast_world_ray(start:Vector2, dir:Vector2) -> Dictionary:
	var space_state := get_world_2d().direct_space_state
	
	var parameters := PhysicsRayQueryParameters2D.new()
	parameters.from = start
	# Theoretically only half the rect's size is needed, but in practice physics doesn't work out perfectly.
	parameters.to = parameters.from + dir
	
	parameters.collision_mask = 1 # World layer
	var result := space_state.intersect_ray(parameters)
	
	return result

## Creates a visual dot at the given position. It lasts for three seconds or until overidden.
## A debug dot is overidden if a new one is created with the same ID.
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

func print_dict_as_json(data: Dictionary) -> void:
	var json_string := JSON.stringify(data, "\t") # "\t" = tab indentation
	print(json_string)

func fade_to_selector() -> void:
	Globals.main.transiton_overlay_player.play("fade_to_black")
	
	Globals.main.transiton_overlay_player.animation_finished.connect(func(_x:Variant) -> void:
		
		SignalBus.SelectorLoaded.connect(func() -> void:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
			Globals.main.transiton_overlay_player.play("fade_from_black")
		
		,CONNECT_ONE_SHOT)
		LevelLoader.load_selector()
		
	,CONNECT_ONE_SHOT)

## Formats a time float into mm:ss.cs
func format_time(time_seconds: float) -> String:
	var total_seconds := int(time_seconds)
	@warning_ignore("integer_division") # Shut up godot I know they are integers!
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	var centiseconds := int((time_seconds - total_seconds) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, centiseconds]

## Returns true if the passed player belongs to this client.
func is_this_client(player:Player) -> bool:
	var status := player.multiplayer.multiplayer_peer.get_connection_status()
	if status == MultiplayerPeer.CONNECTION_CONNECTED:
		return player.id == player.multiplayer.get_unique_id()
	elif status == MultiplayerPeer.CONNECTION_DISCONNECTED:
		return true
	return true

## Safely saves and closes the game.
func close_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _ready() -> void:
	viewport = get_viewport()
	camera = viewport.get_camera_2d()
	SignalBus.CameraChanged.connect(func(cam:Camera2D) -> void: camera = cam)
