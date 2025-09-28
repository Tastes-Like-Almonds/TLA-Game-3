extends DevPanelCategory

@onready var SelectLevelDropdown : OptionButton = $MarginContainer/VBoxContainer/TargetPlayer/VBoxContainer/SelectLevel
@onready var SelectlevelConfirm : Button = $MarginContainer/VBoxContainer/TargetPlayer/VBoxContainer/Load

func _update_level_select_dropdown() -> void:
	
	SelectLevelDropdown.clear()
	
	var paths := LevelLoader.get_all_level_paths()
	for path in paths:
		SelectLevelDropdown.add_item(path)

func _ready() -> void:
	_update_level_select_dropdown()
