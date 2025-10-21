extends GutTest

var player : Player
var weapon : Weapon
var other_weapon : Weapon

func before_each() -> void:
	player = preload("res://Scenes/Player/player.tscn").instantiate()
	player.properties.max_equip = 1
	weapon = TestWeapon.new(1.0)
	other_weapon = TestWeapon.new(0.5)
	add_child_autofree(player)
	player.held_weapons = []
	player.current_weapon = null

# ------------ #
# Weapon tests #
# ------------ #

func test_equip_weapon() -> void:
	player.equip_weapon(weapon)
	assert_eq(player.get_current_weapon(), weapon, "Player weapon not set after equip")

func test_equip_weapon_slot() -> void:
	player.add_weapon(weapon)
	player.equip_weapon_slot(0)
	assert_true(player.current_weapon == weapon, "After adding a weapon, equip_weapon_slot should set the current weapon to the first weapon.")

func test_add_weapon() -> void:
	player.add_weapon(weapon)
	assert_true(player.held_weapons.find(weapon) >= 0, "Add weapon not added to held weapons")
	
	player.add_weapon(other_weapon)
	assert_false(player.held_weapons.size() > 1, "Player weapons should not exceed max_equip")
	assert_false(player.held_weapons.size() < 1, "Adding player weapon in excess should not clear array")
	
	player.properties.max_equip = 2
	player.add_weapon(other_weapon)
	assert_eq(player.held_weapons.size(), 2, "Adding a second weapon should result in two weapons in held_items")

func test_drop_weapon() -> void:
	player.add_weapon(weapon)
	player.drop_weapon(0)
	assert_true(player.held_weapons.size() == 0, "Player drop weapon did not remove from held_items")

func test_pickup_weapon() -> void:
	player.properties.equip_on_pickup = true
	player.properties.max_equip = 2
	
	var dropped := player.pickup_weapon(weapon)
	
	assert_eq(player.current_weapon, weapon, "Picking up weapon should, if equip_on_pickup is true, equip it automatically.")
	assert_eq(player.held_weapons.size(), 1, "Picking up weapon should result in one equipped weapon.")
	assert_null(dropped, "Picking up a weapon should not drop a weapon when below max_equip.")
	
	player.pickup_weapon(other_weapon)
	
	assert_eq(player.held_weapons.size(), 2, "Picking up second weapon should result in two equipped weapons.")

func test_visuals() -> void:
	player.equip_weapon(weapon)
	
	assert_not_null(player.weapon_visual, "Player weapon visual not set")
	
	player._clear_visuals()
	for child in player.get_children():
		assert_true(not (child is WeaponVisual and is_instance_valid(child) and not child.is_queued_for_deletion()), "Weapon visual not cleared correctly")
	
# -------------- #
# Modifier Tests #
# -------------- #

func test_add_modifier() -> void:
	var mod := PropertyModifier.new(2, PropertyModifier.ModiferType.ADD, 50.0)
	player.add_modifier(mod, "gravity")
	
	assert_not_null(player.property_modifiers.get("gravity"), "Adding modifier should create dict key in property_modifiers")
	assert_true(player.property_modifiers["gravity"] is Array, "Modifier key's value should be an array")
	assert_true(player.property_modifiers["gravity"].size() == 1, "Adding modifier should only result in one modifier.")

func test_remove_modifier_by_id() -> void:
	var mod := PropertyModifier.new(2, PropertyModifier.ModiferType.ADD, 50.0)
	mod.set_id("test_id")
	player.add_modifier(mod, "gravity") # Assume working from previous test
	
	player.remove_modifier_by_id("test_id", "does_not_exist")
	assert_true(player.property_modifiers["gravity"].size() == 1, "Removing property from invalid category should not remove the modifier")
	
	player.remove_modifier_by_id("test_id", "gravity")
	assert_true(player.property_modifiers["gravity"].size() == 0, "Removing only modifier should result in no modifiers.")
