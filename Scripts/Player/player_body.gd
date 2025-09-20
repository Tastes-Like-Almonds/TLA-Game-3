extends CharacterBody2D
class_name PlayerBody

func _get_player() -> Player:
	if get_parent() is Player:
		return get_parent()
	return null

## Apply drag to the passed velocity, as per the player's stats.
## Separated from _physics_process in case multiple movement methods need it.
func _apply_drag(vel : Vector2, delta : float) -> Vector2:
	
	var player = _get_player()
	if !is_instance_valid(player): return vel
	
	var drag : Vector2
	
	if is_on_floor():
		drag = player.get_ground_drag()
	else:
		drag = player.get_air_drag()
	
	vel.x *= pow(drag.x, delta)
	vel.y *= pow(drag.y, delta)
	
	return vel

func _physics_process(delta: float) -> void:
	var player : Player = _get_player()
	var collision = player.get_last_collision()
	var sword = player.get_player_sword()
	
	match player.get_movement_mode():
		
		#region Sword Orbit
		player.MovementMode.SWORD_ORBIT:
			
			# Handle sword movement
			var push = sword.get_push()
			if push:
				velocity += sword.get_push()
			else:
				velocity.y += player.gravity

				
			# Slow the player rapidly if beyond the sword's reach
			if (global_position + velocity*delta).distance_to(sword.get_tip_global_position()) > player.max_distance*player.get_soft_limit_distance_coef():
				
				velocity *= pow(player.get_soft_limit_drag(),delta)
				
				if sword.is_on_cable():
					var dir = global_position.direction_to(sword.get_tip_global_position())
					velocity.y += dir.y*global_position.distance_squared_to(sword.get_tip_global_position())*0.005
			
			# Apply drag
			velocity = _apply_drag(velocity, delta)
			
			# Bounce
			var current_vel : Vector2 = velocity
			if move_and_slide():
				if is_on_floor():
					velocity.y = (-current_vel.y - get_last_slide_collision().get_remainder().y) * player.get_bounciness()
			
		#endregion
		
		#region Player orbit
		
		player.MovementMode.PLAYER_ORBIT:
			var tip_pos = sword.get_tip_global_position()
			var target_dir : Vector2 = tip_pos.direction_to(get_global_mouse_position())
			var goal = tip_pos + target_dir*min(player.get_max_distance(),max(player.get_min_distance()*5, tip_pos.distance_to(get_global_mouse_position())))
			velocity = global_position.direction_to(goal)*player.get_player_orbit_strength()*global_position.distance_to(goal)
			move_and_slide()
		
		#endregion

		#region Noclip
		player.MovementMode.NOCLIP:
			velocity = Vector2.ZERO
			if player.is_charging_ability():
				var body_pos = player.get_player_body().global_position
				velocity = body_pos.direction_to(get_global_mouse_position())*body_pos.distance_to(get_global_mouse_position())*10
			move_and_slide()
		#endregion

func get_sprite():
	return $Sprite2D
