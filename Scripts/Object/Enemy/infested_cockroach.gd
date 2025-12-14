class_name InfestedCockroach extends Enemy

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var shape := $CollisionShape2D
@export var gravity: float = 3000
@export var walk_sound : AudioStreamPlayer2D

func _kill() -> void:
	super()
	$GPUParticles2D.emitting = true
	if !respawn:
		if !$GPUParticles2D.is_connected("finished", queue_free):
			$GPUParticles2D.finished.connect(queue_free)

func _movement(delta : float) -> void:
	
	velocity *= pow(0.2, delta) # Drag
	
	movement_cooldown -= delta
	
	if movement_cooldown <= 0 or not target_point: # Find target
		movement_cooldown = movement_delay + randf_range(movement_delay*-0.1,movement_delay*0.1)
		if target_player: # If there is a player found already, prioritize them
			# Cancel and redo if player out of range
			if target_player.get_player_position().distance_to(global_position) > aggro_range: target_player = null ; _movement(delta) ; return
			target_point = target_player.get_player_position()
			target_point.y += collision_shape.shape.get_rect().size.y/2
			#Helper.debug_dot(get_parent(), target_point, "EEE") # Uncomment to debug pos
		else: # If no player, set to a random one.
			target_point = global_position + Vector2(randf_range(-100,100), 0) # Random pos if no players
			var nearest_player : Player = Helper.get_closest_player(global_position, aggro_range)
			if nearest_player:
				target_player = nearest_player

	var move_speed := movement_speed
	if abs(target_point.x - global_position.x) < movement_speed*delta:
		# Prevent shaking when arriving at point
		move_speed = 0

	if target_point:
		var movement := Vector2.ZERO
		if target_point.x - global_position.x < 0: # Left
			movement = Vector2(-move_speed, 0)
		else:
			movement = Vector2(move_speed, 0)
		
		velocity += Vector2.DOWN * gravity*delta # Gravity
		
		if target_point.y < global_position.y - 40:
			if ray_is_on_floor():
				#print("ON FLOOR")
				velocity.y = -800
		
		#print(velocity.y)
		
		#var og_pos := global_position
		var total_movement := movement+velocity
		var result := move_and_collide((total_movement)*delta)
		if result:
			move_and_collide(total_movement.slide(result.get_normal())*delta)
		
		# If not moving, stop the walking sound. Otherwise, play it.
		#if respawning or (absf(global_position.x - og_pos.x) > move_speed*delta): walk_sound.stop()
		#elif not walk_sound.playing: walk_sound.play() ; print("START")

func ray_is_on_floor(length:float = 3) -> Dictionary:
	var space_state := get_world_2d().direct_space_state
	
	var parameters := PhysicsRayQueryParameters2D.new()
	parameters.from = global_position
	
	# Theoretically only half the rect's size is needed, but in practice physics doesn't work out perfectly.
	parameters.to = parameters.from + Vector2.DOWN * (shape.shape.get_rect().size.y/2 + shape.position.y)
	parameters.to = parameters.to.normalized()*length + parameters.to # Add unit vector
	
	parameters.collision_mask = 1
	var result := space_state.intersect_ray(parameters)
	
	return result

func _physics_process(delta: float) -> void:
	super(delta)
	collision_shape.disabled = respawning
