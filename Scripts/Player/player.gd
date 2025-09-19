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
@export_range(0,3000, 1.0) var gravity : float = 1500.0

@export var air_drag : Vector2 = Vector2(0.2,0.2)
@export var ground_drag : Vector2 = Vector2(0.2,0.2)

## The drag applied to the player when being soft-limited (From the sword distance).
## This is applied to the previous drag multiplicatively.
@export_range(0,1) var soft_limit_drag : float = 0.1

## The distance beyond max_distance which the player will be limited
@export_range(0,1) var soft_limit_distance_coef : float = 1.1

@export_range(0,1) var bounciness : float = 0.5

# --- #
@export_group("Startup")

## The weapon the player starts with
@export var starting_weapon : Weapon = null

#endregion

#region Properties
## The amount of time the player has triggered their M1 ability
var ability_charge : float = 0.0

## If true, ability will increase by one a second.
var charging_ability : bool = false

## The currently selected weapon
var current_weapon : Weapon

## The current weapon visual
var weapon_visual : WeaponVisual
#endregion

#region Getters
func get_max_distance() -> float:
	var dist : float = max_distance
	
	if current_weapon:
		dist += current_weapon.get_max_distance_increase()
	
	return dist

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

func get_bounciness() -> float:
	return bounciness

func get_soft_limit_distance_coef() -> float:
	return soft_limit_distance_coef

func get_ability_charge() -> float:
	return ability_charge

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

#region Visual

func _clear_visuals():
	for child in get_children():
		if child is WeaponVisual:
			child.queue_free()

func _visual_process():
	
	# Update player rotation
	get_player_body().get_sprite().flip_h = get_player_sword().get_tip_global_position().x < get_player_position().x

	# Update weapon visual
	if weapon_visual:
		weapon_visual.update_visual(get_player_position(), get_player_sword().get_tip_global_position())

#endregion

#region Item

func equip_weapon(weapon : Weapon) -> void:
	
	if !weapon: return
	if !weapon.can_use(): weapon.init_weapon(self)
	
	weapon.reset()
	current_weapon = weapon
	
	var scn : PackedScene = CosmeticLoader.get_weapon_visual(weapon)
	if scn:
		weapon_visual = scn.instantiate()
		add_child(weapon_visual)

#endregion

#region Actions

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("use"):
		charging_ability = true
	
	elif event.is_action_released("use"):
		charging_ability = false
		if current_weapon:
			print(ability_charge)
			current_weapon.use(ability_charge)
		ability_charge = 0.0

func apply_velocity(vel : Vector2) -> void:
	get_player_body().velocity += vel

#endregion

func _process(delta: float) -> void:
	
	if current_weapon:
		current_weapon.process_weapon(delta)
	
	if charging_ability:
		if current_weapon.can_use():
			ability_charge += delta
		else:
			ability_charge = 0

	_visual_process()

func _ready() -> void:
	equip_weapon(starting_weapon)

## Set the last kinematic collision of the sword tip. Should be done each physics process.
func set_last_collision(collision:KinematicCollision2D):
	last_collision = collision

## Returns the global position of the player.
func get_player_position() -> Vector2:
	var body = get_player_body()
	return body.global_position
