extends Sprite2D

@export var float_height : float = 0.0
@export var float_speed  : float = 1.0

var prog  : float = 0.0
var start : Vector2

func _process(delta: float) -> void:
	prog += delta*float_speed
	prog = wrapf(prog, 0.0, 2*PI)
	position = start + Vector2(0, float_height*sin(prog))

func _ready() -> void:
	start = position
