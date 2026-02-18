extends CheckBox

func _set_fullscreen(toggle:bool) -> void:
	if toggle:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		print(" ITS WINDOW NOW")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _ready() -> void:
	PersistentData.DataLoaded.connect(
		func(key:String, val:Variant) -> void:
			if key == "fullscreen":
				toggle_mode = val
				_set_fullscreen(val)
	)
	toggled.connect(
		func(toggle:bool) -> void:
			GameSettings.set_setting("fullscreen", toggle)
			_set_fullscreen(toggle)
	)
