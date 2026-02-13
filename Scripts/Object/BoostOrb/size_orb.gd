extends BoostOrb

@export var time : float = 3

@export var size_scale : float = 0.5

@export_category("Image Paths")
@export_file_path("*.png") var shrink_image : String
@export_file_path("*.png") var grow_image : String

func _ready() -> void:
	super()
	if size_scale < 1:
		$Visual/Sprite.texture = load(shrink_image)
	else:
		$GPUParticles2D.modulate = Color("ed9b3e")
		$Visual/Glow.modulate = Color(0.947, 0.617, 0.207, 1.0)
		$Visual/Particles.modulate = Color(1.0, 0.547, 0.15, 1.0)
		$Visual/Sprite.texture = load(grow_image)

func hit_effect(player : Player) -> void:
	super(player)
	$GPUParticles2D.emitting = true
	var mod : PropertyModifier = PropertyModifier.new(size_scale, PropertyModifier.ModiferType.MULTIPLY, time)
	mod.set_id("gravity_orb")
	player.add_modifier(mod, "size_scale")
