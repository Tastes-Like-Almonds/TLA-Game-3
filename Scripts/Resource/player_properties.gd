## Handles player stats such as strength, sword distance, physics settings, and many others.
## Stats all have a base value which should not be changed, and can be modified using PropertyModifiers.
##
## Those modifiers can be applied to a stat using get_modified and the array of modifiers.
## 
## This is done so that status effects and other temporary changes to the player do not override
## the player's initial stats.

class_name PlayerProperties extends Resource

# --- #
@export_group("Health and Damage")

## The lives the player will start with after spawning. Altering mid-game does nothing.
@export var max_lives : int = 300

## Maximum health of the player. Does not regenerate.
@export var max_health : float = 10.0

## The minimum amount of time required to pass betewen damage.
@export var invincibility_time : float = 0.5

## The time spent before the player respawns.
@export var respawn_time : float = 2.0

## The base damage of the sword.
@export var sword_damage : float = 6

## The shortest amount of time needed to reach maximum damage; higher values will require
## longer swings to deal max damage.
@export var max_damage_time : float = 0.3

# --- #
@export_group("Sword")

## Max knockback dealt to enemies on hit
@export var knockback : float = 1600.0

## Speed at which the sword moves. This also affects its strength of pushing.
@export var sword_speed : float = 3000

## The maximum distance from the sword tip to the player (Soft limit)
@export var max_distance : float = 160.0

## Minimum distance between the sword tip and player
@export var min_distance : float = 30.0

## The strength of the player; the sword flings more when higher.
@export_range(0,5, 0.1) var strength : float = 4.5

## The strength of the player when in player orbit mode.
@export var player_orbit_strength : float = 10.0

## How much the sword sticks to ground. Higher = lower friction
@export_range(0,1) var sword_slide : float = 0.2

## The multipler of knockback dealt to the player
@export var self_knockback_multi : float = 1

# --- #
@export_group("Inventory")

## The max number of items which the player can hold.
@export_range(1,10, 1) var max_equip : int = 2

## If true, the player will automatically equip picked up items. This happens by default
## if the player's max weapons value is reached.
@export var equip_on_pickup : bool = true

# --- #
@export_group("Physics")

## Size multiplier of the player. Also affects sword distance.
@export_range(0.1,5,0.1) var size_scale : float = 1.0

## The speed which the player falls.
@export_range(0,3000, 1.0) var gravity : float = 3000.0

## Gravity used for cable speed only.
@export_range(0,200) var cable_gravity : float = 70.0

## The coefficient of velocity applied each second while in mid-air.
@export var air_drag : Vector2 = Vector2(0.4,0.8)

## The amount of seconds it takes for friction to be fully applied to velocity.
## For exampe, if equal to 0.5, and the friction of the ground is 0.5, it will take half a second for 
## the movement to be halved.
@export var friction_time : float = 0.5

## The drag applied to the player when being soft-limited (From the sword distance).
## This is applied to the previous drag multiplicatively.
@export_range(0,1) var soft_limit_drag : float = 0.1

## The distance beyond max_distance which the player will be limited
@export_range(0,3) var soft_limit_distance_coef : float = 1.3

## The amount of velocity that is converted into bounce upon the player landing.
@export_range(0,1) var bounciness : float = 0.25

# --- #
@export_group("Startup")

## The weapon the player starts with
@export var starting_weapon : Weapon = SwordWeapon.new()

static func _get_modifiers_of_type(type : PropertyModifier.ModiferType, modifiers : Array[PropertyModifier]) -> Array[PropertyModifier]:
	var all : Array[PropertyModifier] = []
	for modifier in modifiers:
		if modifier.mod_type == type: all.append(modifier)
	return all

## Gets the target property, accounting for modifiers.
func get_modified(property : String , modifiers : Array[PropertyModifier]) -> Variant:
	var p : Variant = get(property)
	
	for type_key:String in PropertyModifier.ModiferType.keys():
		var type_enum : PropertyModifier.ModiferType = PropertyModifier.ModiferType.get(type_key)
		var typed_mods := _get_modifiers_of_type(type_enum, modifiers)
		if p is float:
			p = PropertyModifier.apply_all(typed_mods, p)
	
	if property == "max_distance":
		p*=size_scale
	if property == "min_distance":
		p*=size_scale
	if property == "gravity":
		p*=size_scale
	if property == "sword_speed":
		p*=size_scale
	if property == "cable_gravity":
		p*=size_scale
	
	return p
