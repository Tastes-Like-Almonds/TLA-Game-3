extends Node2D
class_name Player

var last_collision : KinematicCollision2D = null

enum MovementMode {
	SWORD_ORBIT, # The sword orbits the player
	PLAYER_ORBIT, # TODO The player orbits the sword
	NOCLIP # TODO The player flies toward the sword when charging. Collisions disabled in this mode.
}

# TODO Cache sword and body ref until child structure is altered

#region Exports

# --- #
@export_group("Sword")
## The maximum distance from the sword tip to the player (Soft limit)
@export var max_distance : float = 140.0

## Minimum distance between the sword tip and player
@export var min_distance : float = 10.0

## The strength of the player; the sword flings more when higher.
@export_range(0,5, 0.1) var strength : float = 2.5

## The strength of the player when in player orbit mode.
@export var player_orbit_strength : float = 10.0

## How much the sword sticks to ground. Higher = lower friction
@export_range(0,1) var sword_slide : float = 0.2

## The multipler of knockback dealt to the player
@export var self_knockback_multi : float = 1

# --- #
@export_group("Physics")
## Speed of gravity.
@export_range(0,3000, 1.0) var gravity : float = 70.0

@export var air_drag : Vector2 = Vector2(0.4,0.8)
@export var ground_drag : Vector2 = Vector2(0.01,1.0)

## The drag applied to the player when being soft-limited (From the sword distance).
## This is applied to the previous drag multiplicatively.
@export_range(0,1) var soft_limit_drag : float = 0.1

## The distance beyond max_distance which the player will be limited
@export_range(0,3) var soft_limit_distance_coef : float = 1.3

@export_range(0,1) var bounciness : float = 0.25

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

## The current movement mode
var movement_mode : MovementMode = MovementMode.SWORD_ORBIT

## If the player is currently hooked on a cable.
## No getter/setter methods as this is managed in cable.gd
var on_cable : bool = false
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

func get_player_orbit_strength() -> float:
	return player_orbit_strength

func get_sword_slide() -> float:
	return sword_slide

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

func is_charging_ability() -> bool:
	return charging_ability

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

## Gets the currently equipped weapon
func get_current_weapon() -> Weapon:
	return current_weapon

## Gets the current movement mode
func get_movement_mode() -> MovementMode:
	return movement_mode

## Gets the current damage of the blade (Value changes based on speed, charge, etc.)
func get_blade_damage() -> float:
	var damage := 0.0
	var sword = get_player_sword()
	
	damage += sword.get_last_sword_velocity().length()
	
	return damage

func get_knockback_multi() -> float:
	return self_knockback_multi

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
		if current_weapon:
			weapon_visual.update_charge_prog(current_weapon.get_charge_prog(get_ability_charge()))
		weapon_visual.update_visual(get_player_position(), get_player_sword().get_tip_global_position())

#endregion

#region Item

func equip_weapon(weapon : Weapon) -> void:
	
	if !weapon: return
	if !weapon.can_use(): weapon.init_weapon(self)
	
	weapon.reset()
	current_weapon = weapon
	
	_clear_visuals()
	
	var scn : PackedScene = CosmeticLoader.get_weapon_visual(weapon)
	if scn:
		weapon_visual = scn.instantiate()
		weapon_visual.set_player(self)
		add_child(weapon_visual)

#endregion

#region Actions

func start_charging() -> void:
	charging_ability = true

func stop_charging() -> void:
	charging_ability = false
	if current_weapon:
		current_weapon.use(ability_charge)
	ability_charge = 0.0

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("use"):
		start_charging()
	
	elif event.is_action_released("use"):
		stop_charging()
	
	elif event.is_action_pressed("quit"):
		get_tree().quit()
	
	elif event.is_action_pressed("ui_accept"):
		set_movement_mode(MovementMode.NOCLIP)


func apply_velocity(vel : Vector2) -> void:
	get_player_body().velocity += vel

func deal_knockback(vel : Vector2) -> void:
	apply_velocity(vel)

func set_collisions(state : bool) -> void:
	for child in Helper.get_all_descendants(self):
		if child is CollisionShape2D:
			child.disabled = not state

func set_movement_mode(mode : MovementMode) -> void:
	movement_mode = mode
	
	# Load defaults
	set_collisions(true)
	
	# Load movement mode settings
	match movement_mode:
		MovementMode.NOCLIP:
			set_collisions(false)
	

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
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

## Set the last kinematic collision of the sword tip. Should be done each physics process.
func set_last_collision(collision:KinematicCollision2D):
	last_collision = collision

## Returns the global position of the player.
func get_player_position() -> Vector2:
	var body = get_player_body()
	return body.global_position
