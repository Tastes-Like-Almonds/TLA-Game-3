class_name SwordWeapon extends Weapon

const MAX_CHARGE = 0.5

func get_cooldown() -> float:
	return 1.0

func get_dir() -> Vector2:
	var sword = _wielder.get_player_sword()
	var vec = Vector2.ZERO
	if sword.control_mode == sword.ControlMode.GLOBAL_MOUSE:
		vec = _wielder.get_player_position().direction_to(get_pointer_pos())
	elif sword.control_mode == sword.ControlMode.LOCAL_MOUSE:
		vec = Helper.get_mouse_vec_from_center()
	return vec.normalized()

func on_use(charge_time : float) -> void:
	_wielder.apply_velocity(get_dir()*min(MAX_CHARGE,charge_time)*3000)

func get_max_distance_increase() -> float:
	return min(_wielder.get_ability_charge()/MAX_CHARGE, 1)*-20

func get_charge_prog(prog : float):
	return clampf(prog/MAX_CHARGE, 0, 1)
