class_name HealthPickup extends BoostOrb

## The amount the player heals upon pickup.
@export var amt : float = 2.0

func hit_effect(player : Player) -> void:
	super(player) 
	player.heal(amt)
	GameCamera.shake_current_camera(get_viewport(), 0.1)
	$GPUParticles2D.emitting = true
