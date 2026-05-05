class_name DialogPrompt extends Node2D

@export var dialog:DialogTree = DialogTree.new()

var hovered:bool = false
var in_dialog:bool = false

func _trigger() -> void:
	DialogLoader.play_dialog_tree(dialog)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		if player:
			SignalBus.DialogPromptEntered.emit(self)
			$Prompt.open()
			hovered = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		if player:
			$Prompt.close()
			SignalBus.DialogPromptEntered.emit(null)
			hovered = false

func _input(event: InputEvent) -> void:
	if event.is_action("next_dialog") and (hovered) and (not in_dialog) and event.is_pressed():
		_trigger()

func _ready() -> void:
	$Prompt.close()
	SignalBus.DialogStart.connect(func() -> void: in_dialog = true)
	SignalBus.DialogEnd.connect(func() -> void: in_dialog = false)
	SignalBus.DialogPromptEntered.connect(func(prompt:DialogPrompt) -> void:
		
		# Prompt deselected; check if current prompt is a valid choice.
		if prompt == null:
			for body : Node2D in $Area2D.get_overlapping_bodies():
				if body is PlayerBody:
					SignalBus.DialogPromptEntered.emit(self)
					$Prompt.open()
					hovered = true
		
		# Other prompt was chosen; disable self.
		elif prompt != self:
			hovered = false
			$Prompt.close()
	)
