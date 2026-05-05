class_name Fireball extends AnimatableBody2D

@onready var animation_player := $AnimationPlayer

@export var sound_hit : SoundData = SoundData.new(
	"res://Assets/Sound/SFX/Projectile/Fireball/Fireball Hit.wav",
	0.35,
	1.0,
	&"SFX"
)

@export var sound_hit_small : SoundData = SoundData.new(
	"res://Assets/Sound/SFX/Projectile/Fireball/Fireball Hit Small.wav",
	0.35,
	1.0,
	&"SFX"
)

@export var sound_death : SoundData = SoundData.new(
	"res://Assets/Sound/SFX/Projectile/Fireball/Fireball Death.wav",
	0.4,
	1.0,
	&"SFX"
)

var sender      : Node

var movement    : Vector2
var destination : Vector2
var start_pos   : Vector2

var speed       : float = 1.3
var arc_height  : float = 400
var damage      : float = 2.0
var knockback   : float = 1000
var progress    : float = 0.0
var time_alive  : float = 0.0

var dying : bool = false

func _death() -> void:
	if dying: return
	Sfx.play_sound_2d(sound_death, global_position, false)
	dying = true
	$Passive.stop()
	animation_player.animation_finished.connect(func(_x:Variant) -> void: queue_free())
	animation_player.play("death")

func on_sword_hit(player : Player) -> void:
	
	if dying: return
	if sender is Player: return # Don't allow hitting fireball twice
	
	var perc : float = player.get_sword_speed_perc()
	
	if perc < 0.1:
		return
	
	sender = player
	destination = start_pos
	start_pos = global_position
	progress = 0
	speed *= perc * 1.5

	if perc > 0.7:
		Sfx.play_sound_2d(sound_hit, global_position)
		time_alive = 0.0
	else:
		Sfx.play_sound_2d(sound_hit_small, global_position)
		time_alive = abs(speed)
	
	GameCamera.set_current_camera_shake(get_viewport(),perc*0.2)

func _physics_process(delta: float) -> void:
	
	time_alive += delta
	progress += delta*speed
	
	if time_alive > abs(speed) * 2: # 2x Past the destination position
		_death()
	
	if progress < 1.0:
		# Find the destination position
		var pos : Vector2 = start_pos
		pos += start_pos.direction_to(destination) * start_pos.distance_to(destination) * progress
		pos += sin(progress*PI)*arc_height*start_pos.direction_to(destination).rotated(PI/2)
		
		# Move toward that position
		movement = pos-global_position
	
	var result := move_and_collide(movement)
	var direction := movement.normalized()
	
	rotation = direction.angle() - PI/2
	
	if dying: return
	if result:
		var collider : Object = result.get_collider()
		
		if (collider is PlayerBody) and (sender is not Player):
			var player : Player = collider.get_player()
			player.deal_damage(damage)
			player.deal_knockback(direction*knockback)
			_death()
		
		elif collider is Enemy:
			if sender is Player:
				collider.on_projectile_hit(self)
				_death()
		
		elif collider is TileMapLayer:
			_death()

func fire(own:Node, dest:Vector2, height:float, spd:float=speed) -> void:
	$AnimationPlayer.play("spawn")
	sender = own
	destination = dest
	arc_height = height
	speed = spd

func _ready() -> void:
	start_pos = global_position
