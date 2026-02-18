## The player character.

class_name Player extends Node2D

@warning_ignore("unused_signal")
signal sword_collision(collision : KinematicCollision2D)

## Fired when the player's repsawn point is updated to a **different** value.
signal respawn_point_changed(new : Vector2)

## Fired after the player's loadout changes, whether this be from a new item picked up or
## the currently equipped item changing.
signal loadout_changed

## Fires when the player's health is set to a different value through any means.
signal health_changed(new : float)

var last_collision : KinematicCollision2D = null

enum MovementMode {
	SWORD_ORBIT, # The sword orbits the player
	PLAYER_ORBIT, # TODO The player orbits the sword (Not needed or functional currently.)
	NOCLIP # The player flies toward the sword when charging. Collisions disabled in this mode.
}

# TODO Cache sword and body ref until child structure is altered

@onready var sprite : AnimatedSprite2D = $playerBody/Sprite2D
@onready var modifier_display: ModifierDisplayManager = $playerBody/ModifierDisplayManager

#region Exports

@export var properties : PlayerProperties = PlayerProperties.new()

var property_modifiers : Dictionary[String, Array]

@export var hit_sound : SoundData = SoundData.new("res://Assets/Sound/SFX/Impact Sound (1).wav", 0.7, 1.0, &"SFX")
@export var death_sound : SoundData = SoundData.new("res://Assets/Sound/SFX/Player/Player Death.wav", 0.7, 1.0, &"SFX")
@export var refresh_sound : SoundData = SoundData.new("res://Assets/Sound/SFX/Player/Refresh Short.wav", 0.7, 1.0, &"SFX")

#endregion

func get_modified_property(property: String) -> Variant:
	
	var arr : Array[PropertyModifier] = []
	if property in property_modifiers:
		for item : Variant in property_modifiers.get(property):
			if item is PropertyModifier:
				arr.append(item)
	
	if current_weapon:
		var weapon_mods := current_weapon.get_property_modifiers()
		if property in weapon_mods:
			for item : Variant in weapon_mods.get(property):
				if item is PropertyModifier:
					arr.append(item)

	# Prevent infinite recursion (size_scale doesn't need it to be passed)
	var size_scale : float = 1
	if property != "size_scale":
		size_scale = get_size_scale()
	
	return properties.get_modified(property, arr, size_scale)

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

## An array of currently held weapons.
var held_weapons : Array[Weapon] = []

## The player's current health.
var health : float = properties.max_health:
	set(new):
		if new != health:
			health_changed.emit(new)
		health = new

## The amount of time since damage was last taken.
var last_hit_time : float = 0.0

## The amount of damage last dealt
var last_hit_amount : float = 0

## The amount of lives the player has left. Player dies at zero lives, unline some games.
var lives : int = 0

## The current time spent respawning
var time_respawning : float = 0.0

## If true, the player is currently dead (and respawning if not at zero lives.)
var dead : bool = false

## The global position the player will respawn at.
var respawn_pos : Vector2:
	set(new):
		if new != respawn_pos:
			respawn_pos = new # Done before the signal emits
			respawn_point_changed.emit(new)
		else:
			respawn_pos = new
#endregion

#region Getters
## Gets the max distance that the sword should be from the player.
## This is not a hard limit.
func get_max_distance() -> float:
	var dist : float =  get_modified_property("max_distance")
	
	if current_weapon:
		dist += current_weapon.get_max_distance_increase()
	
	return dist

## Gets the minimum distance the sword should be from the player.
func get_min_distance() -> float:
	return get_modified_property("min_distance")

## Gets the speed of gravity of the player
func get_gravity() -> float:
	return get_modified_property("gravity")

## Gets the cable gravity of the player
func get_cable_gravity() -> float:
	return get_modified_property("cable_gravity")

## Gets the stregth of the player, i.e. how much the player can fling themselves
## with their weapon.
func get_strength() -> float:
	return get_modified_property("strength")

## Gets the strength which the player uses in player_orbit mode.
## Currently unimplemented, and may never be.
func get_player_orbit_strength() -> float:
	return get_modified_property("player_orbit_strength")

## Gets the slipperiness of the weapon across the ground [0-1].
func get_sword_slide() -> float:
	return get_modified_property("sword_slide")

## Gets the drag applied each second to the player's velocity while in mid-air.
func get_air_drag() -> Vector2:
	return get_modified_property("air_drag")

## Gets the drag applied to the player per second (In addition to normal drag) when the
## player is beyond max_distance of the hammer.
func get_soft_limit_drag() -> float:
	return get_modified_property("soft_limit_drag")

## Gets the percentage of the players velocity [0-1] that is applied in reverse upon landing. 
## Due to drag, setting the bounce to 1 will not mean that the player fully recovers to their 
## origin height. If you wish  to do this, you must control the player manually.
func get_bounciness() -> float:
	return get_modified_property("bounciness")

## Gets the coefficient of max_distance which determines when the player's velocity is soft-limited.
## E.g. if the coef is 1.1, that means that the player must be father than 1.1 * max_distance to
## be slowed down.
##
## This feature exists as without it the player may slow greatly when making basic movements.
func get_soft_limit_distance_coef() -> float:
	return get_modified_property("soft_limit_distance_coef")

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

## Returns the player's knockback strength
func get_knockback() -> float:
	return get_modified_property("knockback")

## Returns the damage of the player's sword. Should not be called directly, instead
## use get_blade_damage().
func get_sword_damage() -> float:
	return get_modified_property("sword_damage")

## Returns the speed of the sword.
func get_sword_speed() -> float:
	return get_modified_property("sword_speed")

## Returns the speed the sword must travel to deal maximum damage.
#func get_sword_speed_damage() -> float:
	#return get_modified_property("sword_speed_damage")

func get_max_damage_time() -> float:
	return get_modified_property("max_damage_time")

## Returns the max health of the player.
func get_max_health() -> float:
	return get_modified_property("max_health")

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

## Gets the percentage of the sword's speed compared to its max speed.
func get_sword_speed_perc() -> float:
	var sword : Sword = get_player_sword()
	return sword.get_last_sword_velocity().length() / get_sword_speed()

## Returns the coefficient that would be applied to the player's damage
## upon a hit.
func get_blade_damage_perc() -> float:
	var sword : Sword = get_player_sword()
	var perc : float = sword.speed_value
	perc = min(perc, 1.0)
	return perc

## Gets the current damage of the blade (Value changes based on speed, charge, etc.)
func get_blade_damage() -> float:
	var damage := 0.0
	var perc := get_blade_damage_perc()
	damage += get_sword_damage()*perc
	return damage

## Gets the multiplier of knockback applied to the player when they are dealt it.
func get_knockback_multi() -> float:
	return get_modified_property("self_knockback_multi")

func get_invincibility_time() -> float:
	return get_modified_property("invincibility_time")

func get_max_equip() -> int:
	return get_modified_property("max_equip")

func get_equip_on_pickup() -> bool:
	return get_modified_property("equip_on_pickup")

func get_friction_time() -> float:
	return get_modified_property("friction_time")

func get_size_scale() -> float:
	return get_modified_property("size_scale")

## Get the largest distance from the player's hitbox edge to the player's origin.
func get_largest_size() -> float:
	var shape : CollisionShape2D = get_player_body().shape
	return (shape.shape.get_rect().size/2).length()

## Returns true if the player is alive. The player is considered dead if they are respawning.
func is_alive() -> bool:
	return not dead

## Returns the direction that the player is falling
func get_gravity_direction() -> Vector2:
	if get_modified_property("gravity") < 0:
		return Vector2.UP
	else:
		return Vector2.DOWN

#endregion

#region Visual

## Clears all weapon visuals from the player (Should only be one at most)
func _clear_visuals() -> void:
	for child in get_children():
		if child is WeaponVisual:
			child.queue_free()

## Update any player-related visuals
func _visual_process(delta : float) -> void:
	
	visible = not dead

	# Update player rotation
	var body : PlayerBody = get_player_body()
	if body:
		var do_flip_h : bool = !get_player_sword().get_tip_global_position().x < get_player_position().x
		var do_flip_v : bool = (get_gravity() <= 0)
		body.get_sprite().flip_h = do_flip_h
		body.get_sprite().flip_v = do_flip_v

	# Update player damage
	if sprite:
		var c : Vector4 = sprite.material.get_shader_parameter("solid_color")
		sprite.material.set_shader_parameter("solid_color", Vector4(c.x,c.y,c.z,max(0,c.w-delta/get_invincibility_time())))

	# Update weapon visual
	if weapon_visual:
		var sword := get_player_sword()
		if sword:
			weapon_visual.update_visual(delta)
			weapon_visual.update_audio(delta)

#endregion

#region Item

## Get the index of the currently equipped weapon, -1 if not found.
func get_current_weapon_index() -> int:
	return held_weapons.find(current_weapon)

## Equip the passed weapon
func equip_weapon(weapon : Weapon) -> void:
	
	if not weapon: return
	if not weapon.can_use: weapon.init_weapon(self)
	weapon.reset()
	weapon.on_equip()
	
	if current_weapon: current_weapon.on_unequip()
	current_weapon = weapon
	
	_clear_visuals()
	loadout_changed.emit()
	
	var scn : PackedScene = CosmeticLoader.get_weapon_visual(weapon)
	if scn:
		weapon_visual = scn.instantiate()
		weapon_visual.set_player(self)
		add_child(weapon_visual)

## Equip the weapon in the passed slot.
func equip_weapon_slot(slot : int) -> void:
	if slot >= held_weapons.size(): return
	var weapon : Weapon = held_weapons.get(slot)
	if weapon:
		equip_weapon(weapon)
	loadout_changed.emit()

## Add the passed weapon to held weapons. Returns the weapon that was dropped as a result, if any.
func add_weapon(weapon : Weapon) -> Weapon:
	
	held_weapons.append(weapon)
	loadout_changed.emit()
	
	if held_weapons.size() > get_max_equip():
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
	var item : Weapon = held_weapons.pop_at(slot)
	loadout_changed.emit()
	return item # TODO Add item drop

## Pickup the weapon. Should be called by ItemPickup or any item source giving a weapon.
## Returns the weapon that was dropped as a result, if any.
func pickup_weapon(weapon : Weapon) -> Weapon:
	var dropped : Weapon = add_weapon(weapon)
	if get_equip_on_pickup():
		equip_weapon_slot(held_weapons.size()-1)
	return dropped

#endregion

#region Actions

func _input(event: InputEvent) -> void: # TODO Replace this with an input manager class.
	
	if event.is_action_pressed("use"):
		if current_weapon and current_weapon.can_use:
			Sfx.play_sound_2d(current_weapon.use_end_sound, get_player_position())
			ability_charge = current_weapon.MAX_CHARGE
			current_weapon.use(ability_charge)
	
	#elif event.is_action_released("use"):
		#stop_charging()
	
	elif event.is_action_pressed("next_weapon"):
		var idx : int = get_current_weapon_index()
		idx = wrap(idx+1, 0, held_weapons.size())
		equip_weapon_slot(idx)
	
	elif event.is_action_pressed("previous_weapon"):
		var idx : int = get_current_weapon_index()
		idx = wrap(idx-1, 0, held_weapons.size())
		equip_weapon_slot(idx)
	
	elif event.is_action_pressed("noclip"):
		if get_movement_mode() == MovementMode.NOCLIP:
			set_movement_mode(MovementMode.SWORD_ORBIT)
		else:
			get_player_sword().on_cable = null       
			set_movement_mode(MovementMode.NOCLIP)
	
	elif event is InputEventKey:
		if event.pressed:
			# Hotbar hotkeys 0-9
			var number : int = event.keycode-48
			if number >= 0 and number <= 9:
				equip_weapon_slot(wrap(number-1, 0, 10))
	
## Apply the passed velocity to the player.
func apply_velocity(vel : Vector2) -> void:
	get_player_body().velocity += vel

## Set the passed velocity as the player's
func set_velocity(vel : Vector2) -> void:
	get_player_body().velocity = vel

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

## Sets the can_use property of the player's weapon to true; allows the player to
## use their weapon's ability again
func reset_weapon_use() -> void:
	if current_weapon:
		if !current_weapon.can_use:
			Sfx.play_sound(refresh_sound)
		current_weapon.can_use = true

## Teleport the player and sword to the target location.
func teleport_to(pos : Vector2) -> void:
	get_player_sword().on_cable = null
	get_player_body().global_position = pos
	get_player_sword().body.global_position = pos

## Teleport toward the target location, with respect to collisions.
func teleport_toward(vec2 : Vector2) -> void:
	
	var space_state := get_world_2d().direct_space_state
	var body := get_player_body()
	var body_max_size := get_largest_size()
	var origin := get_player_position()
	var dir := origin.direction_to(vec2)
	
	var query := PhysicsRayQueryParameters2D.create(origin, vec2 + dir*body_max_size, 1)
	var result := space_state.intersect_ray(query)
	
	if not result:
		get_player_body().global_position = vec2
		return
	
	body.global_position = result.position - dir*body_max_size
	get_player_sword().body.global_position  = body.global_position

#endregion

#region Damage/Death

## Clears all of the property modifiers attatched to the player which reset upon respawn (default)
func clear_respawn_modifiers() -> void:
	for stat:String in property_modifiers:
		for modifier:PropertyModifier in property_modifiers[stat]:
			if modifier.reset_on_respawn:
				property_modifiers[stat].erase(modifier)

func _respawn() -> void:
	
	teleport_to(respawn_pos)
	get_player_sword().on_cable = null
	
	clear_respawn_modifiers()
	
	time_respawning = 0
	last_hit_time = get_invincibility_time()*-2
	lives -= 1
	health = get_modified_property("max_health")
	dead = false

## Handle the death of the player.
func _death() -> void:
	if dead: return
	get_player_sword().on_cable = null
	Sfx.play_sound_2d(death_sound, get_player_position(), false)
	dead = true

## Kill the player.
func kill() -> void:
	_death()

## Returns true if the player is currently invincible, i.e. has just been hit.
func iframes_active() -> bool:
	return last_hit_time < get_invincibility_time()

## Deal amt of damage to the player, killing them if reaching zero. Returns true if the damage was
## successfully dealt.
func deal_damage(amt : float) -> bool:
	if dead: return false
	
	# Only deal damage in excess of last amount taken if still invincible
	if last_hit_time < get_invincibility_time(): amt -= last_hit_amount
	if amt <= 0: return false
	
	GameCamera.set_current_camera_shake(get_viewport(), clampf((amt/2)/get_modified_property("max_health"),0.0,0.2))
	Sfx.play_sound_2d(hit_sound, get_player_position())
	
	# TODO Set parent to something better
	TextDisplay.damage_display(get_parent(), get_player_position(),str(amt), Vector2.from_angle(-PI/2+randf_range(-PI/4,PI/4)))
	
	last_hit_time = 0.0
	last_hit_amount = amt
	
	var c : Vector4 = sprite.material.get_shader_parameter("solid_color")
	sprite.material.set_shader_parameter("solid_color", Vector4(c.x,c.y,c.z,1))
	
	health -= amt
	if health <= 0:
		_death()

	return true

#endregion

#region Modifiers

func get_modifier_ids(stat:String) -> Array[String]:
	if stat not in property_modifiers : return []
	var arr : Array[String] = []
	for mod : PropertyModifier in property_modifiers[stat]:
		if mod.id: arr.append(mod.id)
	return arr

## Add a property modifier to one of the player's stats.
func add_modifier(mod : PropertyModifier, stat:String) -> void:
	
	var last_size : float = get_size_scale()
	
	if stat not in property_modifiers:
		property_modifiers[stat] = [mod]
	
	elif mod.id not in get_modifier_ids(stat): # Add modifier if the id isn't present
		property_modifiers.get(stat).append(mod)
	
	else: # Modifier with id already present; override it
		for current_mod:Variant in property_modifiers.get(stat):
			if current_mod.id == mod.id:
				property_modifiers[stat].erase(current_mod)
		property_modifiers.get(stat).append(mod)
	
	# Make modifier display for timed modifications
	if mod.timer > 0:
		var color : Color = Color.WHITE
		match mod.id: # Hardcoded color. Yes, its not great, but its a niche use.
			"gravity_orb":
				color = Color.PURPLE
		
		modifier_display.create_display(mod.id, mod.timer, color)
	
	if stat == "size_scale":
		teleport_to(get_player_body().global_position/(get_size_scale()/last_size))

## Remove a target modifier by its id.
func remove_modifier_by_id(id : String, stat:String) -> void:
	if stat not in property_modifiers : return
	for mod : PropertyModifier in property_modifiers[stat]:
		if mod.id == id:
			property_modifiers[stat].erase(mod)

## Update all of the player's property modifiers.
func _update_modifiers(delta : float) -> void:
	for key in property_modifiers:
		for value : PropertyModifier in property_modifiers[key]:
			value.update(delta)
			if not value.is_active():
				var last_size : float = get_size_scale()
				property_modifiers[key].erase(value)
				if key == "size_scale":
					teleport_to(get_player_body().global_position/(get_size_scale()/last_size))

#endregion

func _process(delta: float) -> void:
	
	last_hit_time += delta
	
	if current_weapon:
		current_weapon.process_weapon(delta)
	
	charging_ability = (ability_charge > 0.0)
	
	if charging_ability and is_instance_valid(current_weapon):
		if current_weapon.can_use:
			ability_charge -= delta
		else:
			ability_charge = 0
	ability_charge = max(0, ability_charge)

	# Update the respawn timer
	if dead and lives > 0:
		time_respawning += delta
		if time_respawning >= get_modified_property("respawn_time"):
			_respawn()

	_visual_process(delta) # Handle weapon visuals, colors, etc.
	_update_modifiers(delta) # Modifiers for player properties

func _physics_process(_delta: float) -> void:
	var size_scale := get_size_scale()
	scale = Vector2(size_scale, size_scale)

func _ready() -> void:
	respawn_pos = get_player_body().global_position
	lives = get_modified_property("max_lives")
	add_weapon(get_modified_property("starting_weapon"))
	equip_weapon_slot(0)
	sprite.play("idle")
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED # TODO Move to a better spot when level loading is better

## Set the last kinematic collision of the sword tip. Should be done each physics process.
func set_last_collision(collision:KinematicCollision2D) -> void:
	sword_collision.emit(collision)
	last_collision = collision

## Returns the global position of the player.
func get_player_position() -> Vector2:
	var body : PlayerBody = get_player_body()
	if not body: return Vector2.ZERO
	return body.global_position
