class_name CosmeticDialogPrompt extends DialogPrompt

signal Triggered

func _trigger() -> void:
	Triggered.emit()
