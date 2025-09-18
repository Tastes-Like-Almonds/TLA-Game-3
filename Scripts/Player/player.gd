extends Node2D
class_name Player

var last_collision : KinematicCollision2D = null

#region Exports

# --- #
@export_group("Sword")
## The maximum distance from the sword tip to the player (Soft limit)
@export var max_distance : float = 100.0

## Minimum distance between the sword tip and player
@export var min_distance : float = 10.0

## The strength of the player; the sword flings more when higher.
@export_range(0,5, 0.1) var strength : float = 2.5

# --- #
@export_group("Physics")
## Speed of gravity.
@export_range(0,2000, 1.0) var gravity : float = 1500.0

@export var air_drag : Vector2 = Vector2(0.2,0.2)
@export var ground_drag : Vector2 = Vector2(0.2,0.2)

## The drag applied to the player when being soft-limited (From the sword distance).
## This is applied to the previous drag multiplicatively.
@export_range(0,1) var soft_limit_drag : float = 0.1

## The distance beyond max_distance which the player will be limited
@export_range(0,1) var soft_limit_distance_coef : float = 1.1

# --- #
@export_group("Startup")

## The weapon the player starts with
@export var starting_weapon : Weapon = null

#endregion

#region Properties
## The amount of time the player has triggered their M1 ability
var ability : float = 0.0

## The currently selected weapon
var current_weapon : Weapon
#endregion

#region Getters
func get_max_distance() -> float:
	return max_distance

func get_min_distance() -> float:
	return min_distance

func get_gravity() -> float:
	return gravity

func get_strength() -> float:
	return strength

func get_air_drag() -> Vector2:
	return air_drag

func get_ground_drag() -> Vector2:
	return ground_drag

func get_soft_limit_drag() -> float:
	return soft_limit_drag

func get_soft_limit_distance_coef() -> float:
	return soft_limit_distance_coef

## Get the last kinematic collision of the sword tip
func get_last_collision() -> KinematicCollision2D:
	return last_collision

## Gets the player's body.
func get_player_body() -> PlayerBody:
	
	var body : PlayerBody
	
	for child in get_children():
		if child is PlayerBody:
			body = child
			
	return body

## Gets the player's sword
func get_player_sword() -> Sword:
	
	var sword : Sword
	
	for child in get_children():
		if child is Sword:
			sword = child
			
	return sword
#endregion

## Set the last kinematic collision of the sword tip. Should be done each physics process.
func set_last_collision(collision:KinematicCollision2D):
	last_collision = collision

## Returns the global position of the player.
func get_player_position() -> Vector2:
	var body = get_player_body()
	return body.global_position
