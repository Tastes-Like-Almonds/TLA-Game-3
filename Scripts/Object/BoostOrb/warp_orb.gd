extends BoostOrb
class_name WarpOrb

@onready var line : Line2D = $Visual/Line2D

## The target WarpNode. If not set, the orb will not teleport the player.
@export var dest : WarpOrb = null

## If true, a line will point to dest, should it exist.
@export var show_line : bool = true

func _ready() -> void:
	super()
	if dest and show_line:
		line.clear_points()
		line.add_point(Vector2.ZERO)
		line.add_point(to_local(dest.global_position))
		line.show()
	else:
		disabled = true

func _process(_delta: float) -> void:
	super(_delta)
	if dest == null and visual:
		visual.modulate.a = 0.3

func hit_effect(player : Player) -> void:
	super(player) 
	if is_instance_valid(dest):
		player.teleport_to(dest.global_position)
	$GPUParticles2D.emitting = true
