extends BoostOrb

@export var force : float = 1500

var start_pos : Vector2

var velocity : Vector2 = Vector2.ZERO
var drag : float = 0.7

var pull_speed : float = 100

func hit_effect(player : Player) -> void:
	super(player)
	var vel := player.get_player_sword().get_last_sword_velocity()
	velocity = player.get_blade_damage_perc()*player.get_knockback()*vel.normalized()*2

func _modulate() -> void:
	return

func _physics_process(delta: float) -> void:
	velocity += position.direction_to(start_pos)*pull_speed
	
	if Helper.line_passes_point_horizontally_or_vertically(global_position, global_position+velocity*delta, start_pos):
		global_position = start_pos
		velocity = Vector2.ZERO
	else:
		global_position += velocity*delta
		velocity = velocity.lerp(Vector2.ZERO, 1-pow(0.2, delta))

func _ready() -> void:
	super()
	start_pos = global_position
