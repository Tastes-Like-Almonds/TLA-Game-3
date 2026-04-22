extends DialogPrompt

func _trigger() -> void:
	Globals.main.transiton_overlay_player.play("fade_to_black")
	Globals.main.transiton_overlay_player.animation_finished.connect(func(_x:Variant) -> void:
		
		SignalBus.SelectorLoaded.connect(func() -> void:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
			Globals.main.transiton_overlay_player.play("fade_from_black")
		
		,CONNECT_ONE_SHOT)
		LevelLoader.load_selector()
		
	,CONNECT_ONE_SHOT)
