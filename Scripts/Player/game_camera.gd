class_name GameCamera extends Camera2D

enum TargetMode {
	TARGET_NODE_2D,
	TARGET_POSITION
}

@export_group("Zoom")
## If true, Smoothly alters zoom to the target amount.
@export var smooth_zoom : bool = true

## If true, the camera zooms in correspondence to its speed.
@export var zoom_with_velocity: bool = true

## If zoom_with_velocity is true, it will zoom to the point where it reaches the camera's predicted
## location x seconds from now, where x is this variable.
@export var zoom_with_vel_time : float = 0.1

## The speed at which zoom will change, if smooth_zoom_enabled, per second.
@export_range(0,3, 0.1) var zoom_speed : float = 8

@export_group("Position")
## The speed at which the camera moves.
@export var smooth_follow_speed : float = 10

## If true, smoothly moves to the target position
@export var smooth_follow : bool = true

@export_group("Shake")
## The coefficient of screen_shake per second.
@export var shake_coef : float = 0.01

## The max distance which the screen will shake.
@export var shake_distance : Vector2 = Vector2(100,100)

var target_mode : TargetMode = TargetMode.TARGET_POSITION
var target_zoom : Vector2 = Vector2(1,1)
var target_position : Vector2 = Vector2(0,0)
var target_node : Node2D = null

var target_player : Player

## The current screen shake [0-1]
var screen_shake : float = 0.0

## The last velocity of the camera, acounting for delta.
var last_vel : Vector2 = Vector2.ZERO

## Shake the current viewport's GameCamera, if it has one.
static func shake_current_camera(viewport : Viewport, amt : float) -> void:
	
	var cam := viewport.get_camera_2d()
	
	if not cam: return
	if cam is GameCamera:
		cam.add_shake(amt)

## Set the current viewport's GameCamera's screen shake, if it has one.
## If min is true (default), the value will be set to a minimum of amt, but can still exceed it.
static func set_current_camera_shake(viewport : Viewport, amt : float, set_min : bool = true) -> void:
	
	var cam := viewport.get_camera_2d()
	
	if not cam: return
	if cam is GameCamera:
		if set_min: cam.screen_shake = max(cam.screen_shake, amt)
		else: cam.screen_shake = amt
			

func add_shake(amt : float) -> void:
	screen_shake = clampf(screen_shake+amt, 0.0, 1.0)

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
	if target_node is Player: target_player = target_node
	elif target_node is PlayerBody: target_player = target_node.get_player()

func _physics_process(delta: float) -> void:
	
	# Physics process is used to sync with player movement; player vibrates otherwise.
	
	var target_pos := target_position
	var last_pos := global_position
	
	if target_mode == TargetMode.TARGET_NODE_2D:
		target_pos = target_node.global_position
	global_position = global_position.move_toward(target_pos, smooth_follow_speed*global_position.distance_to(target_pos)*delta)
	last_vel = global_position - last_pos
	
	var current_target_zoom := target_zoom
	
	# Calculate zoom based on velocity
	if zoom_with_velocity:
		var speed := last_vel
		var rect := get_viewport_rect()
		
		var target_speed_rect := rect
		target_speed_rect.position += speed * zoom_with_vel_time/delta
		
		# Gets the rect formed by the current and future camera position, then scales the current
		# camera zoom to match the coverage.
		var target_rect := get_viewport_rect().merge(target_speed_rect)
		var speed_target_zoom :float = 1/max(target_rect.size.x/rect.size.x, target_rect.size.y/rect.size.y)
		
		# Ensure zoom doesn't stretch the camera
		current_target_zoom *= Vector2(speed_target_zoom, speed_target_zoom)
		
	if target_player:
		current_target_zoom /= target_player.get_size_scale()
	
	if smooth_zoom:
		zoom = zoom.move_toward(current_target_zoom, zoom_speed*zoom.distance_to(current_target_zoom)*delta)
	else:
		zoom = current_target_zoom
	
	offset = Vector2(randf_range(0,shake_distance.x)*screen_shake,randf_range(0,shake_distance.y)*screen_shake)
	screen_shake = clampf(screen_shake*pow(shake_coef, delta), 0, 1.0)
