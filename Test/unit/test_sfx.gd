extends GutTest

var sound : SoundData

func before_each() -> void:
	sound = SoundData.new(
		"res://Test/TestResource/TestSound.wav",
		0,
		1.0
	)

func test_play_sound_2d() -> void:
	Sfx.play_sound_2d(
		sound,
		Vector2(0,0),
		true
	)
	assert_eq(Sfx.sound_2d_parent.get_child_count(), 1, "Playing sound should result in only one child")
	
	Sfx.play_sound_2d(
		sound,
		Vector2(0,0),
		true
	)
	
	var count := 0
	if Sfx.sound_2d_parent.get_child_count() > 1:
		for child in Sfx.sound_2d_parent.get_children():
			if is_instance_valid(child) and not child.is_queued_for_deletion(): count += 1
	assert_eq(count, 1, "Overriding sound should result in exactly one valid child")
	
	assert_false(Sfx.sound_2d_parent.get_child_count() <= 0, "Overriding sound should not result in zero children")
	
	Sfx.play_sound_2d(
		sound,
		Vector2(0,0),
		false
	)
	
	count = 0
	if Sfx.sound_2d_parent.get_child_count() > 1:
		for child in Sfx.sound_2d_parent.get_children():
			if is_instance_valid(child) and not child.is_queued_for_deletion(): count += 1
	assert_eq(count, 2, "Playing additional, non-override sound should result in two children")

func test_play_sound() -> void:
	Sfx.play_sound(
		sound,
		true
	)
	assert_eq(Sfx.sound_parent.get_child_count(), 1, "Playing sound should result in only one child")
	
	Sfx.play_sound(
		sound,
		true
	)
	
	var count := 0
	if Sfx.sound_parent.get_child_count() > 1:
		for child in Sfx.sound_parent.get_children():
			if is_instance_valid(child) and not child.is_queued_for_deletion(): count += 1
	assert_eq(count, 1, "Overriding sound should result in exactly one valid child")
	
	assert_false(Sfx.sound_parent.get_child_count() <= 0, "Overriding sound should not result in zero children")
	
	Sfx.play_sound(
		sound,
		false
	)
	
	count = 0
	if Sfx.sound_parent.get_child_count() > 1:
		for child in Sfx.sound_parent.get_children():
			if is_instance_valid(child) and not child.is_queued_for_deletion(): count += 1
	assert_eq(count, 2, "Playing additional, non-override sound should result in two children")
