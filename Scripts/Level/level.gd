## A base class for levels. 
@abstract class_name Level extends Node2D

var level_config : LevelConfig

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
func _setup_player() -> void:
	var player := _make_player()
	var spawn := _get_first_spawn()
	if is_instance_valid(spawn): player.global_position = _get_first_spawn().global_position
	add_child(player)

func initialize(config : LevelConfig = null) -> void:
	
	if not config:
		config = LevelConfig.new()
	level_config = config
	
	_setup_player()
	_setup_camera()

static func get_level_data() -> void:
	pass
