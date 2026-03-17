extends BoostOrb

@export var time : float = 3

@export var size_scale : float = 0.5

@export var sound_shrink : SoundData
@export var sound_grow : SoundData
@export var sound_normal : SoundData

@export_category("Image Paths")
@export_file_path("*.png") var shrink_image : String
@export_file_path("*.png") var grow_image : String
@export_file_path("*.png") var normal_image : String

func _ready() -> void:
	super()
	if size_scale < 1:
		$Visual/Sprite.texture = load(shrink_image)
		$GPUParticles2D.modulate = Color(0.361, 0.724, 0.944, 1.0)
		$Visual/Glow.modulate = Color(0.361, 0.724, 0.944, 1.0)
		$Visual/Particles.modulate = Color(0.361, 0.724, 0.944, 1.0)
	elif size_scale > 1:
		$Visual/Sprite.texture = load(grow_image)
		$GPUParticles2D.modulate = Color("ed9b3e")
		$Visual/Glow.modulate = Color(0.947, 0.617, 0.207, 1.0)
		$Visual/Particles.modulate = Color(1.0, 0.547, 0.15, 1.0)
	else:
		$Visual/Sprite.texture = load(normal_image)
		$GPUParticles2D.modulate = Color("ffffff")
		$Visual/Glow.modulate = Color("ffffff")
		$Visual/Particles.modulate = Color("ffffff")

func hit_effect(player : Player) -> void:
	super(player)
	$GPUParticles2D.emitting = true
	var mod : PropertyModifier = PropertyModifier.new(size_scale, PropertyModifier.ModiferType.MULTIPLY, time)
	mod.reset_on_respawn = false
	mod.set_id("gravity_orb")
	player.add_modifier(mod, "size_scale")
	
	if size_scale < 1:
		if sound_shrink: Sfx.play_sound_2d(sound_shrink, global_position)
	
	elif size_scale > 1:
		if sound_grow: Sfx.play_sound_2d(sound_grow, global_position)
	
	else:
		if sound_normal: Sfx.play_sound_2d(sound_normal, global_position)
