extends CharacterBody2D
class_name PlayerBody

func _get_player() -> Player:
	if get_parent() is Player:
		return get_parent()
	return null

func _physics_process(delta: float) -> void:
	var player = _get_player()
	var collision = player.get_last_collision()
	var sword = player.get_player_sword()
	
	var drag : Vector2
	
	if is_on_floor():
		drag = player.get_ground_drag()
	else:
		drag = player.get_air_drag()
	
	
	if collision:
		velocity += collision.get_remainder() * player.get_strength() * -1 # Reverse velocity of sword
		
		# Slow the player rapidly if beyond the sword's reach
		if (global_position + velocity*delta).distance_to(sword.body.global_position) > player.max_distance*player.get_soft_limit_distance_coef():
			drag *= pow(player.get_soft_limit_drag(),delta)
	else:
		velocity.y += player.gravity * delta
	
	velocity.x *= pow(drag.x, delta)
	velocity.y *= pow(drag.y, delta)
	
	move_and_slide()
