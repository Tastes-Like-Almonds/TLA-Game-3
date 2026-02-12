extends BoostOrb

@export var time : float = 3

@export var size_scale : float = 0.5

@export_category("Image Paths")


func hit_effect(player : Player) -> void:
	super(player)
	$GPUParticles2D.emitting = true
	var mod : PropertyModifier = PropertyModifier.new(size_scale, PropertyModifier.ModiferType.MULTIPLY, time)
	mod.set_id("gravity_orb")
	player.add_modifier(mod, "size_scale")
