extends Area2D

## The level to be loaded upon contact
@export_file_path("*.tscn") var load_level:String

## True if level is not blank; that's all.
var valid_level:bool = false

## If level is currently switching
var transitioning:bool = false

func _get_level(target:Node) -> Level:
	if (!(target is Level)):
		return _get_level(target.get_parent())
	return target

func call_loader(_x: Variant) -> void:
	LevelLoader.load_level(load_level, Globals.get_level_load_node())

func _unfade(_x: Variant) -> void:
	Globals.main.transiton_overlay_player.play("fade_from_black")
	Globals.main.transiton_overlay_player.animation_finished.disconnect(call_loader)
	SignalBus.LevelPathLoaded.disconnect(_unfade)

func _emit_finished(_x: Variant) -> void:
	SignalBus.TransitionFinished.emit()
	Globals.main.transiton_overlay_player.animation_finished.disconnect(_emit_finished)

## Load load_level via LevelLoader.gd.
func transition() -> void:
	
	if transitioning == true: return
	transitioning = true
	
	# NOTE: LevelConfig is not passed here, so if this is used in the future
	# be sure to change it probably via finding it in level.gd.
	_get_level(self).hide_ui()
	Globals.main.transiton_overlay_player.play("fade_to_black")
	
	# NOTE: This is a bit ugly, but functions are offloaded to non-lambdas so they can be disconnected.
	# They should not be called in any other context.
	
	# Load level when the screen is fully black
	Globals.main.transiton_overlay_player.animation_finished.connect(call_loader)
	
	# Unfade transition only when the level is finished loading
	SignalBus.LevelPathLoaded.connect(_unfade)
	
	# Emit signal when the transition is fully over.
	Globals.main.transiton_overlay_player.animation_finished.connect(_emit_finished)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		if is_instance_valid(player): transition()

func _ready() -> void:
	if load_level: valid_level = true
