extends Node

func get_all_descendants(node: Node) -> Array[Node]:
	var descendants: Array[Node] = []
	for child in node.get_children():
		descendants.append(child)
		descendants.append_array(get_all_descendants(child))
	return descendants

func get_closest_player(origin:Vector2, distance_limit : float = 10000000) -> Player:
	for node in get_tree().get_nodes_in_group("Player"):
		if node is not Player : continue
		if origin.distance_to(node.get_player_position()) <= distance_limit:
			return node
	return null
