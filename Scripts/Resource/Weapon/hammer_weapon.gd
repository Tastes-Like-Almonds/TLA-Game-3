extends Weapon
class_name HammerWeapon

const MAX_CHARGE = 0.25

func process_weapon(delta:float) -> void:
	super(delta)

func get_property_modifiers() -> Dictionary[String, Array]:
	return {
		"gravity": [PropertyModifier.new(-1, PropertyModifier.ModiferType.MULTIPLY)]
	}

func get_cooldown() -> float:
	return 0.1

func on_use(_charge_time : float) -> void:
	#_wielder.apply_velocity(_wielder.get_player_position().direction_to(get_pointer_pos())*min(MAX_CHARGE,charge_time)*3000)
	#_wielder.teleport_toward(_get_target_point())
	pass

func get_max_distance_increase() -> float:
	return min(_wielder.get_ability_charge()/MAX_CHARGE, 1)*-20

func get_charge_prog(prog : float) -> float:
	return clampf(prog/MAX_CHARGE, 0, 1)
