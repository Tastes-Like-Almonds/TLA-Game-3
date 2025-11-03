class_name SwordWeapon extends Weapon

# Used to add a delay between boosting and landing on the ground as to not provide 2 charges.
var touch_ground_cooldown : float = 0.1
var current_touch_cooldown : float = 0.0

func _init() -> void:
	MAX_CHARGE = 1.0

func get_cooldown() -> float:
	return 0.0

func get_dir() -> Vector2:
	if not is_instance_valid(_wielder): return Vector2.ZERO
	var sword := _wielder.get_player_sword()
	var vec := Vector2.ZERO
	if sword.control_mode == sword.ControlMode.GLOBAL_MOUSE:
		vec = _wielder.get_player_position().direction_to(get_pointer_pos())
	elif sword.control_mode == sword.ControlMode.LOCAL_MOUSE:
		vec = Helper.get_mouse_vec_from_center()
	return vec.normalized()

func process_weapon(delta:float) -> void:
	current_touch_cooldown = clampf(current_touch_cooldown+delta, 0.0, touch_ground_cooldown)
	super(delta)
	if _wielder.get_player_body().is_on_floor() or _wielder.get_player_sword().is_on_ground():
		if current_touch_cooldown >= touch_ground_cooldown:
			can_use = true

func on_use(charge_time : float) -> void:
	if not is_instance_valid(_wielder): return
	_wielder.apply_velocity(get_dir()*(min(MAX_CHARGE,charge_time)/MAX_CHARGE)*1200*_wielder.get_size_scale())
	current_touch_cooldown = 0.0
	can_use = false

func get_property_modifiers() -> Dictionary[String, Array]:
	if not is_instance_valid(_wielder): return {}
	return {}

func get_charge_prog(prog : float) -> float:
	if not is_instance_valid(_wielder): return 0.0
	return clampf(prog/MAX_CHARGE, 0, 1)
