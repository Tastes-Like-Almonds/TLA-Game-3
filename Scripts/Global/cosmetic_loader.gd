extends Node

## Loads player cosmetics for any given weapon, hat etc.
## Cosmetics are currently unimplemented, but this class will serve a more useful purpose later on.

func get_weapon_visual(weapon : Weapon) -> PackedScene:

	if weapon is SwordWeapon:
		return load("res://Scenes/Visual/Weapons/Sword/sword_basic_visual.tscn")
	elif weapon is StaffWeapon:
		return load("res://Scenes/Visual/Weapons/Staff/staff_basic_visual.tscn")
	elif weapon is HammerWeapon:
		return load("res://Scenes/Visual/Weapons/Hammer/hammer_basic_visual.tscn")

	return load("res://Scenes/Visual/Weapons/Sword/sword_basic_visual.tscn")
