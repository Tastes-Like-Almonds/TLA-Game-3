## Handles the cosmetic portion (sound + visuals) of weapons. 
##
## Subclasses are to override the most specific function to change visuals, 
## calling super() if possible.

@abstract class_name WeaponVisual extends Node

## Offset applied to the weapon sprite when aligning
@export_range(0,360,0.1,"degrees") var rotation_offset : float = 45.0

# --- #
@export_group("Sparks")

## The minimum speed per second for sparks to appear
@export var spark_threshold : float = 1000.0

## The number which the sword's speed is divided by to get the spark amount. This divides the speed
## per second, so the number should be pretty high.
@export var spark_divisor : float = 10000.0

## The multiplier of sparks if the player is on a cable.
@export var spark_cable_multi : float = 5.0

# -- #
@export_group("Sounds")

# - #
@export_subgroup("Drag")

## Sound file to use, Ideally set to loop.
@export_global_file(".wav", ".mp3") var drag_sound : String = "res://Assets/Sound/SFX/Player/Sword/Sword Slide Edit 1 Export 1.mp3"

## The speed of the sword at which the drag sound is at its maximum.
@export var drag_speed_max : float = 1000.0

# - #
@export_subgroup("Cable")

## Sound file to use, Ideally set to loop.
@export_global_file(".wav", ".mp3") var cable_sound : String = "res://Assets/Sound/SFX/Player/Zipline/Zipline Loop Edit 1 Export 1 (1).mp3"

## The speed of the sword at which the drag sound is at its maximum.
@export var cable_speed_max : float = 500.0

# - #
@export_subgroup("Swing")

## Sound to be used when the sword is flying through the air.
@export_global_file(".wav", ".mp3") var swing_sound : String = "res://Assets/Sound/SFX/Player/Sword/Sword Swing Edit 1 Export 1.mp3"

## Coefficient of the swing sound's pitch
@export var swing_pitch : float = 1.0

var player : Player
var spark_particles : GPUParticles2D

var drag_sound_node : AudioStreamPlayer2D
var swing_sound_node : AudioStreamPlayer2D
var cable_sound_node : AudioStreamPlayer2D

## Return true if the weapon is dragging on the ground past the given threshold of speed.
func _is_dragging(threshold : float = 1000.0) -> bool:
	var last_sword_vel := player.get_player_sword().get_last_sword_velocity()
	if (player.get_last_collision() != null and last_sword_vel.length() > threshold):
		return true
	if player.get_player_sword().is_on_cable():
		return true
	return false

## Gets the sprite of this visual. Can be either Sprite2D or AnimatedSprite2D.
## By default returns the first child matching either, but can be overridden
## if multiple sprites are present.
func _get_sprite() -> Variant:
	for child in get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			return child
	return null

## Creates and returns a spark particles node. This does not check if one exists already,
## so use mindfully. Override this function in a weapon visual if you wish to replace
## the particles.
func _create_spark_particles() -> GPUParticles2D:
	var particles : GPUParticles2D = load("res://Scenes/Visual/Particles/sparks.tscn").instantiate()
	
	var sprite : Variant = _get_sprite()
	if sprite:
		sprite.add_child(particles)
		return particles
	
	push_warning("Sprite not set for weapon visual!")
	return null

## Gets the spark GPPUParticles2D of this visual. If it has not yet been created, it will do so.
func _get_spark_particles() -> GPUParticles2D:
	if is_instance_valid(spark_particles):
		return spark_particles
	spark_particles = _create_spark_particles()
	return spark_particles

## Updates the position and rotation to match the origin and destination.
func _update_position(_delta: float) -> void:
	var origin := player.get_player_position()
	var dest := player.get_player_sword().get_tip_global_position()
	var sprite : Variant = _get_sprite()
	sprite.global_position = dest
	sprite.rotation = origin.direction_to(dest).angle() + deg_to_rad(rotation_offset)

## Updates the spark effect based on the sword's dragging across the ground.
func _update_sparks() -> void:
	var sparks : GPUParticles2D = _get_spark_particles()
	sparks.emitting = _is_dragging(spark_threshold)
	
	var vel := player.get_player_sword().get_last_sword_velocity()
	var speed := vel.length()
	if player.get_player_sword().is_on_cable():
		speed *= spark_cable_multi
	sparks.amount_ratio = (speed-spark_threshold) / spark_divisor

	sparks.process_material.direction = Vector3(vel.x, vel.y, 0)

## Update the audio part of the weapon.
func update_audio(_delta : float) -> void:
	if not is_instance_valid(player): return
	
	var sword := player.get_player_sword()
	
	# Drag sound
	if is_instance_valid(drag_sound_node):
		
		if sword.on_cable:
			
			swing_sound_node.playing = false
			drag_sound_node.playing = false
			
			if cable_sound_node.playing == false:
				cable_sound_node.play()
				
			var speed := absf(sword.cable_speed)
			
			cable_sound_node.volume_linear = clampf(speed/cable_speed_max, 0.0, 1.0)
			cable_sound_node.pitch_scale = clampf(speed/cable_speed_max, 4, 6)/4
				
		elif _is_dragging(0):
			
			swing_sound_node.playing = false
			cable_sound_node.playing = false
			
			if drag_sound_node.playing == false:
				var vel := sword.get_last_sword_velocity()
				var speed := vel.length()
				
				drag_sound_node.play()
				drag_sound_node.volume_linear = clampf(speed/drag_speed_max, 0.0, 1.0)
				drag_sound_node.pitch_scale = clampf(speed/drag_speed_max, 4, 8)/4
				
		else:
			
			drag_sound_node.playing = false
			cable_sound_node.playing = false
			
			if not swing_sound_node.playing:
				swing_sound_node.playing = true
			
			var perc := player.get_sword_speed_perc()
			perc = pow(perc, 2)
			swing_sound_node.volume_linear = clampf(lerpf(swing_sound_node.volume_linear, perc, 0.3), 0.0, 1.0)
			swing_sound_node.pitch_scale = lerpf(swing_sound_node.pitch_scale,(1+(perc-0.5)*0.2)*swing_pitch,0.1)

## Update the weapon visual. Origin is the start position and the destination is where the focus of the weapon is.
## For players, the origin should be the center and destination the sword tip.
func update_visual(delta : float) -> void: # TODO Replace by pulling origin and dest from the player.
	_update_position(delta)
	_update_sparks()

## Set the player who owns this visual. Needed for most effects.
func set_player(p : Player) -> void:
	player = p

func _ready() -> void:
	
	# Create the dragging sound
	if not is_instance_valid(drag_sound_node):
		drag_sound_node = AudioStreamPlayer2D.new()
		drag_sound_node.stream = load(drag_sound)
		drag_sound_node.autoplay = false
		_get_sprite().add_child(drag_sound_node)
	
	# Create swinging sound
	if not is_instance_valid(swing_sound_node):
		swing_sound_node = AudioStreamPlayer2D.new()
		swing_sound_node.stream = load(swing_sound)
		swing_sound_node.autoplay = false
		_get_sprite().add_child(swing_sound_node)
	
	# Create swinging sound
	if not is_instance_valid(cable_sound_node):
		cable_sound_node = AudioStreamPlayer2D.new()
		cable_sound_node.stream = load(cable_sound)
		cable_sound_node.autoplay = false
		_get_sprite().add_child(cable_sound_node)
