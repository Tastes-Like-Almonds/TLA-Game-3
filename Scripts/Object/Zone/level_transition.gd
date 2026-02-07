extends Area2D

## The level to be loaded upon contact
@export_file_path("*.tscn") var load_level:String

## True if level is not blank; that's all.
var valid_level:bool = false

## If level is currently switching
var transitioning:bool = false

func call_loader() -> void:
	LevelLoader.load_level(load_level, Globals.get_level_load_node())

## Load load_level via LevelLoader.gd.
func transition() -> void:
	print("Transition.")
	
	if transitioning == true: return
	transitioning = true
	
	# NOTE: LevelConfig is not passed here, so if this is used in the future
	# be sure to change it probably via finding it in level.gd.
	#Globals.main.transiton_overlay_player.play("fade_to_black")
	Globals.main.transiton_overlay_player.animation_finished.connect(call_loader)
	SignalBus.LevelPathLoaded.connect(func(_x:Variant) -> void: Globals.main.transiton_overlay_player.play("fade_to_black"))

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		if is_instance_valid(player): transition()

func _ready() -> void:
	if load_level: valid_level = true
