class_name Main extends Node

@export_file_path("*.tscn") var autoload_level : String = ""

@onready var transition_overlay : Control = $UI/TransitionOverlay
@onready var transiton_overlay_player : AnimationPlayer = $UI/TransitionOverlay/AnimationPlayer

#region Getters
func get_dev_panel() -> DevPanel:
	if is_instance_valid(%DevPanel):
		return %DevPanel
	return null
#endregion

func _ready() -> void:
	Globals.main = self
	if autoload_level:
		LevelLoader.load_level(autoload_level, self)
		$LevelSelect.hide()
	
	# The below commented-out code is used for multiplayer testing, which will not be done for a while.
	# It may never get added, but it's here in case it does.
	
	#var args := OS.get_cmdline_args()
	#var user_type := ""
	#for arg in args:
		#if arg.begins_with("--host"):
			#user_type = "host"
			#Lobby.create_game()
		#elif arg.begins_with("--client"):
			#user_type = "client"
			#Lobby.join_game("127.0.0.1")
	#print("Prints for '" + user_type + "':")
	#print(Lobby.players)
