class_name PauseManager extends Node

func _update_mouse() -> void:
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		if !OS.get_cmdline_args().has("--no-grab"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## Toggle the paused state of the level.
func _toggle_pause() -> void:
	var paused := get_tree().paused
	
	get_tree().paused = !paused
	
	_update_mouse()
	
	SignalBus.PauseToggled.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if !event.pressed: return
		if event.is_action("pause"):
			
			# Disable the escape key on web since it has other purposes
			if OS.has_feature("web"):
				if event.keycode != Key.KEY_ESCAPE:
					_toggle_pause()
			
			# If not on web, just pause normally
			else:
				_toggle_pause()

func _ready() -> void:
	SignalBus.RequestUnpause.connect(func() -> void:
		if (get_tree().paused):
			_toggle_pause()
	)
