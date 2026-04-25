class_name LevelDisplay extends PanelContainer

signal play_level_pressed(level_data:LevelNodeData)

@onready var title_label : RichTextLabel = $Control/HBoxContainer/Control3/VBoxContainer/Title
@onready var desc_label  : RichTextLabel = $Control/HBoxContainer/Control3/VBoxContainer/Description
@onready var diff_label  : RichTextLabel = $Control/HBoxContainer/Control3/VBoxContainer/Diffculty
@onready var history     : Tree          = $Control/HBoxContainer/History/ScrollContainer/VBoxContainer/Tree
@onready var not_comp    : Control       = $Control/HBoxContainer/History/NotCompleted
@onready var comp        : Control       = $Control/HBoxContainer/History/ScrollContainer

@onready var play_button : Button = $Control/HBoxContainer/Control3/VBoxContainer/Play

var current_level_data   : LevelNodeData = null
var current_world        : WorldData = null

func load_level(level_data : LevelNodeData, world : WorldData) -> void:
	current_level_data = level_data
	current_world = world
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
	diff_label.text = current_level_data.level_data.get_difficulty_string()
	
	# Update completion history
	var completions := SaveSlots.get_level_completions(current_world.name, current_level_data.sid)
	
	history.clear()
	history.create_item() # Create root item
	
	if completions.size() > 0:
		comp.show()
		not_comp.hide()
	else:
		not_comp.show()
		comp.hide()
	
	
	for completion : Dictionary in completions:
		var item : TreeItem = history.create_item(history.get_root())
		item.set_text(0, Helper.format_time(completion["time_sec"]))
		item.set_text(1, str(completion["deaths"]))
		item.set_text(2, str(completion["damage_taken"]))

func _ready() -> void:
	_update_display()
	history.columns = 3
	history.set_column_title(0, "Time")
	history.set_column_title(1, "Deaths")
	history.set_column_title(2, "Damage")
	history.column_titles_visible = true
	history.hide_root = true
