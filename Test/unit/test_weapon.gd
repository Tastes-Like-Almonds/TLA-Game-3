extends GutTest

var player : Player

func before_each() -> void:
	player = preload("res://Scenes/Player/player.tscn").instantiate()
	add_child_autofree(player)

func test_not_initialized() -> void:
	var weapon := TestWeapon.new()
	assert_false(weapon._initialized, "Weapon falsely marked initialized")
	assert_false(weapon._valid(), "Weapon shouldn't be valid before initialization")
	assert_false(weapon.can_use, "Weapon shouldn't be useable before initialization")

func test_initial_cooldown_zero() -> void:
	var weapon := TestWeapon.new()
	weapon.init_weapon(player)
	assert_true(weapon.can_use, "Weapon should be usable initially")

# NOTE Commented out due to weapon changes; kept in case those changes are reverted.
#func test_use_sets_cooldown() -> void:
	#var weapon := TestWeapon.new(2.5)
	#weapon.init_weapon(player)
	#weapon.use(1)
	#assert_false(weapon.can_use, "Weapon should be on cooldown after use")
	#assert_eq(weapon.current_use_cooldown, 2.5, "Cooldown not set correctly after use")

func test_process_reduces_cooldown() -> void:
	var weapon := TestWeapon.new(1.5)
	weapon.init_weapon(player)
	weapon.use(1)
	weapon.process_weapon(0.5)
	assert_almost_eq(weapon.current_use_cooldown, 1.0, 0.01, "Cooldown should decrease after processing")
