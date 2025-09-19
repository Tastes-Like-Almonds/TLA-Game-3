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
		var slide_vel = (collision.get_remainder() + collision.get_travel()).slide(collision.get_normal()) * player.get_sword_slide()
		velocity += (collision.get_remainder() + collision.get_travel() + slide_vel) * player.get_strength() * -1 # Reverse velocity of sword
		
		# Slow the player rapidly if beyond the sword's reach
		if (global_position + velocity*delta).distance_to(sword.body.global_position) > player.max_distance*player.get_soft_limit_distance_coef():
			drag *= pow(player.get_soft_limit_drag(),delta)
	else:
		velocity.y += player.gravity * delta
	
	velocity.x *= pow(drag.x, delta)
	velocity.y *= pow(drag.y, delta)
	
	var current_vel : Vector2 = velocity
	
	if move_and_slide():
		if is_on_floor():
			velocity.y = (-current_vel.y - get_last_slide_collision().get_remainder().y) * player.get_bounciness()

func get_sprite():
	return $Sprite2D
