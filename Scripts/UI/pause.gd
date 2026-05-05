extends Control

func _toggle() -> void:
	visible = get_tree().paused
	Music.muffle_music = get_tree().paused

func _ready() -> void:
	SignalBus.PauseToggled.connect(_toggle)
	$MarginContainer/version.text = ProjectSettings.get_setting("application/config/version")
	_toggle()
	
	if OS.has_feature("web"):
		$MarginContainer/CenterContainer/VBoxContainer/ExitGame.hide()
		$MarginContainer/version.text += " (WEB)"
	if OS.has_feature("debug"):
		$MarginContainer/version.text += " (DEBUG)"

func _on_continue_pressed() -> void:
	SignalBus.RequestUnpause.emit()

func _on_exit_level_pressed() -> void:
	Helper.fade_to_selector()

func _on_settings_pressed() -> void:
	SignalBus.OpenSettings.emit()

func _on_exit_game_pressed() -> void:
	Helper.close_game()
