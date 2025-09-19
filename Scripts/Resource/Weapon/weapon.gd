@abstract
extends Resource
class_name Weapon

signal used()

var _wielder : Player
var _initialized : bool = false
var current_use_cooldown : float = 0.0

## Returns true if the weapon has a valid wielder.
func _has_wielder() -> bool:
	return is_instance_valid(_wielder)

## Returns true if the weapon is valid for use (initialized properly)
func _valid():
	return (_initialized and _has_wielder())

## Gets the position of the pointer (mouse)
func get_pointer_pos() -> Vector2:
	if _has_wielder(): return _wielder.get_global_mouse_position()
	return Vector2.ZERO

## Should be called on weapon creation
func init_weapon(player: Player) -> void:
	_wielder = player
	_initialized = true

## Returns true if the weapon was successfully initialized and ready to use.
func is_ready():
	return _valid()

func reset():
	current_use_cooldown = get_cooldown()

## Should be called each frame
func process_weapon(delta:float):
	if !_valid(): return
	current_use_cooldown = max(0.0, current_use_cooldown-delta)

## Returns true if the weapon can be used
func can_use() -> bool:
	if !_valid(): return false
	return current_use_cooldown <= 0.0

## Activates the weapon's ability
func use(charge_time : float):
	if !can_use(): return
	if !_valid(): return
	current_use_cooldown = get_cooldown()
	on_use(charge_time)
	used.emit()

## Gets the cooldown the weapon is reset to upon reseting
func get_reset_cooldown() -> float: 
	return get_cooldown()

## Returns a number which modifies the player's max sword distance.
func get_max_distance_increase() -> float: return 0.0

## Gets the cooldown time of the weapon.
@abstract func get_cooldown() -> float

## Calls when the weapon is used
@abstract func on_use(charge_time : float)
