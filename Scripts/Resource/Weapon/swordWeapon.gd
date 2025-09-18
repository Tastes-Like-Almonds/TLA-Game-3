extends Weapon
class_name SwordWeapon

func get_cooldown() -> float:
	return 1.0

func on_use() -> void:
	print("woohoo")
	pass
