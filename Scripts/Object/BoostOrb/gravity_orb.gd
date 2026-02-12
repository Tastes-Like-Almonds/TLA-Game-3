extends BoostOrb

@export var time : float = 3

## If true, reverses the gravity of the player when tocuhed. If false, it sets it back to normal. 
@export var reverse : bool = true

@export_category("Image Paths")


func hit_effect(player : Player) -> void:
	super(player)
	$GPUParticles2D.emitting = true
	if reverse:
		var mod : PropertyModifier = PropertyModifier.new(-1, PropertyModifier.ModiferType.MULTIPLY, time)
		mod.set_id("gravity_orb")
		player.add_modifier(mod, "gravity")
		
	else:
		player.remove_modifier_by_id("gravity_orb", "gravity")

func _ready() -> void:
	super()
	if not reverse:
		$Visual/GPUParticles2D2.process_material.direction.y = 1
