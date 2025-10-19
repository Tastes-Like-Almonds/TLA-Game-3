class_name Main extends Node

@export_file_path("*.tscn") var autoload_level : String = "res://Scenes/Level/dev_level_3.tscn"

#region Getters
func get_dev_panel() -> DevPanel:
	if is_instance_valid(%DevPanel):
		return %DevPanel
	return null
#endregion

func _ready() -> void:
	Globals.main = self
	LevelLoader.load_level(autoload_level, self)
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
