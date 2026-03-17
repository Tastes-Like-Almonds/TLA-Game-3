extends HSlider

@export var label : Label

func _changed(val : float) -> void:
	assert(is_instance_valid(label), "Label not set for mouse sensitivity slider!")
	label.text = "%.2f" % val + "x"

func _ready() -> void:
	PersistentData.DataLoaded.connect(
		func(key:String, val:Variant) -> void:
			if key == "mouse_sens":
				value = val
				_changed(val)
	)
	drag_ended.connect(
		func(vc:bool) -> void:
			if vc:
				GameSettings.set_setting("mouse_sens", value)
	)
	value = GameSettings.get_setting("mouse_sens")

func _on_value_changed(_value: float) -> void:
	_changed(value)
