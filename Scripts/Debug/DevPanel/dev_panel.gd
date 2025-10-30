## A tool for triggering events/changing data within the game for the sake of quicker development.
## Functionality is handled in each panel "Category".
class_name DevPanel extends Control

# Open and close functions made in case additional functionalty is needed

func open() -> void:
	show()

func close() -> void:
	hide()

func toggle_visibility() -> void:
	visible = not visible

## Get all players in the tree. A node is considered a player if it both extends Player and
## is in the "Player" group.
func get_all_players() -> Array[Player]:
	var players : Array[Player] = []
	
	# Without this line, error triggers upon game closing
	if tree_exiting: return players
	var tree := get_tree()
	
	for player in tree.get_nodes_in_group("Player"):
		if player is Player:
			players.append(player)
	return players
