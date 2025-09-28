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

var player : Player
var spark_particles : GPUParticles2D

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
func _update_position(origin : Vector2, dest : Vector2) -> void:
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

## Update the weapon visual. Origin is the start position and the destination is where the focus of the weapon is.
## For players, the origin should be the center and destination the sword tip.
func update_visual(origin : Vector2, dest : Vector2) -> void: # TODO Replace by pulling origin and dest from the player.
	_update_position(origin, dest)
	_update_sparks()

## Set the player who owns this visual. Needed for most effects.
func set_player(p : Player) -> void:
	player = p
