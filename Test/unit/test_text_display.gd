extends GutTest

func test_get_scn() -> void:
	var scn := load(TextDisplay.get_scn())
	var loaded : Variant = scn.instantiate()
	assert_false(loaded == null, "get_scn() should not return null.")
	assert_is(loaded, TextDisplay, "get_scn() instantiated should return a TextDisplay object.")

func test_creation() -> void:
	var display := TextDisplay.create()
	add_child_autoqfree(display)
	assert_true(is_instance_valid(display), "TextDisplay.create() Should return a valid instance.")
	
