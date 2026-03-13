extends ColorRect

func _ready() -> void:
	GameSettings.SettingChanged.connect(
		func(key:String, val:Variant) -> void:
			if key == "brightness": material.set_shader_parameter("brightness", val)
	)
	material.set_shader_parameter("brightness", GameSettings.get_setting("brightness"))
