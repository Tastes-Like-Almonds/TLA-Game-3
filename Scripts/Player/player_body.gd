## The body of the player.

class_name PlayerBody extends CharacterBody2D

@onready var shape : CollisionShape2D = $CollisionShape2D

var last_slide : float = 1.0

func get_player() -> Player:
	if get_parent() is Player:
		return get_parent()
	return null

## Apply drag to the passed velocity, as per the player's stats.
## Separated from _physics_process in case multiple movement methods need it.
func _apply_drag(vel : Vector2, delta : float) -> Vector2:
	
	var player : Player = get_player()
	if !is_instance_valid(player): return vel
	
	var drag : Vector2
	
	if is_on_floor():
		drag = Vector2.ONE
		drag.x = Helper.get_slide_from_collision(get_last_slide_collision(), last_slide)
		last_slide = drag.x
		vel.x *= pow(drag.x, delta/player.get_friction_time())
	else:
		drag = player.get_air_drag()
		vel.x *= pow(drag.x, delta)
	
	vel.y *= pow(drag.y, delta)
	
	return vel

func _check_damage_collisions(collision : KinematicCollision2D) -> void:
	var player := get_player()
	
	if not collision: return
	if collision.get_collider() is TileMapLayer:
		
		var tile_data := Helper.get_tile_data_from_collision(collision)
		
		if tile_data:
			var contact_damage : Variant = tile_data.get_custom_data("contact_damage")
			if contact_damage is int and contact_damage > 0:
				if player.deal_damage(contact_damage):
					var kb := ((Helper.get_tile_pos_from_collision(collision).direction_to(global_position))*1000)
					player.deal_knockback(kb)

## Determines if the player is on the ground via raycasting. Only collides with collision layer 1.
func ray_is_on_floor() -> Dictionary:
	var space_state := get_world_2d().direct_space_state
	
	var parameters := PhysicsRayQueryParameters2D.new()
	parameters.from = global_position
	
	# Theoretically only half the rect's size is needed, but in practice physics doesn't work out perfectly.
	parameters.to = parameters.from + Vector2.DOWN * shape.shape.get_rect().size.y
	
	parameters.collision_mask = 1
	var result := space_state.intersect_ray(parameters)
	
	return result

func _physics_process(delta: float) -> void:
	var player : Player = get_player()
	var sword := player.get_player_sword()
	
	# Reset velocity to prevent it staying and colliding after respawn.
	if not player.is_alive(): velocity = Vector2.ZERO ; return
	
	match player.get_movement_mode():
		
		#region Sword Orbit
		player.MovementMode.SWORD_ORBIT:
			
			# Handle sword movement
			var push := sword.get_push()
			if push:
				# Reset y velocity if landing as to prevent bounce
				if velocity.y > 0 and sword.is_on_floor():
					velocity.y = 0
				if velocity.y < 0 and sword.is_on_ceiling():
					velocity.y = 0
				velocity += sword.get_push()  
			else: # Only apply gravity if the sword isn't pushing
				velocity.y += player.get_gravity()*delta
				
			# Slow the player rapidly if beyond the sword's reach
			if (global_position + velocity*delta).distance_to(sword.get_tip_global_position()) > player.get_max_distance()*player.get_soft_limit_distance_coef():
				
				velocity *= pow(player.get_soft_limit_drag(),delta)
				
				if sword.is_on_cable():
					var dir := global_position.direction_to(sword.get_tip_global_position())
					velocity += dir*global_position.distance_squared_to(sword.get_tip_global_position())*0.005
			
			# Apply drag
			velocity = _apply_drag(velocity, delta)
			
			# Bounce
			var current_vel : Vector2 = velocity
			_check_damage_collisions(get_last_slide_collision())
			if move_and_slide():
				if is_on_floor():
					velocity.y = (-current_vel.y - get_last_slide_collision().get_remainder().y) * player.get_bounciness()
			
			
			
		#endregion
		
		#region Player orbit
		
		player.MovementMode.PLAYER_ORBIT:
			var tip_pos := sword.get_tip_global_position()
			var target_dir : Vector2 = tip_pos.direction_to(get_global_mouse_position())
			var goal : Vector2 = tip_pos + target_dir*min(player.get_max_distance(),max(player.get_min_distance()*5, tip_pos.distance_to(get_global_mouse_position())))
			velocity = global_position.direction_to(goal)*player.get_player_orbit_strength()*global_position.distance_to(goal)
			move_and_slide()
		
		#endregion

		#region Noclip
		player.MovementMode.NOCLIP:
			velocity = Vector2.ZERO
			if player.is_charging_ability():
				var body_pos := player.get_player_body().global_position
				velocity = body_pos.direction_to(get_global_mouse_position())*body_pos.distance_to(get_global_mouse_position())*10
			move_and_slide()
		#endregion

func get_sprite() -> Variant:
	return $Sprite2D
