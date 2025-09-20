extends GutTest

var player

func before_each():
	player = preload("res://Scenes/Player/player.tscn").instantiate()
	add_child_autofree(player)

# ------------ #
# Weapon tests #
# ------------ #

func test_equip_weapon():
	
	var weapon = TestWeapon.new(1.0)
	player.equip_weapon(weapon)
	
	assert_eq(player.get_current_weapon(), weapon, "Player weapon not set after equip")

func test_visuals():
	
	var weapon = TestWeapon.new(1.0)
	player.equip_weapon(weapon)
	
	assert_not_null(player.weapon_visual, "Player weapon visual not set")
	
	player._clear_visuals()
	for child in player.get_children():
		assert_true(not (child is WeaponVisual and is_instance_valid(child) and not child.is_queued_for_deletion()), "Weapon visual not cleared correctly")
	
