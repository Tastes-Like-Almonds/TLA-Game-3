extends Control

func _toggle() -> void:
	visible = get_tree().paused

func _ready() -> void:
	SignalBus.PauseToggled.connect(_toggle)
	$MarginContainer/version.text = ProjectSettings.get_setting("application/config/version")
	_toggle()

func _on_continue_pressed() -> void:
	SignalBus.RequestUnpause.emit()

func _on_exit_level_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	SignalBus.OpenSettings.emit()
