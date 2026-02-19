extends CheckBox

func _set_fullscreen(toggle:bool) -> void:
	if toggle:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

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
