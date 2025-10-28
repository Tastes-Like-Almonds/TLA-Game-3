class_name TestWeapon extends Weapon

var cooldown: float

func _init(_cooldown: float = 1.0) -> void:
	cooldown = _cooldown
	MAX_CHARGE = 0.25

func get_cooldown() -> float:
	return cooldown

func get_reset_cooldown() -> float:
	return cooldown

func on_use(_charge_time : float) -> void:
	used.emit()

func get_charge_prog(_prog : float) -> float:
	return 1.0
