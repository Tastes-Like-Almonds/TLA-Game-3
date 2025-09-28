## The player character.

class_name Player extends Node2D

var last_collision : KinematicCollision2D = null

enum MovementMode {
	SWORD_ORBIT, # The sword orbits the player
	PLAYER_ORBIT, # TODO The player orbits the sword (Not needed currently; alternative used)
	NOCLIP # The player flies toward the sword when charging. Collisions disabled in this mode.
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
@export_group("Inventory")

## The max number of items which the player can hold.
@export_range(1,10, 1) var max_equip : int = 1

## If true, the player will automatically equip picked up items. This happens by default
## if the player's max weapons value is reached.
@export var equip_on_pickup : bool = true

# --- #
@export_group("Physics")

## The speed which the player falls.
@export_range(0,3000, 1.0) var gravity : float = 3000.0

## Gravity used for cable speed only.
@export_range(0,200) var cable_gravity : float = 70.0

## The coefficient of velocity applied each second while in mid-air.
@export var air_drag : Vector2 = Vector2(0.4,0.8)

## The coefficient of velocity applied each second while on the ground.
@export var ground_drag : Vector2 = Vector2(0.01,1.0)

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

## An array of currently held weapons.
var held_weapons : Array[Weapon] = []
#endregion

#region Getters
## Gets the max distance that the sword should be from the player.
## This is not a hard limit.
func get_max_distance() -> float:
	var dist : float = max_distance
	
	if current_weapon:
		dist += current_weapon.get_max_distance_increase()
	
	return dist

## Gets the minimum distance the sword should be from the player.
func get_min_distance() -> float:
	return min_distance

## Gets the speed of gravity of the player
func get_gravity() -> float:
	return gravity

## Gets the cable gravity of the player
func get_cable_gravity() -> float:
	return cable_gravity

## Gets the stregth of the player, i.e. how much the player can fling themselves
## with their weapon.
func get_strength() -> float:
	return strength

## Gets the strength which the player uses in player_orbit mode.
## Currently unimplemented, and may never be.
func get_player_orbit_strength() -> float:
	return player_orbit_strength

## Gets the slipperiness of the weapon across the ground [0-1].
func get_sword_slide() -> float:
	return sword_slide

## Gets the drag applied each second to the player's velocity while in mid-air.
func get_air_drag() -> Vector2:
	return air_drag

## Gets the drag applied each second to the player's velocity while on the ground.
func get_ground_drag() -> Vector2:
	return ground_drag

## Gets the drag applied to the player per second (In addition to normal drag) when the
## player is beyond max_distance of the hammer.
func get_soft_limit_drag() -> float:
	return soft_limit_drag

## Gets the percentage of the players velocity [0-1] that is applied in reverse upon landing. 
## Due to drag, setting the bounce to 1 will not mean that the player fully recovers to their 
## origin height. If you wish  to do this, you must control the player manually.
func get_bounciness() -> float:
	return bounciness

## Gets the coefficient of max_distance which determines when the player's velocity is soft-limited.
## E.g. if the coef is 1.1, that means that the player must be father than 1.1 * max_distance to
## be slowed down.
##
## This feature exists as without it the player may slow greatly when making basic movements.
func get_soft_limit_distance_coef() -> float:
	return soft_limit_distance_coef

## Gets the number of seconds which the weapon ability has been charging.
func get_ability_charge() -> float:
	return ability_charge

## Gets the current charge of the weapon as a percentage [0-1].
func get_weapon_charge_perc() -> float:
	if not is_instance_valid(current_weapon): return 0.0
	return current_weapon.get_charge_prog(get_ability_charge())

## Return true if the player is currently charging their weapon.
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

## Gets the player's sword object.
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
	var sword : Sword = get_player_sword()
	
	damage += sword.get_last_sword_velocity().length()
	
	return damage

## Gets the multiplier of knockback applied to the player when they are dealt it.
func get_knockback_multi() -> float:
	return self_knockback_multi

## Get the largest distance from the player's hitbox edge to the player's origin.
func get_largest_size() -> float:
	var shape : CollisionShape2D = get_player_body().shape
	return (shape.shape.get_rect().size/2).length()

#endregion

#region Visual

## Clears all weapon visuals from the player (Should only be one at most)
func _clear_visuals() -> void:
	for child in get_children():
		if child is WeaponVisual:
			child.queue_free()

## Update any player-related visuals
func _visual_process() -> void:
	
	# Update player rotation
	get_player_body().get_sprite().flip_h = get_player_sword().get_tip_global_position().x < get_player_position().x

	# Update weapon visual
	if weapon_visual:
		weapon_visual.update_visual(get_player_position(), get_player_sword().get_tip_global_position())

#endregion

#region Item

## Equip the passed weapon
func equip_weapon(weapon : Weapon) -> void:
	
	if not weapon: return
	if not weapon.can_use(): weapon.init_weapon(self)
	
	weapon.reset()
	weapon.on_equip()
	current_weapon = weapon
	
	_clear_visuals()
	
	var scn : PackedScene = CosmeticLoader.get_weapon_visual(weapon)
	if scn:
		weapon_visual = scn.instantiate()
		weapon_visual.set_player(self)
		add_child(weapon_visual)

## Equip the weapon in the passed slot.
func equip_weapon_slot(slot : int) -> void:
	var weapon : Weapon = held_weapons.get(slot)
	if weapon:
		equip_weapon(weapon)

## Add the passed weapon to held weapons. Returns the weapon that was dropped as a result, if any.
func add_weapon(weapon : Weapon) -> Weapon:
	
	held_weapons.append(weapon)
	
	if held_weapons.size() > max_equip:
		var target_index : int = held_weapons.find(current_weapon)
		
		if held_weapons.size() == 0 or held_weapons.size() == 1:
			pass
		else:
			return drop_weapon(target_index)
	return null

## Drops the current weapon into the world.
func drop_weapon(slot : int) -> Weapon:
	
	if slot >= held_weapons.size(): return null
	
	if held_weapons[slot] == current_weapon:
		current_weapon.on_unequip()
	
	return held_weapons.pop_at(slot) # TODO Add item drop

## Pickup the weapon. Should be called by ItemPickup or any item source giving a weapon.
## Returns the weapon that was dropped as a result, if any.
func pickup_weapon(weapon : Weapon) -> Weapon:
	var dropped : Weapon = add_weapon(weapon)
	if equip_on_pickup:
		equip_weapon_slot(held_weapons.size()-1)
	return dropped

#endregion

#region Actions

## Teleport toward the target location, with respect to collisions.
func teleport_toward(vec2 : Vector2) -> void:
	var space_state := get_world_2d().direct_space_state
	var body_max_size := get_largest_size()
	var origin := get_player_position()
	var dir := origin.direction_to(vec2)
	
	var query := PhysicsRayQueryParameters2D.create(origin, vec2 + dir*body_max_size, 1)
	var result := space_state.intersect_ray(query)
	
	if not result:
		get_player_body().global_position = vec2
		return
	get_player_body().global_position = result.position - dir*body_max_size

## Start charging the main ability of the held weapon
func start_charging() -> void:
	charging_ability = true

## Use the main ability of the help weapon, resetting its charge.
func stop_charging() -> void:
	charging_ability = false
	if current_weapon:
		current_weapon.use(ability_charge)
	ability_charge = 0.0

func _input(event: InputEvent) -> void: # TODO Replace this with an input manager class.
	
	if event.is_action_pressed("use"):
		start_charging()
	
	elif event.is_action_released("use"):
		stop_charging()
	
	elif event.is_action_pressed("quit"):
		get_tree().quit()
	
	elif event.is_action_pressed("ui_accept"):
		if get_movement_mode() == MovementMode.NOCLIP:
			set_movement_mode(MovementMode.SWORD_ORBIT)
		else:
			get_player_sword().on_cable = null       
			set_movement_mode(MovementMode.NOCLIP)
	
## Apply the passed velocity to the player.
func apply_velocity(vel : Vector2) -> void:
	get_player_body().velocity += vel

## Deal knockback to the player. Functions similarly to apply_velocity, but should be used for
## any hostile knockback (incase further features are added which deal with it.)
func deal_knockback(vel : Vector2) -> void:
	apply_velocity(vel*get_knockback_multi())

## Set the collisions of all bodies in the player to enabled/disabled.
func set_collisions(state : bool) -> void:
	for child in Helper.get_all_descendants(self):
		if child is CollisionShape2D:
			child.disabled = not state

## Set the movement mode of the player, i.e. the way which the player moves.
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
	
	if charging_ability and is_instance_valid(current_weapon):
		if current_weapon.can_use():
			ability_charge += delta
		else:
			ability_charge = 0

	_visual_process()

func _ready() -> void:
	add_weapon(starting_weapon)
	equip_weapon_slot(0)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

## Set the last kinematic collision of the sword tip. Should be done each physics process.
func set_last_collision(collision:KinematicCollision2D) -> void:
	last_collision = collision

## Returns the global position of the player.
func get_player_position() -> Vector2:
	var body : PlayerBody = get_player_body()
	return body.global_position
