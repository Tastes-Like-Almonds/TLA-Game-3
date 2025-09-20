class_name TestWeapon extends Weapon

var cooldown: float

func _init(_cooldown: float = 1.0):
	cooldown = _cooldown

func get_cooldown() -> float:
	return cooldown

func get_reset_cooldown() -> float:
	return cooldown

func on_use(_charge_time : float):
	used.emit()

func get_charge_prog(_prog : float):
	return 1.0
