class_name Lightning extends Node2D

static var warn_time : float = 0.5

@onready var area          : Area2D           = $Area2D
@onready var spark         : GPUParticles2D   = $Spark
@onready var strike_sprite : AnimatedSprite2D = $Strike

@export var damage    : float = 3.0
@export var knockback : float = 1500

@export var spark_sound  := SoundData.new(
	"res://Assets/Sound/SFX/Projectile/Lightning/Lightning Spark.mp3",  
	0.15, 1.0, &"SFX"
)

@export var strike_sound := SoundData.new(
	"res://Assets/Sound/SFX/Projectile/Lightning/Lightning Strike.mp3", 
	0.10, 1.0, &"SFX"
)

func _strike() -> void:
	
	spark.hide()
	strike_sprite.show()
	strike_sprite.play("strike")
	Sfx.play_sound_2d(strike_sound, global_position)
	
	for body in area.get_overlapping_bodies():
		
		if body is not PlayerBody: continue
		
		var player : Player  = body.get_player()
		var dir    : Vector2 = global_position.direction_to(player.get_player_position())
		
		player.deal_damage(damage)
		player.deal_knockback(dir*knockback)

func _ready() -> void:
	get_tree().create_timer(warn_time, false).timeout.connect(_strike)
	Sfx.play_sound_2d(spark_sound,global_position)
	strike_sprite.stop()
	strike_sprite.hide()
	strike_sprite.animation_finished.connect(queue_free)
