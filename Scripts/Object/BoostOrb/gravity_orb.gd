extends BoostOrb

@export var time : float = 3

func on_sword_hit(player : Player) -> void:
	super(player)
	var mod : PropertyModifier = PropertyModifier.new(-1, PropertyModifier.ModiferType.MULTIPLY, time)
	player.add_modifier(mod, "gravity")
	$GPUParticles2D.emitting = true
