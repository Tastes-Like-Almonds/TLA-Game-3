extends Control

@onready var scn_world_panel : PackedScene = preload("res://Scenes/UI/world_level_panel.tscn")
@onready var scn_level_panel : PackedScene = preload("res://Scenes/UI/level_panel.tscn")

@onready var vbox : VBoxContainer = $PanelContainer/HSplitContainer/Select/MarginContainer/VBoxContainer

var sample_data : Dictionary = {
	"worlds": {
		"Word 1 - The Gutter": {
			"levels": [
				"res://Data/Level/test_level_data.tres",
				"res://Data/Level/test_level_data.tres",
				"res://Data/Level/test_level_data.tres"
			]
		},
	}
	
}

func _on_level_played(_level_data : LevelData) -> void:
	queue_free() # Close the menu when a level is played.

## Loads a dictionary of world data into the scene.
func load_worlds_from_data(data : Dictionary) -> void:
	if not data["worlds"]: return
	
	for key : String in data["worlds"]:
		
		var world : WorldPanel = scn_world_panel.instantiate()
		world.name = key # No functional use, but may make it easier to access via the editor
		
		vbox.add_child(world) # The world's VBox must be readied before data is added
		
		if "levels" in data["worlds"][key]:
			world.load_level_paths_array(data["worlds"][key]["levels"])
			world.LevelPlayed.connect(_on_level_played)
		else: # Don't error, as this might be intended
			push_warning("No levels found for world '" + key + "'!")

func _ready() -> void: # TODO Remove when testing done
	load_worlds_from_data(sample_data)
