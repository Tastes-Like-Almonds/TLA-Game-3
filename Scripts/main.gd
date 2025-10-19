class_name Main extends Node

#region Getters
func get_dev_panel() -> DevPanel:
	if is_instance_valid(%DevPanel):
		return %DevPanel
	return null
#endregion

func _ready() -> void:
	Globals.main = self
	LevelLoader.load_level("res://Scenes/Level/dev_level_3.tscn", self)
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
