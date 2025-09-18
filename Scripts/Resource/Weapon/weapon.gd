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

## Should be called on weapon creation
func init_weapon(player: Player) -> void:
	_wielder = player
	_initialized = true

## Should be called each frame
func process_weapon(delta:float):
	if !_valid(): return
	current_use_cooldown = max(0.0, current_use_cooldown-delta)

## Returns true if the weapon can be used
func can_use() -> bool:
	if !_valid(): return false
	return current_use_cooldown <= 0.0

## Activates the weapon's ability
func use():
	if !can_use(): return
	if !_valid(): return
	current_use_cooldown = get_cooldown()
	on_use()
	used.emit()

## Gets the cooldown time of the weapon.
@abstract func get_cooldown() -> float

## Calls when the weapon is used
@abstract func on_use()
