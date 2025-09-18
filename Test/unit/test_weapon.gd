extends GutTest

class TestWeapon extends Weapon:
	var cooldown: float

	func _init(_cooldown: float = 1.0):
		cooldown = _cooldown

	func get_cooldown() -> float:
		return cooldown
	
	func on_use():
		return

class MockPlayer extends Player:
	pass

func test_not_initialized():
	var weapon = TestWeapon.new()
	assert_false(weapon._initialized, "Weapon falsely marked initialized")
	assert_false(weapon._valid(), "Weapon shouldn't be valid before initialization")
	assert_false(weapon.can_use(), "Weapon shouldn't be useable before initialization")

func test_initial_cooldown_zero():
	var weapon = TestWeapon.new()
	var player = MockPlayer.new()
	add_child_autoqfree(player)
	weapon.init_weapon(player)
	assert_true(weapon.can_use(), "Weapon should be usable initially")

func test_use_sets_cooldown():
	var weapon = TestWeapon.new(2.5)
	var player = MockPlayer.new()
	add_child_autoqfree(player)
	weapon.init_weapon(player)
	weapon.use()
	assert_false(weapon.can_use(), "Weapon should be on cooldown after use")
	assert_eq(weapon.current_use_cooldown, 2.5, "Cooldown not set correctly after use")

func test_process_reduces_cooldown():
	var weapon = TestWeapon.new(1.5)
	var player = MockPlayer.new()
	add_child_autoqfree(player)
	weapon.init_weapon(player)
	weapon.use()
	weapon.process_weapon(0.5)
	assert_almost_eq(weapon.current_use_cooldown, 1.0, 0.01, "Cooldown should decrease after processing")
