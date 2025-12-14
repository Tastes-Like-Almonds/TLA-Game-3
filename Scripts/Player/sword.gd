extends Node2D
class_name Sword

enum ControlMode {
	
	## Follows the actual mouse position in game space
	GLOBAL_MOUSE,
	
	## Follows the mouse relative to the center of the screen
	LOCAL_MOUSE
}

@onready var body : AnimatableBody2D = $AnimatableBody2D
@onready var body_shape : CollisionShape2D = $AnimatableBody2D/CollisionShape2D
@onready var blade : BladeArea = $Area2D

@export var control_mode : ControlMode = ControlMode.GLOBAL_MOUSE

var last_sword_velocity : Vector2
var last_frame_pos : Vector2
var last_result : Array[Node2D]
var velocity : Vector2 = Vector2.ZERO # Only used for specific movement mode(s)
var on_cable : Cable = null
var cable_speed : float = 0.0
var last_delta : float = 0.0

var cable_cooldown : float = 0.5
var current_cable_cooldown : float = 0.0

## The percentage of velocity the sword is at to its maximum.
var vel_perc : float

func _get_player() -> Player:
	if get_parent() is Player:
		return get_parent()
	return null

func _get_slide_from_last_collision() -> float:
	var collision := _get_player().get_last_collision()
	return Helper.get_slide_from_collision(collision, _get_player().get_sword_slide())

## Limits vector b to be, at most, dist away from vector a. Returns the modified b vector.
func _limit_distance(dist:float, a:Vector2, b:Vector2) -> Vector2:
	if a.distance_to(b) > dist:
		return a + (a.direction_to(b)*dist)
	return b

## Return the target position of the sword tip
func _get_target_pos() -> Vector2:
	
	var player_pos := _get_player().get_player_position()
	var player := _get_player()
	
	var distance := player.get_max_distance()
	
	var mouse_vec : Vector2 = Vector2.ZERO
	if control_mode == ControlMode.LOCAL_MOUSE:
		mouse_vec = Helper.get_mouse_vec_from_center()
	elif control_mode == ControlMode.GLOBAL_MOUSE:
		mouse_vec = get_global_mouse_position() - player_pos
	
	# Limit the sword distance
	if mouse_vec.length() < player.get_max_distance():
		distance = max(player.get_min_distance(), mouse_vec.length())
	
	var pos := player_pos + mouse_vec.normalized()*distance
	return pos

func _update_blade(_delta : float) -> void:
	var player := _get_player()
	var player_pos := player.get_player_position()
	var size := player_pos.distance_to(body.global_position)/player.get_size_scale()
	blade.rotation = player_pos.direction_to(body.global_position).angle()
	blade.collision_shape.shape.size.x = size
	blade.global_position = body.global_position + body.global_position.direction_to(player_pos)*(size*player.get_size_scale()/2)
	
	var result := blade.get_overlapping_bodies()
	result.append_array(blade.get_overlapping_areas())
	
	for hit in result:
		if hit in last_result: continue; # Prevent multiple hits while colliding
		if hit.is_in_group("BladeHitable"):
			if hit.has_method("on_sword_hit"):
				hit.call("on_sword_hit", player)
				SignalBus.BladeHit.emit(hit)
	
	last_result = result

func _physics_process(delta: float) -> void:
	
	last_delta = delta
	current_cable_cooldown = clampf(current_cable_cooldown + delta, 0, cable_cooldown)
	
	var player : Player = _get_player()
	if not player.is_alive(): return
	
	last_sword_velocity = Vector2.ZERO
	
	match player.movement_mode:
		
		player.MovementMode.SWORD_ORBIT:
			var target_pos := _get_target_pos()
			#var next_velocity := body.global_position.direction_to(target_pos)*player.get_sword_speed()*body.global_position.distance_to(target_pos)
			var next_velocity := body.global_position.direction_to(target_pos)*player.get_sword_speed() + _get_player().get_player_body().velocity
			var movement := next_velocity*delta
			
			
			# Ensure movement doesn't pass target position
			var current_pos := body.global_position
			var future_pos := body.global_position + movement
			
			if (current_pos.x < target_pos.x) != (future_pos.x < target_pos.x):
				movement.x = target_pos.x - current_pos.x
			if (current_pos.y < target_pos.y) != (future_pos.y < target_pos.y):
				movement.y = target_pos.y - current_pos.y
			
			# Used for visual / damage calculations
			vel_perc = movement.length() / next_velocity.length()
			
			last_sword_velocity = movement/delta # Get velocity per second as opposed to the frame
			last_frame_pos = body.global_position
			
			# Cables move the sword manually, so don't do physics here.
			if not is_instance_valid(on_cable):
				
				var collision := body.move_and_collide(movement)
				_get_player().set_last_collision(collision)
				
				if collision:
					var friction := _get_slide_from_last_collision()
					if collision.get_collider() is AnimatableBody2D:
						body.global_position += collision.get_collider().constant_linear_velocity
					body.move_and_collide(collision.get_remainder().slide(collision.get_normal()) * friction)
		
		player.MovementMode.PLAYER_ORBIT: # No use as of now.
			
			velocity.y += player.gravity * delta
			
			var drag : Vector2
			
			if player.get_last_collision():
				drag = player.get_ground_drag()
			else:
				drag = player.get_air_drag()
			
			velocity.x *= pow(drag.x, delta)
			velocity.y *= pow(drag.y, delta)
			
			var collision := body.move_and_collide(velocity*delta)
			if collision:
				body.move_and_collide(velocity.slide(collision.get_normal()) * _get_player().get_sword_slide())
			
			_get_player().set_last_collision(collision)
		
		player.MovementMode.NOCLIP:
			body.global_position = get_global_mouse_position()
	
	_update_blade(delta)


## Gets the velocity which should be applied to the player each frame 
## in respect to the sword's movement.
func get_push() -> Vector2:
	
	var player := _get_player()
	var collision := player.get_last_collision()
	var vel := Vector2.ZERO

	if on_cable:
		vel.y += clampf(Input.get_last_mouse_velocity().y, -player.get_sword_speed(), player.get_sword_speed()) * player.get_strength() * -last_delta
		vel.x += clampf(Input.get_last_mouse_velocity().x, -player.get_sword_speed(), player.get_sword_speed()) * player.get_strength() * -last_delta

	elif collision:
		
		# Acount for slide direction in push
		var slide_vel := (collision.get_remainder() + collision.get_travel()).slide(collision.get_normal()) * _get_slide_from_last_collision()
		vel += (collision.get_remainder() + collision.get_travel() + slide_vel) * player.get_strength() * -1 # Reverse velocity of sword

	return vel

## Gets the global position of the sword's tip.
func get_tip_global_position() -> Vector2:
	return body.global_position

## Returns the last sword velocity calculated on _physics_process. May not always be set correctly
## depending on movement mode.
func get_last_sword_velocity() -> Vector2:
	return last_sword_velocity

## Returns true if the sword is on a cable.
func is_on_cable() -> bool:
	return is_instance_valid(on_cable)

## Determines if the sword body is on the ground via raycasting. Only collides with collision layer 1.
func is_on_floor() -> bool:
	var space_state := get_world_2d().direct_space_state
	
	var parameters := PhysicsRayQueryParameters2D.new()
	parameters.from = body.global_position
	
	# Theoretically only half the rect's size is needed, but in practice physics doesn't work out perfectly.
	parameters.to = parameters.from + Vector2.DOWN * body_shape.shape.get_rect().size.y
	
	parameters.collision_mask = 1
	var result := space_state.intersect_ray(parameters)
	
	return result.size() > 0

## Similar to is_on_floor, but uses the player's gravity direction to calculate the ground.
func is_on_ground() -> bool:
	var player := _get_player()
	if not player: return false # Can't be on the ground if the player doesn't exist
	var space_state := get_world_2d().direct_space_state
	
	var parameters := PhysicsRayQueryParameters2D.new()
	parameters.from = body.global_position
	
	# Theoretically only half the rect's size is needed, but in practice physics doesn't work out perfectly.
	parameters.to = parameters.from + _get_player().get_gravity_direction() * body_shape.shape.get_rect().size.y
	
	parameters.collision_mask = 1
	var result := space_state.intersect_ray(parameters)
	
	return result.size() > 0

## Determines if the sword body is on the ceiling via raycasting. Only collides with collision layer 1.
func is_on_ceiling() -> bool:
	var space_state := get_world_2d().direct_space_state
	
	var parameters := PhysicsRayQueryParameters2D.new()
	parameters.from = body.global_position
	
	# Theoretically only half the rect's size is needed, but in practice physics doesn't work out perfectly.
	parameters.to = parameters.from + Vector2.UP * body_shape.shape.get_rect().size.y
	
	parameters.collision_mask = 1
	var result := space_state.intersect_ray(parameters)
	
	return result.size() > 0

## Enter the passed cable.
func enter_cable(cable : Cable) -> void:
	on_cable = cable

## Exit the passed cable.
func exit_cable() -> void:
	_get_player().reset_weapon_use()
	current_cable_cooldown = 0
	on_cable = null

func teleport_to_target_pos() -> void:
	body.global_position = _get_target_pos()
