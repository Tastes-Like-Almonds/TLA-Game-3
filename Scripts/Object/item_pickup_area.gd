extends Area2D

signal player_hit(player : Player)

func on_sword_hit(player : Player) -> void:
	if is_instance_valid(player): player_hit.emit(player)
