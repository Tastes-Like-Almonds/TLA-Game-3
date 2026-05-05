extends HSlider

func _ready() -> void:
	PersistentData.DataLoaded.connect(
		func(key:String, val:Variant) -> void:
			if key == "brightness":
				value = val
	)
	drag_ended.connect(
		func(vc:bool) -> void:
			if vc:
				GameSettings.set_setting("brightness", value)
	)
	var brightness : Variant = GameSettings.get_setting("brightness")
	if brightness:
		value = brightness
