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

var line_effects : Dictionary[int, Array]

# Not using SFX for sound effects as it unnecessarily creates a bunch of nodes
var sound : AudioStreamPlayer

#region Helper
func parsed_index_to_raw_index(rich_text_label: RichTextLabel, parsed_index: int) -> int:
	var raw_text := rich_text_label.text
	var visible_count := 0
	var inside_tag := false

	for i in raw_text.length():
		var c := raw_text[i]

		if c == "[":
			inside_tag = true
		elif c == "]" and inside_tag:
			inside_tag = false
			continue

		if not inside_tag:
			if visible_count == parsed_index:
				return i
			visible_count += 1

	return -1 # Not found
#endregion

func open() -> void:
	show()

func close() -> void:
	hide()

func _tree_ended() -> void:
	hide()
	displaying_characters = false
	current_tree = null
	# TODO Add choice system (If ever needed)

## Handles user input when "next_dialog" triggers. Either skips or proceeds to the next dialog.
func _next_dialog() -> void:
	if (!current_tree): return
	if char_idx < current_tree.lines[line_idx].text.length():
		char_idx = current_tree.lines[line_idx].text.length()-1
		_next_char()
	else:
		_next_line()

func process_line_effects(effects:Array) -> void:
	for effect:Dictionary in effects:
		if effect["type"] == "playsound":
			var playsound : SoundData = SoundData.new(effect["path"])
			Sfx.play_sound(playsound)
		elif effect["type"] == "screenshake":
			GameCamera.set_current_camera_shake(get_viewport(), float(effect["num"]))

func _get_line_effects(line:String) -> Dictionary[int, Array]:
	var dict : Dictionary[int, Array] = {}
	
	# NOTE: This whole system is horribly unoptimized, but that's fine since there's only one
	# often-not-active instance of this node.... Also I'm lazy
	
	# Find all "playsound" entries
	var regex : RegEx = RegEx.new()
	regex.compile('(?mU)\\[playsound .*sound="(?<path>.*)"\\]')
	var matches : Array[RegExMatch] = regex.search_all(line)
	
	for m in matches:
		var start := m.get_start()
		
		if start not in dict:
			dict[start] = []
		
		dict[start].append({
			"type": "playsound",
			"path": m.get_string("path")
		})
	
	regex.compile('(?mU)\\[screenshake (?<num>[\\d.]*)]')
	matches = regex.search_all(line)
	
	for m in matches:
		var start := m.get_start()
		
		if start not in dict:
			dict[start] = []
		
		dict[start].append({
			"type": "screenshake",
			"num": m.get_string("num")
		})
	
	return dict
	

## Starts displaying the next line of dialog.
func _next_line() -> void:
	
	if (!current_tree): return
	
	line_idx += 1
	char_idx = 0
	
	if line_idx >= current_tree.lines.size():
		_tree_ended()
		return
	
	var line : DialogLine = current_tree.lines[line_idx]
	line_effects = _get_line_effects(line.text)
	
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
	var last_pos:int = parsed_index_to_raw_index(text_node, char_idx)
	
	text_node.visible_characters = char_idx+1 # Index starts at 0
	char_idx += 1

	var parsed : String = text_node.get_parsed_text()
	if char_idx >= parsed.length():
		_line_ended()
		return
	
	# Skip whitespace and don't play sound for it.
	target_delay = DialogLoader.get_char_delay(line, parsed[char_idx-1])
	if parsed[char_idx-1] != " ":
		if line.sound_type == DialogLine.SoundType.PER_CHARACTER:
			if sound:
				sound.play()
	
	var new_pos:int = parsed_index_to_raw_index(text_node, char_idx)
	if new_pos-last_pos > 1:
		for i in range(last_pos,new_pos+1):
			if i in line_effects:
				process_line_effects(line_effects[i])

## Plays a dialog tree, overriding any currently playing one.
func play_dialog_tree(dialog_tree : DialogTree) -> void:
	speaker_name = "???" # Set default
	current_tree = dialog_tree
	line_idx = -1
	open()
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
