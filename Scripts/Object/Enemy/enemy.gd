## Base enemy class with health, respawn, and some other logic.
@abstract class_name Enemy extends AnimatableBody2D

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

# --- #
@export_group("Health and Damage")
## The time it takes before the bat can be hit again.
@export var hit_time : float = 0.5

## The max health of the bat. Does not regen.
@export var health : float = 5.0

# --- #
@export_group("Knockback")
## Maximum knockback dealt to the player when they hit the bat.
@export var max_hit_kb : float = 1500.0

## Knockback dealt to the player on hit.
@export var knockback : float = 100.0

## Coefficient of knockback applied.
@export var knockback_coef : float = 0.6

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

func get_current_hit_color() -> Vector4:
	return sprite.material.get_shader_parameter("solid_color")

## Deals the target damage to the enemy. Returns true if killed.
func deal_damage(damage: float) -> bool:
	
	if time_since_last_hit < hit_time: return false
	
	health -= damage
	time_since_last_hit = 0.0
	
	# Damage display
	var color := get_current_hit_color()
	sprite.material.set_shader_parameter("solid_color", color + Vector4(0,0,0,1))
	
	if health <= 0:
		_kill()
		return true
	return false

func on_sword_hit(player : Player) -> void:
	
	if respawning : return
	if time_since_last_hit < hit_time: return
	
	var damage := player.get_blade_damage()
	var vel := player.get_player_sword().get_last_sword_velocity()
	
	if deal_damage(damage): # If killed
		TextDisplay.damage_display(get_parent(), global_position, str(round(damage*100)/100), vel.normalized(), Color.RED, 1.5)
	else:
		Sfx.play_sound(hit_sound)
		TextDisplay.damage_display(get_parent(), global_position, str(round(damage*100)/100), vel.normalized())
	
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
	
	# Deal knockback to bat
	velocity = vel*knockback_coef
	
	GameCamera.shake_current_camera(get_viewport(), 0.1)

func _kill() -> void:
	Sfx.play_sound(death_sound)
	velocity = Vector2.ZERO
	respawn_cooldown = 0.0
	respawning = true # Respawn var is used even on permadeath to indicate a dying status
	if respawn:
		sprite.visible = false

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

@abstract func _movement(_delta : float) -> void

func _physics_process(delta: float) -> void:
	if not respawning:
		_movement(delta)

func _process(delta: float) -> void:
	
	time_since_last_hit += delta
	
	var color : Vector4 = get_current_hit_color()
	sprite.material.set_shader_parameter("solid_color", Vector4(color.x,color.y,color.z,max(0,color.w-delta/hit_time)))
	
	sprite.flip_h = (target_point.x < global_position.x)
	
	if respawning:
		respawn_cooldown += delta
		if not only_respawn_on_screen:
			_check_respawn()
		return


func on_hit(collision : KinematicCollision2D) -> void:
	if not collision: return
	if respawning: return
	if collision.get_collider() is PlayerBody and is_instance_valid(collision.get_collider()):
		
		var player_body := collision.get_collider() as PlayerBody
		var player : Player = player_body.get_player()
		
		if not is_instance_valid(player): return
		elif  time_since_last_hit > hit_time: 
			player.deal_damage(2.6) 
			player.deal_knockback(global_position.direction_to(player.get_player_position())*knockback*Vector2(1,-1))

func _ready() -> void:
	notifier.screen_entered.connect(_check_respawn)
	notifier.global_position = global_position
	start_pos = global_position
	sprite.play("default")
	if spawn_dead:
		respawning = true
		respawn_cooldown = respawn_time
