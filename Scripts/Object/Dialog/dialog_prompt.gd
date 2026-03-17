extends Node2D

@export var dialog:DialogTree = DialogTree.new()

var hovered:bool = false
var in_dialog:bool = false

func _trigger() -> void:
	DialogLoader.play_dialog_tree(dialog)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		if player:
			$Prompt.open()
			hovered = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		if player:
			$Prompt.close()
			hovered = false

func _input(event: InputEvent) -> void:
	if event.is_action("next_dialog") and (hovered) and (not in_dialog) and event.is_pressed():
		_trigger()

func _ready() -> void:
	$Prompt.close()
	SignalBus.DialogStart.connect(func() -> void: in_dialog = true)
	SignalBus.DialogEnd.connect(func() -> void: in_dialog = false)
