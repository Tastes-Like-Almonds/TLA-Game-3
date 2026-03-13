class_name PlaySoundTextEffect extends RichTextEffect

var bbcode := "playsound"
var played : Array[CharFXTransform]

func _process_custom_fx(_char_fx: CharFXTransform) -> bool:
	# NOTE: Handling done in dialog.gd. Playing a sound at a specific point requires context
	# which only exists when processing the dialog. 
	return true
