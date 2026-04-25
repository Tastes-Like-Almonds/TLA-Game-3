class_name BoostOrb extends StaticBody2D

signal Hit()

@export_group("Orb Settings")
## The time before the orb regenerates after use.
@export var respawn_time : float = 1.0

## Calls reset_weapon_use() on the player when the orb is activated.
@export var reset_weapon_on_hit : bool = true

## If true, the orb cannot be struck.
@export var disabled : bool = false

## If true, the orb will regenerate upon a player's death.
@export var reset_on_death : bool = false

## If true, the orb will delete upon being struck.
@export var free_on_hit : bool = false

## If greater than zero, the orb will despawn after this amount of time.
@export var lifetime : float = 0.0

@export_group("Movement")
## The bob animation height
@export var bob_dist : float = 10.0

## The bob animation speed
@export var bob_speed : float = 1.0

## The speed and direction which the orb moves per second.
@export var movement : Vector2

## The rotation (in radians) applied per second.
@export var rotation_speed : float

@export_group("Sound")
@export var sound : SoundData = null

## The current time spent in the bob animation, resets after 2PI
var bob_time : float = 0.0

## The visual of the orb, typically a Node2D with multiple nodes inside.
var visual : Node2D

var alive : bool = true

var time_alive : float = 0.0

var current_respawn_time : float = 0.0


func hit_effect(_player : Player) -> void:
	pass

func _player_death(_player : Player) -> void:
	if reset_on_death:
		_respawn()

func on_sword_hit(player : Player) -> void:
	if not alive: return
	if disabled: return
	alive = false
	
	Hit.emit()
	hit_effect(player)
	if reset_weapon_on_hit: player.reset_weapon_use()
	
	if sound != null:
		Sfx.play_sound_2d(sound, global_position)

func _modulate() -> void:
	if alive and not disabled:
		visual.modulate.a = 1.0
	elif disabled:
		visual.modulate.a = 0.3
	else:
		visual.modulate.a = current_respawn_time*0.3 / respawn_time

func _respawn() -> void:
	current_respawn_time = 0.0 
	alive = true
	var emitter := get_node("Visual/Particles")
	if emitter and emitter is GPUParticles2D:
		emitter.emitting = true

func _death_process(delta : float) -> void:
	if modulate.a <= 0: queue_free()
	else: modulate.a -= delta

func _process(delta: float) -> void:
	
	time_alive += delta
	
	if (lifetime > 0) and (time_alive > lifetime):
		_death_process(delta)
	
	if not alive:
		
		if free_on_hit: # Fade out and then delete the orb.
			_death_process(delta)
		
		else: # Check respawn conditions
			current_respawn_time += delta
			if current_respawn_time >= respawn_time: 
				_respawn()
	
	if is_instance_valid(visual):
		bob_time += delta*bob_speed
		bob_time = fmod(bob_time, 2*PI)
		visual.position.y = bob_dist * sin(bob_time)
		visual.rotation += rotation_speed * delta
	
		# Modulate alpha based on hit condition
		_modulate()

func _physics_process(delta: float) -> void:
	if alive:
		global_position += movement*delta

func _ready() -> void:
	var visual_node := get_node_or_null("Visual")
	if is_instance_valid(visual_node):
		visual = visual_node
	add_to_group("BladeHitable")
	
	if reset_on_death:
		SignalBus.PlayerKilled.connect(_player_death)
