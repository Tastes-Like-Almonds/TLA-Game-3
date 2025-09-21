extends Area2D

@onready var collision_shape : CollisionShape2D = $CollisionShape2D

## If true, will only update the camera if it is a GameCamera
@export var smart_camera_only : bool = true

## On collision, the camera will be targeted at the given node.
@export var target_node : Node2D

## The target zoom of the camera
@export var target_zoom : Vector2 = Vector2(1,1)

## If true, will track the player instead of the target node.
@export var track_player : bool = false

func _update_camera(player : Player) -> void:
	if track_player:
		
		if player:
			var cam = get_viewport().get_camera_2d()
			
			if cam is GameCamera:
				cam.set_target_zoom(target_zoom)
				cam.set_target_node(player.get_player_body())
			else:
				if smart_camera_only: return
				cam.zoom = target_zoom
		
	elif is_instance_valid(target_node):
		var cam = get_viewport().get_camera_2d()
		if cam is GameCamera:
				cam.set_target_zoom(target_zoom)
				cam.set_target_node(target_node)
		else:
			if smart_camera_only: return
			cam.zoom = target_zoom

func _check_collision(body : PhysicsBody2D) -> void:
	if body is PlayerBody:
		_update_camera(body.get_player())

func _ready() -> void:
	body_entered.connect(_check_collision)
