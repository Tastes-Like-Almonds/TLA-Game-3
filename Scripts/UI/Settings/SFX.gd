extends HSlider

func changed() -> void:
	var idx := AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_linear(idx, value)

func _ready() -> void:
	PersistentData.DataLoaded.connect(
		func(key:String, val:Variant) -> void:
			if key == "sfx_volume_perc":
				value = val
				changed()
	)
	drag_ended.connect(
		func(vc:bool) -> void:
			if vc:
				GameSettings.set_setting("sfx_volume_perc", value)
				changed()
	)
	value = GameSettings.get_setting("sfx_volume_perc")
	changed()
