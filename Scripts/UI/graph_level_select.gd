extends Control

## The worlds to be loaded into the selector.
@export var worlds : Array[WorldData]

@onready var world_display : WorldDisplay = %WorldDisplay
@onready var graph_select  : GraphSelect  = %GraphSelect
@onready var level_display : LevelDisplay = %LevelDisplay

var current_world : WorldData = null

func _reload() -> void:
	world_display.clear_worlds()
	for world in worlds:
		world_display.add_world(world) # TODO Handle locking for unreached worlds

func _load_world(world:WorldData) -> void:
	current_world = world
	graph_select.load_world(world)

func _level_selected(level_node : LevelNodeData) -> void:
	level_display.load_level(level_node)

func _play_level(level_data : LevelNodeData) -> void:
	if Globals.has_main():
		
		if not level_data.level_data.level_path:
			push_warning("No level data found for level SID " + level_data.sid)
			return
		
		var config := LevelConfig.new()
		config.world = current_world.name
		config.sid = level_data.sid
		
		LevelLoader.load_level(
			level_data.level_data.level_path, 
			Globals.get_level_load_node(),
			config
		)
	else:
		print_debug("Globals.main not present; cannot load level.")
	
	queue_free()

func _ready() -> void:
	world_display.world_changed.connect(_load_world)
	graph_select.level_selected.connect(_level_selected)
	level_display.play_level_pressed.connect(_play_level)
	_reload()
	
	Music.stop_track(Music.TrackLayer.MUSIC)
	Music.stop_track(Music.TrackLayer.AMBIENT)
