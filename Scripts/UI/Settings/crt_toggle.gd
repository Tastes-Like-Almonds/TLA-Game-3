extends CheckBox

func _ready() -> void:
	PersistentData.DataLoaded.connect(
		func(key:String, val:Variant) -> void:
			if key == "disable_crt":
				button_pressed = val
	)
	toggled.connect(
		func(toggle:bool) -> void:
			GameSettings.set_setting("disable_crt", toggle)
	)
	button_pressed = GameSettings.get_setting("disable_crt")
