extends Node

var main : Main

## Returns true if main is present, false otherwise.
func has_main() -> bool:
	return is_instance_valid(main)
