extends Node

var player : Player = null
var player_body : PlayerBody = null
var player_sprite : AnimatedSprite2D = null
var body_particles : GPUParticles2D = null

var body_particles_offset : Vector2 = Vector2.ZERO

var current_player_animation : StringName

func _ready() -> void:
	var parent : Node = get_parent()
	if parent is Player:
		if not parent.is_node_ready():
			await parent.ready
		player = get_parent()
		player_body = player.get_player_body()
		body_particles = player_body.get_node_or_null("GroundParticles")
		player_sprite = player_body.get_sprite()
		if body_particles:
			body_particles_offset = body_particles.position
	else:
		push_warning("Player animator child of non-parent node!")

func _process(_delta: float) -> void:
	if body_particles:
		body_particles.position = body_particles_offset*player.get_gravity_direction()
		body_particles.emitting = player_body.is_on_floor()
		body_particles.amount_ratio = max(0, abs(player_body.velocity.x) / player.get_sword_speed())

func _physics_process(_delta: float) -> void:
	if player_body.is_on_floor():
		current_player_animation = "idle"
	else:
		current_player_animation = "airborne"
	
	if not (player_sprite.animation == current_player_animation):
		player_sprite.play(current_player_animation)
