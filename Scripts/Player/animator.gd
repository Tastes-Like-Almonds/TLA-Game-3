extends Node

var player : Player = null
var player_body : PlayerBody = null
var player_sprite : AnimatedSprite2D = null
var body_particles : GPUParticles2D = null

var body_particles_offset : Vector2 = Vector2.ZERO

var current_player_animation : StringName

var spawning: bool = false

func finish_spawn() -> void:
	spawning = false
	player_sprite.animation_finished.disconnect(finish_spawn)

func play_spawn() -> void:
	spawning = true
	player_sprite.frame = 0
	player_sprite.play("spawn")
	player_sprite.animation_finished.connect(finish_spawn)

func _ready() -> void:
	var parent : Node = get_parent()
	
	if parent is not Player:
		push_warning("Player animator child of non-parent node!")
	
	if not parent.is_node_ready():
		await parent.ready
	
	spawning = true
	
	player = get_parent()
	player_body = player.get_player_body()
	body_particles = player_body.get_node_or_null("GroundParticles")
	player_sprite = player_body.get_sprite()
	
	if body_particles:
		body_particles_offset = body_particles.position
	
	play_spawn()
	
func _process(_delta: float) -> void:
	if body_particles:
		var size_scale : float = player.get_size_scale()
		body_particles.process_material.scale = Vector2(size_scale, size_scale)
		body_particles.position = body_particles_offset*player.get_gravity_direction()
		body_particles.emitting = player_body.is_on_floor()
		body_particles.amount_ratio = max(0, abs(player_body.velocity.x) / player.get_sword_speed())

func _physics_process(_delta: float) -> void:
	
	if spawning:
		return
	
	if player_body.is_on_floor():
		current_player_animation = "idle"
	else:
		current_player_animation = "airborne"
	
	# Don't play the current animation if it's already playing.
	if not (player_sprite.animation == current_player_animation):
		player_sprite.play(current_player_animation)
