extends Weapon
class_name StaffWeapon

const MAX_CHARGE = 0.5

func get_cooldown() -> float:
	return 0.1

func on_use(charge_time : float) -> void:
	_wielder.apply_velocity(_wielder.get_player_position().direction_to(get_pointer_pos())*min(MAX_CHARGE,charge_time)*3000)
	pass

func get_max_distance_increase() -> float:
	return min(_wielder.get_ability_charge()/MAX_CHARGE, 1)*-20

func get_charge_prog(prog : float):
	return clampf(prog/MAX_CHARGE, 0, 1)
