class_name SwordWeapon extends Weapon

const MAX_CHARGE = 0.5

func get_cooldown() -> float:
	return 1.0

func get_dir() -> Vector2:
	if not is_instance_valid(_wielder): return Vector2.ZERO
	var sword := _wielder.get_player_sword()
	var vec := Vector2.ZERO
	if sword.control_mode == sword.ControlMode.GLOBAL_MOUSE:
		vec = _wielder.get_player_position().direction_to(get_pointer_pos())
	elif sword.control_mode == sword.ControlMode.LOCAL_MOUSE:
		vec = Helper.get_mouse_vec_from_center()
	return vec.normalized()

func on_use(charge_time : float) -> void:
	if not is_instance_valid(_wielder): return
	_wielder.apply_velocity(get_dir()*min(MAX_CHARGE,charge_time)*3000*_wielder.get_size_scale())

func get_property_modifiers() -> Dictionary[String, Array]:
	if not is_instance_valid(_wielder): return {}
	
	return {
		"max_distance": [
			PropertyModifier.new(
		1-_wielder.get_weapon_charge_perc()*0.2,
		PropertyModifier.ModiferType.MULTIPLY)
		]
			
	}

func get_charge_prog(prog : float) -> float:
	if not is_instance_valid(_wielder): return 0.0
	return clampf(prog/MAX_CHARGE, 0, 1)
