extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		if not is_instance_valid(player): return
		player.kill()
