class_name InfestedCockroach extends Enemy

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@export var gravity: float = 300

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

	if target_point:
		pass
		var movement := Vector2.ZERO
		if target_point.x - global_position.x < 0: # Left
			movement = Vector2(-movement_speed*delta, 0)
		else:
			movement = Vector2(movement_speed*delta, 0)
		
		velocity += Vector2.DOWN * gravity
		movement += velocity*delta
		
		var result := move_and_collide(movement*delta)
		if result:
			move_and_collide(movement.slide(result.get_normal()))

func _physics_process(delta: float) -> void:
	super(delta)
	collision_shape.disabled = respawning
