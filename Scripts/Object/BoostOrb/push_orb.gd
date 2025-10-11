extends BoostOrb

@export var force : float = 1500

func on_sword_hit(player : Player) -> void:
	super(player)
	var dir := Vector2.UP.rotated(rotation)
	player.set_velocity(dir*force)
	$GPUParticles2D.emitting = true
