class_name ScreenShakeTextEffect extends RichTextEffect

var bbcode := "screenshake"

func _process_custom_fx(_char_fx: CharFXTransform) -> bool:
	# NOTE: Handling done in dialog.gd.
	return true
