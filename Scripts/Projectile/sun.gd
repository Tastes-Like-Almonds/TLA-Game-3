class_name SunProjectile extends Area2D

@onready var animator : AnimationPlayer = $AnimationPlayer

@export var target : Node2D
@export var damage : float = 2.0
@export var lifetime : float = 10.0

var last_pos   : Vector2
var last_start : Vector2
var direction  : Vector2

var dist       : float = 0.0
var time       : float = 2.0
var progress   : float = 0.0
var time_alive : float = 0.0

func _death() -> void:
	animator.animation_finished.connect(func(_x:Variant) -> void: queue_free())
	animator.play("death")

func on_collision(object:Node2D) -> void:
	
	var dir := global_position.direction_to(object.global_position)
	
	if object is PlayerBody:
		var player : Player = object.get_player()
		var vel := dir*1000
	
		vel.y = abs(vel.y)
		player.set_velocity(vel)
		player.deal_damage(damage)

func _reset_target_point() -> void:
	if not target: return
	last_pos   = target.global_position
	last_start = global_position
	direction  = last_start.direction_to(last_pos)
	dist       = last_start.distance_to(last_pos)

func _physics_process(delta: float) -> void:
	if not target: return
	progress += delta
	time_alive += delta
	progress = clampf(progress, 0.0, time)
	var pos : Vector2 = last_start + direction*dist*(-cos((progress/time)*PI)+1)/2
	global_position = pos
	
	if progress >= time:
		_reset_target_point()
		progress = 0.0
	
	if time_alive > lifetime:
		_death()

func _ready() -> void:
	animator.play("spawn")
	_reset_target_point()
	body_entered.connect(on_collision)
	
	if target:
		target.tree_exiting.connect(func() -> void:
			target = null
			_death()
		)
