## A flying sword miniboss (?)
class_name PossessedSword extends Enemy

@onready var collision_shape : CollisionShape2D = $CollisionShape2D

## Random variation in seconds between dashes.
@export var hover_variation : float = 3

## Time spent hovering before dashing
@export var hover_time : float = 1

## Time spinning before dashing
@export var warn_time : float = 0.5

## Amount of time it takes to fully spawn
@export var spawn_time : float = 2.5

## Amount of time the sword dashes for
@export var dash_time : float = 0.8

## Speed which the sword hovers
@export var hover_speed : float = 2.0

## The distance from the player which the sword aims to hover at
@export var hover_distance : float = 500

## The speed in radians which the sword rotates around the player.
@export var rotation_speed : float = 2.0

@export_category("Sound")

@export var sound_spawn : SoundData
@export var sound_charge : SoundData
@export var sound_dash : SoundData

var awakened := false
var awakening := false
var awaken_time : float = 0.0
var attack_progress : float = 1.0
var hover_rad : float = 0.0 # Rotation around the player to be hovering
var last_time : float = 0.0

var sword_velocity : Vector2 = Vector2.ZERO
var dash_direction : Vector2 = Vector2.ZERO

func _kill() -> void:
	super()
	$GPUParticles2D.emitting = true
	if !respawn:
		if !$GPUParticles2D.is_connected("finished", queue_free):
			$GPUParticles2D.finished.connect(queue_free)

func _respawn() -> void:
	super()
	sprite.play("spawn")

func on_sword_hit(_player : Player) -> void:
	if awakened:
		attack_progress = 0.0 - randf_range(0, hover_variation)
		super(_player)
	else:
		awaken()

func _movement(delta : float) -> void:
	
	last_time = attack_progress
	
	if awakening:
			
		awaken_time += delta
		
		var movement := Vector2.UP * 100
		move_and_collide(movement*delta)
		rotation = (awaken_time/spawn_time)*4*PI
		
		if awaken_time >= spawn_time:
			awakened = true
			awakening = false
			last_time = 0
			attack_progress = hover_time

	if not awakened:
		return
	
	## Find target
	if not target_player:
		# Set to random point if no target found
		var nearest_player : Player = Helper.get_closest_player(global_position, 10000)
		
		if nearest_player:
			target_player = nearest_player
		else:
			return
		
	target_point = target_player.get_player_position()
	target_point.y -= collision_shape.shape.get_rect().size.y/2
	
	attack_progress += delta
	
	var result : KinematicCollision2D
	
	# Hovering stage
	if attack_progress < hover_time:
		
		# Find target point (orbit) around the player
		var dest : Vector2 = target_point
		hover_rad += rotation_speed*delta
		dest += hover_distance*Vector2(cos(hover_rad), sin(hover_rad))
		
		sword_velocity = (dest-global_position)*hover_speed
		result = move_and_collide(sword_velocity*delta) # Convert to local and move
		rotation = global_position.direction_to(target_point).angle()
	
	# Spinning stage
	elif attack_progress < hover_time + warn_time:
		if (last_time < hover_time):
			Sfx.play_sound_2d(sound_charge, global_position, false)
		
		# Spin for the duration of cooldown
		rotation = global_position.direction_to(target_point).angle()
		
		rotation += 2*PI*pow((attack_progress-hover_time)/warn_time,1.0/3)
		
		# Prep dash direction for next step (when it occurs)
		dash_direction = global_position.direction_to(target_point)
		
		# Move backwards
		var movement := dash_direction * -hover_speed
		
		result = move_and_collide((movement + sword_velocity)*delta)
	
	# Dashing stage (deals damage)
	elif attack_progress < (hover_time + warn_time + dash_time):
		
		if (last_time < hover_time + warn_time):
			Sfx.play_sound_2d(sound_dash, global_position, false)
		
		result = move_and_collide(dash_direction*movement_speed*delta)
		
		if result:
			if result.get_collider() is PlayerBody:
				if time_since_last_hit > hit_time:
					on_hit(result.get_collider())
	
	# End of loop; reset to beginning with random offset
	else:
		attack_progress = -randf_range(0, hover_variation)
		hover_rad = target_point.angle_to(global_position)
	
	if result:
		move_and_collide(result.get_remainder().slide(result.get_normal()))
 
func awaken() -> void:
	if awakening: return
	GameCamera.set_current_camera_shake(get_viewport(), 0.2)
	awakening = true
	alert()
	Sfx.play_sound_2d(sound_spawn, global_position, false)

func _physics_process(delta: float) -> void:
	super(delta)
	collision_shape.disabled = respawning

func _ready() -> void:
	super()
	do_flip = false # Disable sprite flipping
	notifier.rect = collision_shape.shape.get_rect()
