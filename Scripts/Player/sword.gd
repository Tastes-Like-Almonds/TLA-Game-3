extends Node2D
class_name Sword

@onready var body : AnimatableBody2D = $AnimatableBody2D

func _get_player() -> Player:
	if get_parent() is Player:
		return get_parent()
	return null

## Limits vector b to be, at most, dist away from vector a. Returns the modified b vector.
func _limit_distance(dist:float, a:Vector2, b:Vector2) -> Vector2:
	if a.distance_to(b) > dist:
		return a + (a.direction_to(b)*dist)
	return b

## Return the target position of the sword tip
func _get_target_pos() -> Vector2:
	
	var player_pos = _get_player().get_player_position()
	var player = _get_player()
	
	var distance = player.get_max_distance()
	
	# Limit the sword distance
	if player_pos.distance_to(get_global_mouse_position()) < player.get_max_distance():
		distance = max(player.get_min_distance(), player_pos.distance_to(get_global_mouse_position()))
	
	var pos = player_pos + player_pos.direction_to(get_global_mouse_position())*distance
	return pos

func _physics_process(delta: float) -> void:
	var target_pos = _get_target_pos()
	var movement = body.global_position.direction_to(target_pos)*30*delta*body.global_position.distance_to(target_pos)
	var collision : KinematicCollision2D = body.move_and_collide(movement)
	_get_player().set_last_collision(collision)
	#body.constant_linear_velocity = target_pos
	#body.apply_central_force(body.global_position.direction_to(target_pos)*200.0*body.global_position.distance_to(target_pos))
	#body.global_position = _limit_distance(max_distance, _get_player().get_player_position(), body.global_position)
