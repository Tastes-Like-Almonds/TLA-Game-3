extends Control

@onready var text_node : RichTextLabel = $MarginContainer/TextDisplay/VBoxContainer/DialogPanel/MarginContainer/HBoxContainer/Text
@onready var name_node : RichTextLabel = $MarginContainer/TextDisplay/VBoxContainer/NamePanel/Name
@onready var icon_node : TextureRect = $MarginContainer/TextDisplay/VBoxContainer/DialogPanel/MarginContainer/HBoxContainer/TextureRect

var current_delay : float = 0.0
var target_delay : float = 0.0

var current_tree : DialogTree
var line_idx : int = 0
var char_idx : int = 0

var speaker_name : String = "???"

var displaying_characters: bool = false

# Not using SFX for sound effects as it unnecessarily creates a bunch of nodes
var sound : AudioStreamPlayer

func _tree_ended() -> void:
	print_debug("END OF TREE")
	displaying_characters = false
	current_tree = null
	# TODO Add choice system + Close dialog when done

## Handles user input when "next_dialog" triggers. Either skips or proceeds to the next dialog.
func _next_dialog() -> void:
	if (!current_tree): return
	if char_idx < current_tree.lines[line_idx].text.length():
		char_idx = current_tree.lines[line_idx].text.length()-1
		_next_char()
	else:
		_next_line()

## Starts displaying the next line of dialog.
func _next_line() -> void:
	
	if (!current_tree): return
	
	line_idx += 1
	char_idx = 0
	
	if line_idx >= current_tree.lines.size():
		_tree_ended()
		return
	
	var line : DialogLine = current_tree.lines[line_idx]
	
	if sound:
		sound.queue_free()
	
	# Load sound
	if line.sound and line.sound.sound_string:
		sound = AudioStreamPlayer.new()
		sound.stream = load(line.sound.sound_string)
		sound.volume_linear = line.sound.volume_linear
		sound.pitch_scale = line.sound.pitch_scale
		sound.bus = line.sound.bus
		add_child(sound)
	
	if line.sound_type == DialogLine.SoundType.PER_LINE:
		sound.play()
	
	if line.name:
		speaker_name = line.name
	
	name_node.text = speaker_name
	
	text_node.text = line.text
	displaying_characters = true
	_next_char()

## Ran when the current line runs out of character to display.
func _line_ended() -> void:
	displaying_characters = false
	if current_tree.lines[line_idx].auto:
		_next_line()

## Displays the next character, calling _line_ended() if it reaches the end.
func _next_char() -> void:
	
	if (!current_tree): return
	
	var line : DialogLine = current_tree.lines[line_idx]
	
	text_node.visible_characters = char_idx+1 # Index starts at 0
	char_idx += 1

	if char_idx >= text_node.get_parsed_text().length():
		_line_ended()
		return
	
	# Skip whitespace and don't play sound for it.
	target_delay = DialogLoader.get_char_delay(current_tree, line_idx, char_idx)
	if text_node.get_parsed_text()[char_idx-1] != " ":
		if line.sound_type == DialogLine.SoundType.PER_CHARACTER:
			if sound:
				sound.play()

## Plays a dialog tree, overriding any currently playing one.
func play_dialog_tree(dialog_tree : DialogTree) -> void:
	speaker_name = "???" # Set default
	current_tree = dialog_tree
	line_idx = -1
	_next_line()

func _process(delta: float) -> void:
	if current_tree and displaying_characters:
		current_delay += delta
		if current_delay > target_delay:
			_next_char()
			current_delay = 0

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.is_action("next_dialog"):
				_next_dialog()

# Testing only
func _ready() -> void:
	play_dialog_tree(load("res://Scripts/Resource/Weapon/mydialog.tres"))
