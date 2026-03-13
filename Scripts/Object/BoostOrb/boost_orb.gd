class_name BoostOrb extends StaticBody2D

## The time before the orb regenerates after use.
@export var respawn_time : float = 1.0

## The bob animation height
@export var bob_dist : float = 10.0

## The bob animation speed
@export var bob_speed : float = 1.0

## Calls reset_weapon_use() on the player when the orb is activated.
@export var reset_weapon_on_hit : bool = true

## If true, the orb cannot be struck.
@export var disabled : bool = false

@export var sound : SoundData = null

## The current time spent in the bob animation, resets after 2PI
var bob_time : float = 0.0

## The visual of the orb, typically a Node2D with multiple nodes inside.
var visual : Node2D

var alive : bool = true

var current_respawn_time : float = 0.0

func hit_effect(_player : Player) -> void:
	pass

func on_sword_hit(player : Player) -> void:
	if not alive: return
	if disabled: return
	alive = false
	
	hit_effect(player)
	if reset_weapon_on_hit: player.reset_weapon_use()
	
	if sound != null:
		Sfx.play_sound_2d(sound, global_position)

func _process(delta: float) -> void:
	
	if not alive:
		current_respawn_time += delta
		if current_respawn_time >= respawn_time: 
			current_respawn_time = 0.0 
			alive = true
			var emitter := get_node("Visual/Particles")
			if emitter and emitter is GPUParticles2D:
				emitter.emitting = true
	
	if is_instance_valid(visual):
		bob_time += delta*bob_speed
		bob_time = fmod(bob_time, 2*PI)
		visual.position.y = bob_dist * sin(bob_time)
	
		if alive and not disabled:
			visual.modulate.a = 1.0
		elif disabled:
			visual.modulate.a = 0.3
		else:
			visual.modulate.a = current_respawn_time*0.3 / respawn_time

func _ready() -> void:
	var visual_node := get_node_or_null("Visual")
	if is_instance_valid(visual_node):
		visual = visual_node
	add_to_group("BladeHitable")
