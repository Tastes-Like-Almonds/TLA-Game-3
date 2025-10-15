## UI For displaying game data such as health and weapons.
class_name LevelUI extends CanvasLayer

var player : Player

## Returns true if the UI as a player associated.
func has_player() -> bool:
	return is_instance_valid(player)

## Registers a player to the ui.
func register_player(p : Player) -> void:
	player = p
