## Loads player cosmetics for any given weapon, hat etc.
extends Node

func get_weapon_visual(weapon : Weapon) -> WeaponVisual:

	if weapon is SwordWeapon:
		return load("res://Scenes/Visual/Weapons/Sword/sword_basic_visual.tscn").instantiate()
	elif weapon is WoodSwordWeapon:
		var visual : WeaponVisual = load("res://Scenes/Visual/Weapons/Sword/sword_basic_visual.tscn").instantiate()
		visual.trail_color = Color.SADDLE_BROWN
		visual.texture = load("res://Assets/Sprites/Weapon/Wooden Sword.png")
		return visual
	elif weapon is StaffWeapon:
		return load("res://Scenes/Visual/Weapons/Staff/staff_basic_visual.tscn").instantiate()
	elif weapon is HammerWeapon:
		return load("res://Scenes/Visual/Weapons/Hammer/hammer_basic_visual.tscn").instantiate()

	return load("res://Scenes/Visual/Weapons/Sword/sword_basic_visual.tscn").instantiate()

func get_body_cosmetics() -> Array[BodyCosmetic]:
	return []
