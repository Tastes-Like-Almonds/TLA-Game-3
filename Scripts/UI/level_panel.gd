## A UI display for LevelData.
class_name LevelPanel extends FoldableContainer

# NOTE If a level is unsuccessfully loaded, the game might be in a softlocked state, depending on
# how it's implemented later.

## Called when the play button is pressed on this level. Emitted before the level is loaded.
signal LevelPlayed(data : LevelData)

@onready var desc_label : Label = $MarginContainer/VBoxContainer/HBoxContainer/Description
@onready var diff_label : Label = $MarginContainer/VBoxContainer/HBoxContainer/Difficulty
@onready var play_button : Button = $MarginContainer/VBoxContainer/Play

var level_data : LevelData

## Update the panel's display and function based on the LevelData provided.
func set_level_data(data : LevelData) -> void:
	title = data.title
	desc_label.text = data.description
	diff_label.text = str(data.difficulty) + " (" + Level.Difficulty.find_key(data.difficulty).to_pascal_case() + ")"
	level_data = data

## Load the level from this node's level_data property.
func _load_level() -> void:
	print("Level '" + title + "' loading...")
	
	if Globals.has_main():
		LevelPlayed.emit(level_data)
		LevelLoader.load_level(level_data.level_path, Globals.get_level_load_node())

func _ready() -> void:
	play_button.pressed.connect(_load_level)
