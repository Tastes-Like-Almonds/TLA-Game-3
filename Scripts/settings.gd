## Manages the UI portion of the settings system. See game_settings.gd for the actual settings
## implementation.
extends Control

@onready var apply : Button = $MarginContainer/HBoxContainer/VBoxContainer/Apply

func _ready() -> void:
	apply.pressed.connect(func() -> void: hide())
	SignalBus.OpenSettings.connect(func() -> void: show())
	SignalBus.PauseToggled.connect(
		func() -> void: 
			if get_tree().paused == false:
				visible = false
	)
