class_name Lance extends AnimatableBody2D

@onready var animator := $AnimationPlayer
@onready var warn     := $Warn

var direction : Vector2 :
	set(new):
		rotation = direction.angle() - PI/4
		direction = new

var speed     : float = 4000.0
var lifetime  : float = 1.5
var damage    : float = 2.0

var time_alive : float = 0.0
var dying      : bool = false

func _update_warn() -> void:
	warn.rotation = rotation
	warn.scale.y = (speed/800)*lifetime
	warn.global_position = global_position
	warn.global_position += (direction*warn.scale.y*800)/2

func _death() -> void:
	if dying: return
	dying = true
	animator.animation_finished.connect(func(_x:Variant) -> void: queue_free())
	animator.play("death")

func _physics_process(delta: float) -> void:
	time_alive += delta
	if time_alive > lifetime:
		_death()
	var result := move_and_collide(direction*speed*delta)
	if result and not dying:
		var collider := result.get_collider()
		if collider is PlayerBody:
			var player : Player = collider.get_player()
			player.deal_damage(damage)
			_death()

func _ready() -> void:
	_update_warn()
	$AudioStreamPlayer2D2.pitch_scale = randf_range(1,1.3)
	animator.play("spawn")
