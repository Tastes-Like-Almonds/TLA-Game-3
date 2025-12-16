class_name Bat extends Enemy

@onready var collision_shape : CollisionShape2D = $CollisionShape2D

func _kill() -> void:
	super()
	$GPUParticles2D.emitting = true
	if !respawn:
		if !$GPUParticles2D.is_connected("finished", queue_free):
			$GPUParticles2D.finished.connect(queue_free)

func _movement(delta : float) -> void:
	
	velocity *= pow(0.2, delta)
	
	movement_cooldown -= delta
	
	if movement_cooldown <= 0 or not target_point:
		movement_cooldown = movement_delay + randf_range(movement_delay*-0.1,movement_delay*0.1)
		if target_player:
			# Cancel and redo if player out of range
			if target_player.get_player_position().distance_to(global_position) > aggro_range: target_player = null ; _movement(delta) ; return
			target_point = target_player.get_player_position()
			target_point.y -= collision_shape.shape.get_rect().size.y/2
		else:
			# Set to random point if no target found
			target_point = Vector2(cos(randf()*2*PI), sin(randf()*2*PI))*100.0 + global_position
			var nearest_player : Player = Helper.get_closest_player(global_position, aggro_range)
			if nearest_player:
				target_player = nearest_player
	
	var move_speed := movement_speed
	if global_position.distance_to(target_point) < movement_speed*delta:
		move_speed = global_position.distance_to(target_point)

	if target_point:
		var movement := global_position.direction_to(target_point)*move_speed*delta + velocity*delta
		var result := move_and_collide(movement)
		if result:
			move_and_collide(movement.slide(result.get_normal()))
			if result.get_collider() is PlayerBody:
				on_hit(result.get_collider())

func _physics_process(delta: float) -> void:
	super(delta)
	collision_shape.disabled = respawning

func _ready() -> void:
	super()
	notifier.rect = collision_shape.shape.get_rect()
