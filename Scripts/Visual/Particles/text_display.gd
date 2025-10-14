## A popup display for text. Can be used for damage numbers, status effects, etc.
class_name TextDisplay extends Node2D

const DAMAGE_NUM_SIZE : int = 40

static func get_scn() -> String:
	return "res://Scenes/Visual/Particles/text_display.tscn"

static func create(pos : Vector2 = Vector2.ZERO, txt : String = "", size : int = 50, fnt : FontFile = Globals.DEFAULT_FONT) -> Label:
	#var display : TextDisplay = load(TextDisplay.get_scn()).instantiate()
	#display.text = txt
	#display.global_position = pos
	#return display
	var l := Label.new()
	l.global_position = pos
	l.text = txt
	l.add_theme_font_override("font", fnt)
	l.add_theme_font_size_override("font_size", size)
	return l

static func damage_display(parent:Node, pos:Vector2, txt : String, direction:Vector2, color:Color = Color.RED, size_scale:float = 1.0,fade_time:float = 2.0,anim_time:float=0.5) -> void:
	var label := Label.new()
	label.text = txt
	label.global_position = pos
	
	label.modulate = color
	label.scale = Vector2.ZERO
	label.add_theme_font_override("font", Globals.DEFAULT_FONT)
	label.add_theme_font_size_override("font_size", DAMAGE_NUM_SIZE)
	
	parent.add_child(label)
	
	var tree := label.get_tree()
	if tree == null: return
	var tween := tree.create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(
		label,
		"global_position",
		pos+direction*80,
		anim_time
	)
	tween.tween_property(
		label,
		"scale",
		Vector2(size_scale,size_scale),
		anim_time
	)
	
	var fade_tween := tree.create_tween()
	var invis_color := color
	invis_color.a = 0
	fade_tween.tween_property(
		label,
		"modulate",
		invis_color,
		fade_time
		
	)
	tween.play()
	tween.tween_callback(fade_tween.play)
	

static func tween_pos(l : Label, target : Vector2, time : float = 1) -> void:
	var tween := l.get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		l,
		"global_position",
		target,
		time
	)
	tween.play()
