extends Area2D

## The node which the player will teleport to. If not set, nothing happens.
@export var target_node : Node2D

## If true, cancel the player's velocity upon teleport.
@export var cancel_velocity : bool = true

## If true, the player will teleport to their respawn point instead of target_node.
@export var teleport_to_spawn : bool = true

## If true, the player's property modifiers will be reset as they would be if they respawned
## upon a teleport.
@export var property_respawn_reset : bool = true

## If >0, will deal damage to the player upon teleporting equal to this amount.
@export var damage: float = 0

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		
		if not is_instance_valid(player): return
	
		if damage > 0:
			player.deal_damage(damage)
			if player.dead:
				return # Respawn normally if the player dies.
		
		if teleport_to_spawn:
			player.teleport_to(player.respawn_pos*player.get_size_scale())
		else:
			if not is_instance_valid(target_node): return
			player.teleport_to(target_node.global_position)
		
		if property_respawn_reset:
			player.clear_respawn_modifiers()
		
		if cancel_velocity:
			player.set_velocity(Vector2.ZERO)
