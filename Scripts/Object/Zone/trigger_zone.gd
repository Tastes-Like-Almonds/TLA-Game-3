## Object used for triggering other objects' functionality. Does not do anything by itself.
class_name TriggerZone extends Area2D

signal player_entered(player : Player)
signal player_exited(player : Player)

func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func on_body_entered(body : PhysicsBody2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		if player:
			player_entered.emit(player)

func on_body_exited(body : PhysicsBody2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		if body:
			player_exited.emit(player)

func get_players_inside() -> Array[Player]:
	return []
