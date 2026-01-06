extends Area2D

func transition() -> void:
	LevelLoader.load_level()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		if is_instance_valid(player): transition()
