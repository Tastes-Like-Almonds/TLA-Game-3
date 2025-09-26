extends Node

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_F1:
					if Input.mouse_mode == Input.MOUSE_MODE_CONFINED:
						Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
					else:
						Input.mouse_mode = Input.MOUSE_MODE_CONFINED
				KEY_F2:
					var panel = Globals.main.get_dev_panel()
					if is_instance_valid(panel):
						panel.toggle_visibility()
