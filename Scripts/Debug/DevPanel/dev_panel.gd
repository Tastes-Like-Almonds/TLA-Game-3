## A tool for triggering events/changing data within the game for the sake of quicker development.
## Functionality is handled in each panel "Category".
class_name DevPanel extends Control

func open() -> void:
	show()

func close() -> void:
	hide()

func toggle_visibility() -> void:
	visible = not visible

func get_all_players() -> Array[Player]:
	var players : Array[Player] = []
	var tree := get_tree()
	if not tree: return []
	for player in tree.get_nodes_in_group("Player"):
		if player is Player:
			players.append(player)
	return players
