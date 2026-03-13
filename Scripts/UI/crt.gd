extends Control

func _ready() -> void:
	GameSettings.SettingChanged.connect(
		func(key:String, val:Variant) -> void:
			if key == "disable_crt": visible = !val
	)
	visible = !GameSettings.get_setting("disable_crt")
