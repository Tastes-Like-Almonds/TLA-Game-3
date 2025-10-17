extends Area2D

## The node which the player will teleport to. If not set, nothing happens.
@export var target_node : Node2D

## If true, cancel the player's velocity upon teleport.
@export var cancel_velocity : bool = true

## If true, the player will teleport to their respawn point instead of target_node.
@export var teleport_to_spawn : bool = true

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		
		if not is_instance_valid(player): return
		
		if teleport_to_spawn:
			player.teleport_to(player.respawn_pos)
		else:
			if not is_instance_valid(target_node): return
			player.teleport_to(target_node.global_position)
		
		if cancel_velocity:
			player.set_velocity(Vector2.ZERO)
		
