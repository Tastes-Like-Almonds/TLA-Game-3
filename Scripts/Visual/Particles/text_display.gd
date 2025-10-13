## A popup display for text. Can be used for damage numbers, status effects, etc.
class_name TextDisplay extends Node2D

@onready var label : Label = $Label

@export var font : FontFile = null:
	set(new):
		if new == null: return
		if label:
			label.add_theme_font_override("font", new)
		font = new

@export var text := "":
	set(new):
		print("CALLED WITH " + new)
		if new == null: return
		print("NOT NULL")
		print(label)
		if is_instance_valid(label):
			print("SETTOMG")
			label.text = str(new)
		text = new

@export var scale_speed : float = 2

## Lerp value per second toward target_pos
@export var move_speed : float = 0.8

var target_scale : float = 1.0

## The target global position of the display. Will lerp toward the target space by
## move_speed per second.
var target_pos : Vector2 = Vector2.ZERO

static func get_scn() -> String:
	return "res://Scenes/Visual/Particles/text_display.tscn"

static func create(pos : Vector2 = Vector2.ZERO, txt : String = "") -> TextDisplay:
	var display : TextDisplay = load(TextDisplay.get_scn()).instantiate()
	display.text = txt
	display.global_position = pos
	return display

## Sets the scale to (amt, amt)
func set_scale_to_float(amt : float) -> void:
	scale = Vector2(amt,amt)

## Sets the scale to (amt, amt), but does so at a speed of self.scale_speed
func set_scale_target_to_float(amt : float) -> void:
	target_scale = amt

func _process(delta: float) -> void:
	# Update scale; does not support different x and y for the sake of simplicity.
	scale.x = move_toward(scale.x, target_scale, scale_speed*delta)
	scale.x = move_toward(scale.y, target_scale, scale_speed*delta)
	
	# Lerp toward target position.
	global_position = global_position.lerp(target_pos, pow(move_speed, delta))

func _ready() -> void:
	label = get_node("Label")
	if font == null:
		font = Globals.DEFAULT_FONT
	if text == "":
		font = Globals.DEFAULT_FONT
	label.text = str(text)
	label.add_theme_font_override("font", font)
