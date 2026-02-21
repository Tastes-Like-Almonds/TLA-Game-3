extends Node

## Queue of dialog trees to be run sequentially; technically an array, but used as a queue (FIFO).
var queue: Array[DialogTree]

func _cycle_queue() -> void:
	queue.pop_at(0)
	
	if queue.size() > 0:
		play_dialog_tree(queue[0])

func get_char_delay(tree:DialogTree, line_idx:int, char_idx:int) -> float:
	return DialogTree.DEFAULT_SPEED # TODO

## Play a dialog tree. This overrides a
func play_dialog_tree(dialog_tree:DialogTree) -> void: 
	var dialog_node : Control = Globals.main.get_node("%Dialog")
	
	if dialog_node:
		dialog_node.play_dialog_tree(dialog_tree)
	
	_cycle_queue()

## Queues a DialogTree to play after the current one(s) are finished. Plays immediately if the queue
## is empty.
func queue_dialog_tree(dialog_tree:DialogTree) -> void:
	queue.append(dialog_tree)

## Clears all dialog in the queue.
func clear_queue() -> void:
	queue.clear()
