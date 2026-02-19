extends Node2D

func _ready() -> void:
	$Fog.global_position = Vector2.ZERO
	$Fog/Parallax2D/Sprite2D.global_position = Vector2.ZERO
