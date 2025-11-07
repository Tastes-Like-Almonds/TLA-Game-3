extends LevelMap

func get_nodes() -> Array[MapNode]:
	var arr : Array[MapNode] = []
	for child in Helper.get_all_descendants(self):
		if child is MapNode:
			arr.append(child)
	return arr
