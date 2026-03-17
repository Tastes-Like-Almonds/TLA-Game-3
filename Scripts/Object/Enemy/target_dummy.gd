class_name TargetDummy extends Enemy

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var shape := $CollisionShape2D

signal HitBy(player:Player)

func _kill() -> void:
	super()
	$GPUParticles2D.emitting = true
	if !respawn:
		if !$GPUParticles2D.is_connected("finished", queue_free):
			$GPUParticles2D.finished.connect(queue_free)

func _respawn() -> void:
	super()
	sprite.play("spawn")
	#sprite.animation_finished.connect(func(_x:Variant) -> void: respawning = false)

func on_sword_hit(player : Player) -> void:
	HitBy.emit(player)
	super(player)
	sprite.play("hit")

func _movement(_delta : float) -> void:
	return

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
