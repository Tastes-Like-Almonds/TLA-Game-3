extends Area2D

## The level to be loaded upon contact
@export_file_path("*.tscn") var load_level:String

## If true, the transition will instead load the level selector.
@export var go_to_selector : bool = true

@export var exit : StringName = "main"

## True if level is not blank; that's all.
var valid_level:bool = false

## If level is currently switching
var transitioning:bool = false

func _get_level(target:Node) -> Level:
	if (!(target is Level)):
		return _get_level(target.get_parent())
	return target

## Load load_level via LevelLoader.gd.
func transition() -> void:
	_get_level(self).complete()

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		if is_instance_valid(player): transition()

func _ready() -> void:
	if load_level: valid_level = true
