class_name LevelDisplay extends PanelContainer

signal play_level_pressed(level_data:LevelNodeData)

@onready var title_label : RichTextLabel = $Control/HBoxContainer/Control3/VBoxContainer/Title
@onready var desc_label  : RichTextLabel = $Control/HBoxContainer/Control3/VBoxContainer/Description

@onready var play_button : Button = $Control/HBoxContainer/Control3/VBoxContainer/Play

var current_level_data   : LevelNodeData = null

func load_level(level_data : LevelNodeData) -> void:
	current_level_data = level_data
	_update_display()

func _play_level() -> void:
	play_level_pressed.emit(current_level_data)

func _update_display() -> void:
	if not current_level_data: 
		hide()
		return
	show()
	
	title_label.text = current_level_data.sid + " - " + current_level_data.level_data.title
	desc_label.text  = current_level_data.level_data.description

func _ready() -> void:
	_update_display()
