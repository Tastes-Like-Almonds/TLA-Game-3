extends Node

var DEFAULT_FONT : FontFile = load("res://Resource/Font/Micro5-Regular.ttf")

var main : Main:
	set(node):
		main=node
		SignalBus.MainLoaded.emit()

## Returns true if main is present, false otherwise.
func has_main() -> bool:
	return is_instance_valid(main)
