extends Weapon
class_name StaffWeapon

const MAX_CHARGE = 0.25
const DISTANCE = 600

var staff_line := preload("res://Scenes/Visual/staff_line.tscn")
var current_staff_line : Line2D = null

func _get_target_point() -> Vector2:
	var pos := _wielder.get_player_position()
	return pos+pos.direction_to(_wielder.get_player_sword().get_tip_global_position())*_wielder.get_weapon_charge_perc()*DISTANCE

func process_weapon(delta:float) -> void:
	super(delta)
	if is_instance_valid(current_staff_line):
		if current_staff_line.points.size() == 2:
			current_staff_line.points[0] = _wielder.get_player_position()
			current_staff_line.points[1] = _get_target_point()
	else:
		current_staff_line = staff_line.instantiate()
		current_staff_line.add_point(_wielder.get_player_position())
		current_staff_line.add_point(_get_target_point())
		_wielder.get_parent().add_child(current_staff_line)

func on_unequip() -> void:
	if is_instance_valid(current_staff_line):
		current_staff_line.queue_free()

func get_cooldown() -> float:
	return 0.1

func on_use(_charge_time : float) -> void:
	#_wielder.apply_velocity(_wielder.get_player_position().direction_to(get_pointer_pos())*min(MAX_CHARGE,charge_time)*3000)
	_wielder.teleport_toward(_get_target_point())

func get_max_distance_increase() -> float:
	return min(_wielder.get_ability_charge()/MAX_CHARGE, 1)*-20

func get_charge_prog(prog : float) -> float:
	return clampf(prog/MAX_CHARGE, 0, 1)
