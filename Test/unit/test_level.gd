extends GutTest

var level_path : String = "res://Test/TestResource/level_test.tscn"
var level : Level

func before_all() -> void:
	gut.show_orphans(false)

func before_each() -> void:
	level = load(level_path).instantiate()
	watch_signals(level)
	add_child_autoqfree(level)

func test_level_load_signal() -> void:
	assert_signal_not_emitted(level.on_load, "Signal on_load should not emit on its own.")
	level.initialize()
	assert_signal_emitted(level.on_load, "Level should emit on_load after initialization.")

func test_setup_ui() -> void:
	
	var ui : Variant = load(level.level_ui_path).instantiate()
	assert_is(ui, LevelUI, "Instantiating level_ui_path should return a LevelUI object.")
	
	level._setup_ui()
	assert_not_null(level.current_ui, "_setup_ui() should result in a non-null LevelUi instance.")

func after_each() -> void:
	level.free()
