extends Node

## Queue of dialog trees to be run sequentially; technically an array, but used as a queue (FIFO).
var queue: Array[DialogTree]

func _cycle_queue() -> void:
	queue.pop_at(0)
	
	if queue.size() > 0:
		play_dialog_tree(queue[0])

func is_playing_dialog() -> bool:
	return queue.size() > 0

func get_char_delay(line:DialogLine, character:String) -> float:
	var speed := DialogTree.DEFAULT_SPEED
	if line.speed:
		speed = line.speed
	
	if character in DialogTree.SYMBOL_COEFS:
		speed *= DialogTree.SYMBOL_COEFS[character]
	
	return speed

## Play a dialog tree. This overrides any currently playing one.
func play_dialog_tree(dialog_tree:DialogTree) -> void: 
	var dialog_node : Control = Globals.main.get_node("%Dialog")
	
	if dialog_node:
		if (queue.size() == 0):
			SignalBus.DialogStart.emit()
		queue.insert(0, dialog_tree)
		dialog_node.play_dialog_tree(dialog_tree)

## Queues a DialogTree to play after the current one(s) are finished. Plays immediately if the queue
## is empty.
func queue_dialog_tree(dialog_tree:DialogTree) -> void:
	queue.append(dialog_tree)

## Clears all dialog in the queue.
func clear_queue() -> void:
	queue.clear()

func _ready() -> void:
	SignalBus.DialogEnd.connect(_cycle_queue)
