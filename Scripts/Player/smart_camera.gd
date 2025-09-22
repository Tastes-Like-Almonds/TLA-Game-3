class_name GameCamera extends Camera2D

enum TargetMode {
	TARGET_NODE_2D,
	TARGET_POSITION
}

@export var smooth_zoom : bool = true
@export var smooth_follow : bool = true
@export var smooth_follow_speed : float = 10
@export_range(0,3, 0.1) var zoom_speed : float = 8

var target_mode : TargetMode = TargetMode.TARGET_POSITION
var target_zoom : Vector2 = Vector2(1,1)
var target_position : Vector2 = Vector2(0,0)
var target_node : Node2D = null

## Sets the target zoom of the camera to be eased to.
func set_target_zoom(target : Vector2) -> void:
	target_zoom = target

## Set the target position of the camera. This will override setting the target node if done so
## previously.
func set_target_position(pos : Vector2) -> void:
	global_position = pos
	target_mode = TargetMode.TARGET_POSITION

## Set the target node of the camera to track. This will override setting the target position
## if done so previously.
func set_target_node(node : Node2D) -> void:
	target_node = node
	target_mode = TargetMode.TARGET_NODE_2D

func _physics_process(delta: float) -> void:
	
	var target_pos = target_position
	
	if target_mode == TargetMode.TARGET_NODE_2D:
		target_pos = target_node.global_position
	global_position = global_position.move_toward(target_pos, smooth_follow_speed*global_position.distance_to(target_pos)*delta)
	
	if smooth_zoom:
		zoom = zoom.move_toward(target_zoom, zoom_speed*zoom.distance_to(target_zoom)*delta)
