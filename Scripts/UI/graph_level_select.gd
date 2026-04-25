class_name GraphLevelSelect extends Control

## The worlds to be loaded into the selector.
@export var worlds : Array[WorldData]

@onready var world_display : WorldDisplay = %WorldDisplay
@onready var graph_select  : GraphSelect  = %GraphSelect
@onready var level_display : LevelDisplay = %LevelDisplay

@onready var exit_button : Button = $Exit

@export var start_sound    : SoundData    = SoundData.new("res://Assets/Sound/SFX/UI/Level Start 1.wav", 0.45, 1.0, "SFX")

var loading_level : bool      = false
var current_world : WorldData = null

func _reload() -> void:
	world_display.clear_worlds()
	for world in worlds:
		world_display.add_world(world) # TODO Handle locking for unreached worlds

func _load_world(world:WorldData) -> void:
	if loading_level: return
	current_world = world
	graph_select.load_world(world)

func _level_selected(level_node : LevelNodeData) -> void:
	if loading_level: return
	level_display.load_level(level_node, current_world)

func _play_level(level_data : LevelNodeData) -> void:
	if loading_level: return
	if Globals.has_main():
		loading_level = true
		
		if not level_data.level_data.level_path:
			push_warning("No level data found for level SID " + level_data.sid)
			loading_level = false
			return
		
		var config := LevelConfig.new()
		config.world = current_world.name
		config.sid = level_data.sid
		
		Sfx.play_sound(start_sound)
		
		Globals.main.transiton_overlay_player.play("fade_to_black")
		Globals.main.transiton_overlay_player.animation_finished.connect(func(_x:Variant) -> void:
			SignalBus.LevelLoaded.connect(func() -> void:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				Globals.main.transiton_overlay_player.play("fade_from_black")
				queue_free()
			,CONNECT_ONE_SHOT)
			
			LevelLoader.load_level(
			level_data.level_data.level_path, 
			Globals.get_level_load_node(),
			config
		)
			
		,CONNECT_ONE_SHOT)
	else:
		print_debug("Globals.main not present; cannot load level.")

func _exit() -> void:
	Globals.main.transiton_overlay_player.play("fade_to_black")
	
	Globals.main.transiton_overlay_player.animation_finished.connect(func(_x:Variant) -> void:
		
		SignalBus.LevelLoaded.connect(func() -> void:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Globals.main.transiton_overlay_player.play("fade_from_black")
			queue_free()
		
		,CONNECT_ONE_SHOT)
		LevelLoader.load_level("res://Scenes/Level/menu.tscn", Globals.get_level_load_node())
		
	,CONNECT_ONE_SHOT)

func _ready() -> void:
	world_display.world_changed.connect(_load_world)
	graph_select.level_selected.connect(_level_selected)
	graph_select.level_played.connect(_play_level)
	level_display.play_level_pressed.connect(_play_level)
	exit_button.pressed.connect(_exit)

	SignalBus.RequestUnpause.emit()
	_reload()
	
	Music.stop_track(Music.TrackLayer.MUSIC)
	Music.stop_track(Music.TrackLayer.AMBIENT)
