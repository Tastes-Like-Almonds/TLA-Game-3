extends Node

## Toggle the paused state of the level.
func _toggle_pause() -> void:
	var paused := get_tree().paused
	
	get_tree().paused = !paused
	SignalBus.PauseToggled.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if !event.pressed: return
		if event.is_action("pause"):
			_toggle_pause()

func _ready() -> void:
	SignalBus.RequestUnpause.connect(func() -> void:
		if (get_tree().paused):
			_toggle_pause()
	)
