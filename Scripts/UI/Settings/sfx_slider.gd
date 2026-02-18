extends HSlider

func changed() -> void:
	var idx := AudioServer.get_bus_index("SFX")
	print(value)
	AudioServer.set_bus_volume_linear(idx, value)

func _ready() -> void:
	PersistentData.DataLoaded.connect(
		func(key:String, val:Variant) -> void:
			if key == "sfx_volume_perc":
				value = val
				changed()
	)
	drag_ended.connect(
		func(toggle:bool) -> void:
			GameSettings.set_setting("sfx_volume_perc", toggle)
			changed()
	)
	value = GameSettings.get_setting("sfx_volume_perc")
	changed()
