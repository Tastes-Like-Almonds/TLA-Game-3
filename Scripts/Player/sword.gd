extends Node2D
class_name Sword

@onready var body : AnimatableBody2D = $AnimatableBody2D
@onready var blade : BladeArea = $Area2D

var last_sword_velocity : Vector2
var last_result
var velocity : Vector2 = Vector2.ZERO # Only used for specific movement mode(s)
var on_cable : Cable = null
var cable_speed : float = 0.0

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

func _update_blade(_delta) -> void:
	var player = _get_player()
	var player_pos = player.get_player_position()
	var size = player_pos.distance_to(body.global_position)
	blade.rotation = player_pos.direction_to(body.global_position).angle()
	blade.collision_shape.shape.size.x = size
	blade.global_position = body.global_position + body.global_position.direction_to(player_pos)*size/2
	
	var result = blade.get_overlapping_bodies()
	
	for hit in result:
		if hit in last_result: continue; # Prevent multiple hits while colliding
		if hit.is_in_group("BladeHitable"):
			if hit.has_method("on_sword_hit"):
				hit.call("on_sword_hit", player)
				SignalBus.BladeHit.emit(hit)
	
	last_result = result

func _physics_process(delta: float) -> void:
	
	var player : Player = _get_player()
	
	last_sword_velocity = Vector2.ZERO
	
	match player.movement_mode:
		
		player.MovementMode.SWORD_ORBIT:
			var target_pos = _get_target_pos()
			var movement = body.global_position.direction_to(target_pos)*30*delta*body.global_position.distance_to(target_pos)
			
			last_sword_velocity = movement * (1/delta) # Get velocity per second as opposed to the frame
			
			if not on_cable:
				var collision = body.move_and_collide(movement)
				
				if collision:
					body.move_and_collide(movement.slide(collision.get_normal()) * _get_player().get_sword_slide())
				
				_get_player().set_last_collision(collision)
		
		player.MovementMode.PLAYER_ORBIT:
			
			velocity.y += player.gravity * delta
			
			var drag : Vector2
			
			if player.get_last_collision():
				drag = player.get_ground_drag()
			else:
				drag = player.get_air_drag()
			
			velocity.x *= pow(drag.x, delta)
			velocity.y *= pow(drag.y, delta)
			
			var collision = body.move_and_collide(velocity*delta)
			if collision:
				body.move_and_collide(velocity.slide(collision.get_normal()) * _get_player().get_sword_slide())
			
			_get_player().set_last_collision(collision)
		
		player.MovementMode.NOCLIP:
			body.global_position = get_global_mouse_position()
	
	_update_blade(delta)

func get_push() -> Vector2:
	
	var player = _get_player()
	var collision = player.get_last_collision()
	var vel := Vector2.ZERO
	
	#if on_cable:
		#var target = _get_target_pos()
		#vel += body.global_position.direction_to(target)*player.get_strength()* -0.1 * body.global_position.distance_to(player.get_player_position())
		#vel += player.get_player_position().direction_to(body.global_position) * 100

	if on_cable:
		vel.y += Input.get_last_mouse_velocity().y * -0.05

	elif collision:
		var slide_vel = (collision.get_remainder() + collision.get_travel()).slide(collision.get_normal()) * player.get_sword_slide()
		vel += (collision.get_remainder() + collision.get_travel() + slide_vel) * player.get_strength() * -1 # Reverse velocity of sword

	return vel

func get_tip_global_position() -> Vector2:
	return body.global_position

func get_last_sword_velocity() -> Vector2:
	return last_sword_velocity

func is_on_cable() -> bool:
	return is_instance_valid(on_cable)

func enter_cable(cable : Cable):
	on_cable = cable

func exit_cable():
	on_cable = null
