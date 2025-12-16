extends Sprite2D
class_name DebugDot

var kill_time : float = 0.0
var id : String

func _ready() -> void:
	$Label.text = str(global_position)

func _process(delta: float) -> void:
	kill_time -= delta
	if kill_time <= 0:
		queue_free()
