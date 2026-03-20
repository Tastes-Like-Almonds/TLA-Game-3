## Base enemy class with health, respawn, and some other logic.
@abstract class_name Enemy extends AnimatableBody2D

signal Killed
signal Hit(damage:float)

@onready var alert_pos : Node2D = null

# --- #
@export_group("Basic Data (Must be set)")
## Sprite2D / AnimatedSprite2D of the enemy.
@export var sprite : Node2D

## Sprite2D / AnimatedSprite2D of the enemy.
@export var notifier : VisibleOnScreenNotifier2D

# --- #
@export_group("Sound")

@export var hit_sound: SoundData
@export var death_sound : SoundData
@export var alert_sound : SoundData

# --- #
@export_group("Health and Damage")

## If true, the enemy can take damage but never die.
@export var invincible : bool = false

## The time it takes before the enemy can be hit again.
@export var hit_time : float = 0.2

## The max health of the bat. Does not regen.
@export var health : float = 5.0

## If false, the enemy will use its physics body as a damage hitbox.
@export var disable_physics_hitbox : bool = false

@export var damage:float = 2.6

# --- #
@export_group("Knockback")
## Maximum knockback dealt to the player when they hit the bat.
@export var max_hit_kb : float = 1500.0

## Knockback dealt to the player on hit.
@export var knockback : float = 100.0

## Coefficient of knockback applied.
@export var knockback_coef : float = 2

## Maximum knockback that can be dealt to the enemy.
@export var max_kb : float = 1800

# --- #
@export_group("Movement")
## Movement speed of the bat.
@export var movement_speed : float = 600.0

## The distance which the bat will lock on to a player.
@export var aggro_range : float = 3000.0

# --- #
@export_group("Death and Respawning")
## If true, the bat will respawn after respawn_time in seconds.
@export var respawn : bool = true:
	set(value):
		respawn = value

## If true, the bat will only respawn when its spawn position enters the screen.
@export var only_respawn_on_screen : bool = true

## If true, the bat will spawn dead.
@export var spawn_dead : bool = true

## The time it takes to respawn if enabled, in seconds.
@export var respawn_time : float = 3.0

var do_flip : bool = true

var movement_delay : float = 1.0

var respawn_cooldown : float = 0.0
var movement_cooldown: float = 0.0
var respawning : bool = false
var target_point : Vector2

var start_pos : Vector2

var dying : bool = false

var target_player : Player
var start_health := health

var time_since_last_hit : float = 0.0

var velocity : Vector2 = Vector2.ZERO

@abstract func _movement(_delta : float) -> void

#region Health and damage
func get_current_hit_color() -> Vector4:
	return sprite.material.get_shader_parameter("solid_color")

## Deals the target damage to the enemy. Returns true if killed.
func deal_damage(amt: float) -> bool:
	
	if time_since_last_hit < hit_time: return false
	
	if !invincible:
		health -= amt
	
	time_since_last_hit = 0.0
	
	# Damage display
	var color := get_current_hit_color()
	sprite.material.set_shader_parameter("solid_color", color + Vector4(0,0,0,1))
	
	Hit.emit(amt)
	
	if health <= 0:
		_kill()
		return true
	return false

## When a sword strikes the enemy. Called from player.gd.
func on_sword_hit(player : Player) -> void:
	
	if respawning : return
	if time_since_last_hit < hit_time: return
	
	var sword_damage := player.get_blade_damage()
	var vel := player.get_player_sword().get_last_sword_velocity()
	
	if deal_damage(sword_damage): # If killed
		TextDisplay.damage_display(get_parent(), global_position, str(round(sword_damage*100)/100), vel.normalized(), Color.RED, 1.5)
	else:
		if hit_sound:
			Sfx.play_sound(hit_sound)
		TextDisplay.damage_display(get_parent(), global_position, str(round(sword_damage*100)/100), vel.normalized())
	
	var player_body := player.get_player_body()
	
	# Apply velocity to player based on sword speed
	if not player_body.is_on_floor():
		# Cancel y velocity
		if player_body.velocity.y > 0:
			player.set_velocity(Vector2(0, player_body.velocity.x))
		if (vel).length() > max_hit_kb:
			player.apply_velocity(vel.normalized()*-max_hit_kb)
		else:
			player.apply_velocity(vel)
	
	# Deal knockback to enemy
	player.reset_weapon_use() # Allow dash after hit
	velocity = player.get_blade_damage_perc()*player.get_knockback()*vel.normalized()
	
	GameCamera.shake_current_camera(get_viewport(), 0.1)

func _kill() -> void:
	
	if death_sound:
		Sfx.play_sound(death_sound)
	velocity = Vector2.ZERO
	respawn_cooldown = 0.0
	
	respawning = true # Respawn var is used even on permadeath to indicate a dying status
	sprite.visible = false
	
	Killed.emit()

func _respawn() -> void:
	sprite.visible = true
	respawning = false
	velocity = Vector2.ZERO
	health = start_health
	global_position = start_pos

func _check_respawn() -> void:
	if respawn_cooldown >= respawn_time and respawning:
		respawn_cooldown = 0
		respawning = false
		_respawn()

## Called with the *player* is hit by the enemy. Returns true if fatal.
func on_hit(collider : PhysicsBody2D, damage_val : float = -1) -> bool:
	if not collider: return false
	if respawning: return false
	if damage_val == -1: damage_val = damage
	if collider is PlayerBody and is_instance_valid(collider):
		
		var player_body := collider as PlayerBody
		var player : Player = player_body.get_player()
		
		if not is_instance_valid(player): return false
		elif time_since_last_hit > hit_time:
			if player.deal_damage(damage_val): # Only KB if the hit lands
				player.deal_knockback(global_position.direction_to(player.get_player_position())*knockback*Vector2(1,-1))
		
		return not player.is_alive()
	
	return false
		
#endregion

#region Sound
func alert() -> void:
	if alert_pos:
		TextDisplay.damage_display(get_parent(), alert_pos.global_position, "!", Vector2.UP, Color.RED, 2, 2, 0.1)
	if alert_sound:
		Sfx.play_sound_2d(alert_sound, global_position, false)
	else:
		push_warning("Attempt to play invalid alert sound")

#endregion

#region Basic
func _physics_process(delta: float) -> void:
	if not respawning:
		_movement(delta)

func _process(delta: float) -> void:
	
	time_since_last_hit += delta
	
	var color : Vector4 = get_current_hit_color()
	sprite.material.set_shader_parameter("solid_color", Vector4(color.x,color.y,color.z,max(0,color.w-delta/hit_time)))
	
	if do_flip:
		sprite.flip_h = !(target_point.x < global_position.x)
	
	if respawning:
		respawn_cooldown += delta
		if not only_respawn_on_screen:
			_check_respawn()
		return

func _ready() -> void:
	if notifier:
		notifier.screen_entered.connect(_check_respawn)
		notifier.global_position = global_position
	start_pos = global_position
	sprite.play("default")
	start_health = health
	
	if not disable_physics_hitbox:
		add_to_group(&"BladeHitable")
	
	if spawn_dead:
		respawning = true
		respawn_cooldown = respawn_time
	
	if has_node("AlertPos"):
		alert_pos = get_node("AlertPos")
#endregion
