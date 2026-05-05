extends Sprite2D

@onready var animator:AnimationPlayer = $Animator

func open() -> void:
	animator.play("show")

func close() -> void:
	animator.play("hide")
