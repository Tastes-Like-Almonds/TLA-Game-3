extends CheckBox

func _set_fullscreen(toggle:bool) -> void:
	if toggle:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func _ready() -> void:
	PersistentData.DataLoaded.connect(
		func(key:String, val:Variant) -> void:
			if key == "fullscreen":
				button_pressed = val
				_set_fullscreen(val)
	)
	toggled.connect(
		func(toggle:bool) -> void:
			GameSettings.set_setting("fullscreen", toggle)
			_set_fullscreen(toggle)
	)
	var fs : Variant = GameSettings.get_setting("fullscreen")
	button_pressed = fs
	_set_fullscreen(fs)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		button_pressed = !button_pressed
		_set_fullscreen(button_pressed)
