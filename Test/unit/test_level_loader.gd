extends GutTest

var level_path := "res://Test/TestResource/level_test.tscn"
var not_level_path := "res://Test/TestResource/not_a_level_test.tscn"

var parent : Node

func before_each() -> void:
	parent = Node.new()
	add_child_autoqfree(parent)

func test_load_level() -> void:
	
	assert_eq(
		LevelLoader.load_level(level_path, null), 
		LevelLoader.LoadLevelStatus.INVALID_PARENT, 
		"Invalid parent should return INVALID_PARENT"
	)
	assert_no_new_orphans("Loading level with invalid parent should not result in orphan.")
	
	assert_eq(
		LevelLoader.load_level("", parent), 
		LevelLoader.LoadLevelStatus.INVALID_LEVEL, 
		"Invalid level should return INVALID_LEVEL"
	)
	assert_no_new_orphans("Loading invalid level should not result in orphan.")
	
	assert_eq(
		LevelLoader.load_level(not_level_path, parent), 
		LevelLoader.LoadLevelStatus.LEVEL_IS_NOT_LEVEL, 
		"Non-level node should return LEVEL_IS_NOT_LEVEL"
	)
	assert_no_new_orphans("Loading false level should not result in orphan.")
	
	assert_eq(
		parent.get_child_count(),
		0,
		"Invalid inputs should not create children"
	)
	
	assert_eq(
		LevelLoader.load_level(level_path, parent), 
		LevelLoader.LoadLevelStatus.SUCCESS, 
		"Loading level successfully should return SUCCESS"
	)
	
	assert_eq(
		parent.get_child_count(),
		1,
		"Loading level successfully should result in one added node exactly"
	)

func test_clear_levels() -> void:
	LevelLoader.load_level(level_path, parent)
	LevelLoader.clear_levels(parent)
	
	for child in parent.get_children():
		if is_instance_valid(child):
			assert_false((child is Level) and (not child.is_queued_for_deletion()), "Calling clear_levels() should result in no level objects in the parent.")
