extends DevPanelCategory

@onready var select_level_dropdown : OptionButton = $MarginContainer/VBoxContainer/TargetPlayer/VBoxContainer/SelectLevel
@onready var select_level_confirm : Button = $MarginContainer/VBoxContainer/TargetPlayer/VBoxContainer/Load

@onready var reload_level_confirm : Button = $MarginContainer/VBoxContainer/Reload

var last_level : String

func _update_level_select_dropdown() -> void:
	
	select_level_dropdown.clear()
	
	var paths := LevelLoader.get_all_level_paths()
	for path in paths:
		select_level_dropdown.add_item(path.get_file())
		select_level_dropdown.set_item_metadata(select_level_dropdown.item_count-1, path)

## Loads the currently selected level to the target parent. If clear_prev is true (default),
## it will delete the level within the parent before it.
func _load_selected_level(parent:Node, clear_prev: bool = true) -> void:
	var meta : Variant = select_level_dropdown.get_selected_metadata()
	if clear_prev: LevelLoader.clear_levels(parent)
	var result := LevelLoader.load_level(meta, parent)
	if result == LevelLoader.LoadLevelStatus.SUCCESS:
		last_level = meta

func _ready() -> void:
	_update_level_select_dropdown()
	await SignalBus.MainLoaded
	var parent := Globals.main
	select_level_confirm.pressed.connect(func() -> void: _load_selected_level(parent))
	reload_level_confirm.pressed.connect(func() -> void: LevelLoader.clear_levels(parent) ; LevelLoader.load_level(last_level, parent))
