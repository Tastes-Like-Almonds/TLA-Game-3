class_name Main extends Node

#region Getters
func get_dev_panel() -> DevPanel:
	if is_instance_valid(%DevPanel):
		return %DevPanel
	return null
#endregion

func _ready() -> void:
	Globals.main = self
