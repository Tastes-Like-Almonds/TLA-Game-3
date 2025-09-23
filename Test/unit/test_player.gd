extends GutTest

var player : Player
var weapon : Weapon
var other_weapon : Weapon

func before_each():
	player = preload("res://Scenes/Player/player.tscn").instantiate()
	player.max_equip = 1
	weapon = TestWeapon.new(1.0)
	other_weapon = TestWeapon.new(0.5)
	add_child_autofree(player)

# ------------ #
# Weapon tests #
# ------------ #

func test_equip_weapon():
	player.equip_weapon(weapon)
	assert_eq(player.get_current_weapon(), weapon, "Player weapon not set after equip")

func test_equip_weapon_slot():
	player.add_weapon(weapon)
	player.equip_weapon_slot(0)
	assert_true(player.current_weapon == weapon, "Player failed to equip target weapon slot")

func test_add_weapon():
	player.add_weapon(weapon)
	assert_true(player.held_weapons.find(weapon) >= 0, "Add weapon not added to held weapons")
	
	player.add_weapon(other_weapon)
	assert_false(player.held_weapons.size() > 1, "Player weapons exceeded max_equip")
	assert_false(player.held_weapons.size() < 1, "Adding player weapon in excess clears array")

func test_drop_weapon():
	player.add_weapon(weapon)
	player.drop_weapon(0)
	assert_true(player.held_weapons.size() == 0, "Player drop weapon did not remove from held_items")

func test_visuals():
	player.equip_weapon(weapon)
	
	assert_not_null(player.weapon_visual, "Player weapon visual not set")
	
	player._clear_visuals()
	for child in player.get_children():
		assert_true(not (child is WeaponVisual and is_instance_valid(child) and not child.is_queued_for_deletion()), "Weapon visual not cleared correctly")
	
