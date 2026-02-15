## A base class for levels. If anything looks abnormal, it's because this was designed to be more
## adaptable to multiplayer should we do so later in development.
@abstract class_name Level extends Node2D

enum Difficulty {
	EFFORTLESS,
	EASY,
	AVERAGE,
	HARD,
	TOUGH,
	INSANE
}

signal on_load

var level_config : LevelConfig

@export_group("Files")
@export_file_path("*.tscn") var level_ui_path : String = "res://Scenes/UI/level_ui.tscn"

var current_ui : LevelUI

#region Private
## Gets the spawn which the player should.. well.. spawn at.
func _get_first_spawn() -> Node2D:
	for node in get_tree().get_nodes_in_group("PlayerSpawn"):
		if is_ancestor_of(node): return node
	return null

## Return the camera to be used in the level. Override to set custom camera stats.
func _make_camera() -> GameCamera:
	var cam : GameCamera = load("res://Scenes/Player/game_camera.tscn").instantiate()
	return cam

## Return the player to be used in the level. Override to set custom player stats.
func _make_player() -> Player:
	return load("res://Scenes/Player/player.tscn").instantiate()

## Setup the camera. Should only be overidden if specific functionality is needed. Otherwise,
## use _make_camera.
func _setup_camera() -> void:
	var camera := _make_camera()
	add_child(camera)

## Setup the player. Should only be overidden if specific functionality is needed. Otherwise,
## use _make_player.
func _setup_player() -> Player:
	var player := _make_player()
	var spawn := _get_first_spawn()
	if is_instance_valid(spawn): 
		player.get_player_body().global_position = _get_first_spawn().global_position
		add_child(player)
		player.get_player_sword().body.global_position = player.get_player_body().global_position
	return player

## Instantiate and child the LevelUI. Must be registered to a player to display.
func _setup_ui() -> void:
	current_ui = load(level_ui_path).instantiate()
	add_child(current_ui)
	
#endregion

#region Public
func hide_ui() -> void:
	current_ui.hide()

## Syncronize displayed information (items, health, etc.) with a target player.
## Should be called whenever a new UI is created.
func register_ui(player : Player) -> void:
	current_ui.register_player(player)

func initialize(config : LevelConfig = null) -> void:
	
	if not config:
		config = LevelConfig.new()
	level_config = config
	
	var player := _setup_player()
	_setup_camera()
	
	_setup_ui()
	register_ui(player)
	
	on_load.emit()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

static func get_level_data() -> void:
	pass
#endregion

#region Inherited
func _ready() -> void:
	
	# Delegate pausing to separate node as to ensure level gets paused, as well.
	var pause_man : Node = load("res://Scenes/Component/pause_manager.tscn").instantiate()
	add_child(pause_man)
#endregion
