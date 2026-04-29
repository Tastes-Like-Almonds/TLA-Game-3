@abstract
extends Resource
class_name Weapon

signal used

@export var use_start_sound : SoundData = SoundData.new("res://Assets/Sound/SFX/Player/Sword/Use start.wav", 0.25, 1.3)
@export var use_end_sound : SoundData = SoundData.new("res://Assets/Sound/SFX/Player/Sword/Use end (1).wav", 0.5)

var _wielder : Player
var _initialized : bool = false
var current_use_cooldown : float = 0.0
var equipped : bool = false

var can_use : bool = true
var MAX_CHARGE: float = 1.0

func get_can_use() -> bool:
	if !_valid(): print("E"); return false
	if _wielder.get_player_body().is_on_floor(): return false
	return can_use

## Returns true if the weapon has a valid wielder.
func _has_wielder() -> bool:
	return is_instance_valid(_wielder)

## Returns true if the weapon is valid for use (initialized properly)
func _valid() -> bool:
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
func is_ready() -> bool:
	return _valid()

func reset() -> void:
	current_use_cooldown = get_cooldown()

## Should be called each frame
func process_weapon(delta:float) -> void:
	if !_valid(): return
	current_use_cooldown = max(0.0, current_use_cooldown-delta)

## Activates the weapon's ability
func use(charge_time : float) -> void:
	if !get_can_use(): return
	current_use_cooldown = get_cooldown()
	on_use(charge_time)
	used.emit()

## Gets the cooldown the weapon is reset to upon reseting
func get_reset_cooldown() -> float: 
	return get_cooldown()

## Returns a number which modifies the player's max sword distance.
func get_max_distance_increase() -> float: return 0.0

## Called when the weapon is being unequipped
func on_unequip() -> void: equipped = false

## Called when the weapon is being equipped
func on_equip() -> void: equipped = true

## Return an array of modifiers to be applied with this weapon.
func get_property_modifiers() -> Dictionary[String, Array]: return {}

## Gets the cooldown time of the weapon.
@abstract func get_cooldown() -> float

## Calls when the weapon is used
@abstract func on_use(charge_time : float) -> void

## Gets the percentage to fully charged of the weapon
@abstract func get_charge_prog(prog : float) -> float
