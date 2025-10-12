extends BoostOrb

@export var force : float = 1500

func hit_effect(player : Player) -> void:
	super(player) 
	var dir := Vector2.UP.rotated(rotation)
	player.set_velocity(dir*force)
	$GPUParticles2D.emitting = true
